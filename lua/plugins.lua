--[[
                       &&&                                                                                                
                    &##&                                                         █████╗ ██╗     ███████╗███╗   ███╗██╗    
                  &##&                                                          ██╔══██╗██║     ██╔════╝████╗ ████║██║    
                 BB&                                                            ███████║██║     █████╗  ██╔████╔██║██║    
               &GB                                     &                        ██╔══██║██║     ██╔══╝  ██║╚██╔╝██║██║    
              &GB                                     &BGBBBBBBBB###&           ██║  ██║███████╗███████╗██║ ╚═╝ ██║██║    
              GG                                       &GGGGGGGGGGGGGB#&        ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝     ╚═╝╚═╝    
             #P#                                        &&#BGGGGGGGGGGG#                     nvim plugins                 
             BP&                                           &GGGGGGGGGB#                                                   
         &#BGPP&                                         &#BGGGGGGGB#              * tldr: managed with lazy.nvim         
     &#BGGGGGPP&                                     &&#BGGGGGGB##&                  - lsp: integrated + nvim-lspconfig   
  &#GPPPGGGGGBPB                                &&##BGGGGGBB#&&                      - completion: nvim-cmp + LuaSnip     
 #PPPPPPPGGPG BP&                        &&##BBGGGGGGBB#&&                           - syntax: nvim-treesitter            
 PPPPPPPPPPPPGBPG&&&       &&&&&&###BBBGGGGGGGBB##&&                                 - pickers: telescope.nvim            
 &BGPPPPPPPPPPPPPPGGGGGGGGGGGGGGGGGGGBBB##&&&                                        - files: neo-tree.nvim               
    &&##BBBBGGGGGGGPGBBBBBB####&&&&                                                  - git: vim-fugitive + gitsigns.nvim  
                  &#B#&                                                              - extra: hexmode, vim-combo,         
               &&    ###&                                                                     rust-tools, nvim-colorizer, 
              &G#      &&#&&&                                                                 nvim-jdtls, vim-surround,   
                             &&&                                                              undotree,                   
]]--

local function set_lsp_binds(_, bufnr)
	require('keybinds'):set_lsp_keys({buffer=bufnr})
end

return {
	'alemidev/peak.nvim',            -- color scheme

	'rickhowe/diffchar.vim',         -- word-level diffs
	'fidian/hexmode',                -- convert buffers into hex view with xxd
	'alemidev/vim-combo',            -- track code combos

	'tpope/vim-fugitive',            -- better git commands
	'tpope/vim-surround',            -- text object motions for surrounding

	'mbbill/undotree',               -- tree undo history visualizer

	"stevearc/dressing.nvim",        -- better vim.fn.input() and vim.fn.select()

	{
		'norcalli/nvim-colorizer.lua',    -- show hex color codes
		config = function () require('colorizer').setup() end
	},

	{
		"ellisonleao/glow.nvim",          -- markdown previewer with glow
		config = function() require("glow").setup() end
	},

	{
		'lewis6991/gitsigns.nvim',        -- show diff signs in gutter
		config = function()
			require('gitsigns').setup {   -- configure symbols and colors
				signs = {
					add          = {hl = 'GitSignsChange', text = '╎'},
					change       = {hl = 'GitSignsChange', text = '│'},
					delete       = {hl = 'GitSignsDelete', text = '_'},
					topdelete    = {hl = 'GitSignsDelete', text = '‾'},
					changedelete = {hl = 'GitSignsDelete', text = '~'},
					untracked    = {hl = 'GitSignsUntracked', text = '╎'},
				},
			}
		end
	},

	{
		'nvim-treesitter/nvim-treesitter',
		build = ':TSUpdate', -- if parsers break upon install, check under scoop/apps/neovim/{version}/lib/nvim/parser
		config = function()
			require('nvim-treesitter.configs').setup({
				highlight = { enable = true },
				incremental_selection = { enable = true },
				textobjects = { enable = true }
			})
			vim.opt.foldmethod = "expr"
			vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
		end
	},

	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v2.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
			"alemidev/neo-tree-symbolmap",
			"mrbjarksen/neo-tree-diagnostics.nvim",
		},
		config = function ()
			vim.g.neo_tree_remove_legacy_commands = 1
			require('neo-tree').setup({
				sources = {
					"filesystem",
					"buffers",
					"git_status",
					"symbolmap",
					"diagnostics",
				},
				window = {
					width = 30,
				}
			})
		end
	},

	{
		'nvim-telescope/telescope.nvim',  -- fuzzy finder, GUI component
		dependencies = {
			{'nvim-lua/plenary.nvim'},    -- some utilities made for telescope
			{'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }, -- fzf algorithm implemented in C for faster searches
		},
		config = function()
			local telescope = require('telescope')
			telescope.load_extension('fzf')
			telescope.setup({
				defaults = {
					path_display = { "truncate" },
					layout_config = {
						horizontal = {
							preview_width = 0.65,
							results_width = 0.35,
						},
						vertical = {
							mirror = false,
						},
						cursor = {
							preview_width = 0.6,
							results_width = 0.4,
						}
					},
				}
			})
			require('keybinds'):set_telescope_keys({})
			-- for some reason, telescope breaks folds!
			-- this should fix (took it off an issue on github)
			vim.api.nvim_create_autocmd('BufRead', {
				callback = function()
					vim.api.nvim_create_autocmd('BufWinEnter', {
						once = true,
						command = 'normal! zx'
					})
				end
			})
		end
	},

	'mfussenegger/nvim-jdtls',       -- extra LSP stuff for java

	{
		'simrat39/rust-tools.nvim',      -- extra LSP defaults for rust
		dependencies = {
			'hrsh7th/nvim-cmp',          -- referenced here to guarantee load order
		},
		config = function ()
			local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
			local rust_tools = require("rust-tools")
			rust_tools.setup({
				tools = {
					inlay_hints = { auto = true, highlight = "InlayHint" },
					hover_actions = { border = "none" },
				},
				server = {
					capabilities = capabilities,
					on_attach = set_lsp_binds,
				},
				dap = { adapter = require('dap').adapters.lldb },
			})
			rust_tools.inlay_hints.enable()

		end
	},

	{
		'neovim/nvim-lspconfig',       -- import LSP configurations
		dependencies = {
			'hrsh7th/nvim-cmp',        -- referenced here to guarantee load order
			'folke/neodev.nvim',       -- configure lua lsp with neovim runtime
		},
		config = function ()
			require("neodev").setup({})
			local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
			local lspconfig = require("lspconfig")
			lspconfig.bashls.setup({capabilities=capabilities, on_attach=set_lsp_binds})
			lspconfig.pylsp.setup({capabilites = capabilities, on_attach = set_lsp_binds, settings = { pylsp = { plugins = { pycodestyle = { enabled = false } } } } })
			lspconfig.clangd.setup({capabilities=capabilities, on_attach=set_lsp_binds})
			lspconfig.ltex.setup({capabilities=capabilities, on_attach=set_lsp_binds})
			lspconfig.lua_ls.setup({capabilites=capabilities, on_attach=set_lsp_binds, settings = { Lua = { telemetry = { enable = false }}}}) -- default-on telemetry is never ok ...
			-- lspconfig.kotlin_language_server.setup({capabilities=capabilities, on_attach=set_lsp_binds})
		end
	},

	{
		'mfussenegger/nvim-dap',        -- debugger adapter protocol
		dependencies = {
			'rcarriga/nvim-dap-ui',     --batteries-included debugger ui
		},
		config = function()
			local dap = require('dap')
			dap.adapters.python = {
				type = 'executable',
				command = (vim.fn.environ()["VIRTUAL_ENV"] or "") .. "/bin/python",
				args = { '-m', 'debugpy.adapter' },
			}
			dap.configurations.python = {
				{
					name = "Launch file",
					type = "python",
					request = "launch",
					program = vim.fn.expand('%'),
					cwd = '${workspaceFolder}',
				},
			}
			dap.adapters.lldb = {
				type = 'executable',
				command = '/usr/bin/lldb-vscode', -- adjust as needed, must be absolute path
				name = 'lldb'
			}
			dap.configurations.cpp = {
				{
					name = 'Launch',
					type = 'lldb',
					request = 'launch',
					program = function()
						vim.fn.input("run: ", vim.fn.getcwd() .. "/", "command")
					end,
					cwd = '${workspaceFolder}',
				},
			}
			dap.configurations.c = dap.configurations.cpp
			dap.configurations.rust = {
				{
					name = 'Launch',
					type = 'lldb',
					request = 'launch',
					program = function()
						local program = ""
						for i in string.gmatch(vim.fn.getcwd(), "([^/]+)") do -- TODO jank! assumes folder is called just like executable
							program = i
						end
						return vim.fn.getcwd() .. "/target/debug/" .. program -- TODO can I put startup file somewhere?
					end,
					cwd = '${workspaceFolder}',
					args = function()
						local args = {}
						for str in string.gmatch(vim.fn.input("args: "), "([^,]+)") do
							table.insert(args, str)
						end
						return args
					end,
				},
			}
			require('keybinds'):set_dap_keys({})
			require('dapui').setup()
		end,
	},

	{
		'hrsh7th/nvim-cmp',             -- completion engine core
		dependencies = {
			'hrsh7th/cmp-nvim-lsp',                 -- complete with LSP
			'hrsh7th/cmp-nvim-lsp-signature-help',  -- complete function signatures
			'hrsh7th/cmp-nvim-lsp-document-symbol', -- complete document symbols
			'hrsh7th/cmp-path',                     -- complete paths
			'hrsh7th/cmp-buffer',                   -- complete based on buffer
			'rcarriga/cmp-dap',                     -- complete in debugger
			'saadparwaiz1/cmp_luasnip',             -- complete with snippets
			'onsails/lspkind.nvim',                 -- fancy icons and formatting
			'L3MON4D3/LuaSnip',                     -- snippet engine
		},
		config = function ()
			local cmp = require('cmp')
			cmp.setup({
				formatting = {
					format = function(entry, vim_item)
						local kind = require("lspkind").cmp_format({ mode = "symbol" })(entry, vim_item)
						kind.kind = " " .. kind.kind .. " "
						return kind
					end,
				},
				snippet = {
					expand = function(args) require('luasnip').lsp_expand(args.body) end,
				},
				mapping = cmp.mapping.preset.insert({
					['<Tab>'] = cmp.mapping.confirm({ select = true }),
					['<C-Space>'] = cmp.mapping.complete(),
				}),
				sources = cmp.config.sources({
					{ name = 'nvim_lsp_signature_help', max_item_count = 1 },
					{ name = 'nvim_lsp' },
					{ name = 'path', max_item_count = 3 },
					{ name = 'luasnip' },
					{ name = 'buffer', keyword_length = 3, max_item_count = 3 },
				}),
			})
			cmp.setup.filetype({ "dap-repl", "dapui_watches" }, {
				formatting = {
					format = function(entry, vim_item)
						local kind = require("lspkind").cmp_format({ mode = "symbol" })(entry, vim_item)
						kind.kind = " " .. kind.kind .. " "
						return kind
					end,
				},
				mapping = cmp.mapping.preset.insert({ ['<Tab>'] = cmp.mapping.confirm({ select = true }) }),
				sources = {
					{ name = 'dap' },
				},
			})
			-- cmp.setup.cmdline('/', {
			-- 	formatting = {
			-- 		format = function(entry, vim_item)
			-- 			local kind = require("lspkind").cmp_format({ mode = "symbol" })(entry, vim_item)
			-- 			kind.kind = " " .. kind.kind .. " "
			-- 			return kind
			-- 		end,
			-- 	},
			-- 	mapping = cmp.mapping.preset.cmdline(),
			-- 	sources = cmp.config.sources({
			-- 		{ name = 'nvim_lsp_document_symbol' },
			-- 		{ name = 'buffer', keyword_length = 3 },
			-- 	})
			-- })
		end
	},
}
