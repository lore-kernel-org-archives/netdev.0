From: Meelis Roos <mroos@linux.ee>
Subject: Re: 4.1 regression in resizable hashtable tests
Date: Thu, 2 Jul 2015 22:09:52 +0300 (EEST)
Message-ID: <alpine.LRH.2.11.1507022208200.28236@math.ut.ee>
References: <alpine.LRH.2.11.1507011259180.4092@math.ut.ee> <20150702123130.GA20843@pox.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: sparclinux@vger.kernel.org,
	Linux Kernel list <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <20150702123130.GA20843@pox.localdomain>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > [   31.898697] Running resizable hashtable tests...
> > [   31.898915]   Adding 2048 keys
> > [   31.952911]   Traversal complete: counted=17, nelems=2048, entries=2048
> > [   31.953004] Test failed: Total count mismatch ^^^
> > [   32.022676]   Traversal complete: counted=17, nelems=2048, entries=2048
> > [   32.022788] Test failed: Total count mismatch ^^^
> > [   32.022828]   Deleting 2048 keys
> 
> Thanks for the report. I think this is already fixed. Can you try with the
> following commit:
> 
> commit 246b23a7695bd5a457aa51a36a948cce53d1d477

Tried todays got, it's actually worse:

[    0.000000] PROMLIB: Sun IEEE Boot Prom 'OBP 3.31.0 2001/07/25 20:36'
[    0.000000] PROMLIB: Root node compatible: 
[    0.000000] Linux version 4.1.0-12127-g4da3064 (mroos@u5) (gcc version 4.9.2 (Debian 4.9.2-20) ) #19 Thu Jul 2 21:09:48 EEST 2015
[    0.000000] bootconsole [earlyprom0] enabled
[    0.000000] ARCH: SUN4U
[    0.000000] Ethernet address: 08:00:20:f8:c7:72
[    0.000000] MM: PAGE_OFFSET is 0xfffff80000000000 (max_phys_bits == 40)
[    0.000000] MM: VMALLOC [0x0000000100000000 --> 0x0000060000000000]
[    0.000000] MM: VMEMMAP [0x0000060000000000 --> 0x00000c0000000000]
[    0.000000] Kernel: Using 10 locked TLB entries for main kernel image.
[    0.000000] Remapping the kernel... done.
[    0.000000] kmemleak: Kernel memory leak detector disabled
[    0.000000] OF stdout device is: /pci@1f,0/pci@1,1/ebus@1/se@14,400000:a
[    0.000000] PROM: Built device tree with 70266 bytes of memory.
[    0.000000] Top of RAM: 0x1ff2c000, Total RAM: 0x1ff2a000
[    0.000000] Memory hole size: 0MB
[    0.000000] Allocated 16384 bytes for kernel page tables.
[    0.000000] Zone ranges:
[    0.000000]   Normal   [mem 0x0000000000000000-0x000000001ff2bfff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000000000-0x000000001fefdfff]
[    0.000000]   node   0: [mem 0x000000001ff00000-0x000000001ff2bfff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000000000-0x000000001ff2bfff]
[    0.000000] On node 0 totalpages: 65429
[    0.000000]   Normal zone: 512 pages used for memmap
[    0.000000]   Normal zone: 0 pages reserved
[    0.000000]   Normal zone: 65429 pages, LIFO batch:15
[    0.000000] Booting Linux...
[    0.000000] CPU CAPS: [flush,stbar,swap,muldiv,v9,mul32,div32,v8plus]
[    0.000000] CPU CAPS: [vis]
[    0.000000] pcpu-alloc: s0 r0 d32768 u32768 alloc=1*32768
[    0.000000] pcpu-alloc: [0] 0 
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 64917
[    0.000000] Kernel command line: root=/dev/sda1 ro
[    0.000000] PID hash table entries: 2048 (order: 1, 16384 bytes)
[    0.000000] Dentry cache hash table entries: 65536 (order: 6, 524288 bytes)
[    0.000000] Inode-cache hash table entries: 32768 (order: 5, 262144 bytes)
[    0.000000] Sorting __ex_table...
[    0.000000] Memory: 475912K/523432K available (5266K kernel code, 516K rwdata, 1672K rodata, 520K init, 30210K bss, 47520K reserved, 0K cma-reserved)
[    0.000000] Running RCU self tests
[    0.000000] Testing tracer nop: PASSED
[    0.000000] NR_IRQS:2048 nr_irqs:2048 1
[   26.997388] clocksource: tick: mask: 0xffffffffffffffff max_cycles: 0x5306eb473f, max_idle_ns: 440795213232 ns
[   27.101123] clocksource: mult[2c71c72] shift[24]
[   27.140662] clockevent: mult[5c28f5c3] shift[32]
[   27.182668] Console: colour dummy device 80x25
[   27.218768] console [tty0] enabled
[   27.243489] bootconsole [earlyprom0] disabled
[   27.279960] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
[   27.280027] ... MAX_LOCKDEP_SUBCLASSES:  8
[   27.280070] ... MAX_LOCK_DEPTH:          48
[   27.280114] ... MAX_LOCKDEP_KEYS:        8191
[   27.280159] ... CLASSHASH_SIZE:          4096
[   27.280204] ... MAX_LOCKDEP_ENTRIES:     32768
[   27.280250] ... MAX_LOCKDEP_CHAINS:      65536
[   27.280295] ... CHAINHASH_SIZE:          32768
[   27.280341]  memory used by lock dependency info: 8159 kB
[   27.280392]  per task-struct memory footprint: 1920 bytes
[   27.280443] ------------------------
[   27.280480] | Locking API testsuite:
[   27.280518] ----------------------------------------------------------------------------
[   27.280584]                                  | spin |wlock |rlock |mutex | wsem | rsem |
[   27.280650]   --------------------------------------------------------------------------
[   27.280755]                      A-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   27.347473]                  A-B-B-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   27.414742]              A-B-B-C-C-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   27.482380]              A-B-C-A-B-C deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   27.550106]          A-B-B-C-C-D-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   27.618220]          A-B-C-D-B-D-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   27.686412]          A-B-C-D-B-C-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   27.754659]                     double unlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   27.821852]                   initialize held:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   27.888859]                  bad unlock order:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   27.956425]   --------------------------------------------------------------------------
[   27.956522]               recursive read-lock:             |  ok  |             |  ok  |
[   27.979039]            recursive read-lock #2:             |  ok  |             |  ok  |
[   28.001563]             mixed read-write-lock:             |  ok  |             |  ok  |
[   28.024110]             mixed write-read-lock:             |  ok  |             |  ok  |
[   28.046651]   --------------------------------------------------------------------------
[   28.046747]      hard-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
[   28.080394]      soft-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
[   28.114080]      hard-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
[   28.147750]      soft-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
[   28.181441]        sirq-safe-A => hirqs-on/12:  ok  |  ok  |  ok  |
[   28.215142]        sirq-safe-A => hirqs-on/21:  ok  |  ok  |  ok  |
[   28.248831]          hard-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
[   28.282498]          soft-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
[   28.316180]          hard-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
[   28.349883]          soft-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
[   28.383591]     hard-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
[   28.417445]     soft-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
[   28.451313]     hard-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
[   28.485171]     soft-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
[   28.519043]     hard-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
[   28.552919]     soft-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
[   28.586807]     hard-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
[   28.620644]     soft-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
[   28.654491]     hard-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
[   28.688235]     soft-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
[   28.721975]     hard-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
[   28.755816]     soft-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
[   28.789659]     hard-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
[   28.823537]     soft-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
[   28.857444]     hard-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
[   28.891316]     soft-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
[   28.925227]     hard-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
[   28.959124]     soft-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
[   28.993068]     hard-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
[   29.026955]     soft-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
[   29.060846]     hard-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
[   29.094728]     soft-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
[   29.128716]     hard-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
[   29.162587]     soft-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
[   29.196489]       hard-irq lock-inversion/123:  ok  |  ok  |  ok  |
[   29.230406]       soft-irq lock-inversion/123:  ok  |  ok  |  ok  |
[   29.264377]       hard-irq lock-inversion/132:  ok  |  ok  |  ok  |
[   29.298300]       soft-irq lock-inversion/132:  ok  |  ok  |  ok  |
[   29.332252]       hard-irq lock-inversion/213:  ok  |  ok  |  ok  |
[   29.366184]       soft-irq lock-inversion/213:  ok  |  ok  |  ok  |
[   29.400146]       hard-irq lock-inversion/231:  ok  |  ok  |  ok  |
[   29.434058]       soft-irq lock-inversion/231:  ok  |  ok  |  ok  |
[   29.467995]       hard-irq lock-inversion/312:  ok  |  ok  |  ok  |
[   29.501937]       soft-irq lock-inversion/312:  ok  |  ok  |  ok  |
[   29.535924]       hard-irq lock-inversion/321:  ok  |  ok  |  ok  |
[   29.569838]       soft-irq lock-inversion/321:  ok  |  ok  |  ok  |
[   29.603779]       hard-irq read-recursion/123:  ok  |
[   29.615153]       soft-irq read-recursion/123:  ok  |
[   29.626541]       hard-irq read-recursion/132:  ok  |
[   29.637931]       soft-irq read-recursion/132:  ok  |
[   29.649320]       hard-irq read-recursion/213:  ok  |
[   29.660691]       soft-irq read-recursion/213:  ok  |
[   29.672085]       hard-irq read-recursion/231:  ok  |
[   29.683459]       soft-irq read-recursion/231:  ok  |
[   29.694860]       hard-irq read-recursion/312:  ok  |
[   29.706244]       soft-irq read-recursion/312:  ok  |
[   29.717637]       hard-irq read-recursion/321:  ok  |
[   29.729013]       soft-irq read-recursion/321:  ok  |
[   29.740399]   --------------------------------------------------------------------------
[   29.740488]   | Wound/wait tests |
[   29.740545]   ---------------------
[   29.740609]                   ww api failures:  ok  |  ok  |  ok  |
[   29.774577]                ww contexts mixing:  ok  |  ok  |
[   29.797179]              finishing ww context:  ok  |  ok  |  ok  |  ok  |
[   29.842258]                locking mismatches:  ok  |  ok  |  ok  |
[   29.876139]                  EDEADLK handling:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   29.989562]            spinlock nest unlocked:  ok  |
[   30.000888]   -----------------------------------------------------
[   30.000967]                                  |block | try  |context|
[   30.001043]   -----------------------------------------------------
[   30.001123]                           context:  ok  |  ok  |  ok  |
[   30.035168]                               try:  ok  |  ok  |  ok  |
[   30.069043]                             block:  ok  |  ok  |  ok  |
[   30.102906]                          spinlock:  ok  |  ok  |  ok  |
[   30.137106] -------------------------------------------------------
[   30.137201] Good, all 253 testcases passed! |
[   30.137267] ---------------------------------
[   30.146082] ODEBUG: selftest passed
[   30.146448] kmemleak: Early log buffer exceeded (2042), please increase DEBUG_KMEMLEAK_EARLY_LOG_SIZE
[   30.287689] Calibrating delay using timer specific routine.. 727.40 BogoMIPS (lpj=3637009)
[   30.287827] pid_max: default: 32768 minimum: 301
[   30.289249] Mount-cache hash table entries: 1024 (order: 0, 8192 bytes)
[   30.289385] Mountpoint-cache hash table entries: 1024 (order: 0, 8192 bytes)
[   30.297477] ftrace: allocating 15150 entries in 30 pages
[   30.378044] devtmpfs: initialized
[   30.425063] Performance events: No support for PMU type 'ultra12'
[   30.429125] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 19112604462750000 ns
[   30.432647] Testing tracer function: 
[   30.435241] kworker/u2:0 (11) used greatest stack depth: 8168 bytes left
[   30.597479] PASSED
[   30.597571] Testing dynamic ftrace: PASSED
[   30.877428] Testing dynamic ftrace ops #1: (1 0 1 0 0) (1 1 2 0 0) (2 1 3 0 73) (2 2 4 0 161) PASSED
[   31.170306] Testing dynamic ftrace ops #2: (1 0 1 77 0) (1 1 2 165 0) (2 1 3 1 3) (2 2 4 86 88) PASSED
[   31.470901] Testing ftrace recursion: PASSED
[   31.538716] Testing ftrace recursion safe: PASSED
[   31.606680] Testing ftrace regs(no arch support): PASSED
[   31.674779] Testing tracer irqsoff: PASSED
[   31.700741] Testing tracer function_graph: PASSED
[   31.864718] atomic64_test: passed
[   31.870878] NET: Registered protocol family 16
[   31.942494] /pci@1f,0: PCI IO[1fe02000000] MEM[1ff00000000]
[   31.942752] /pci@1f,0: SABRE PCI Bus Module ver[0:0]
[   31.942849] PCI: Scanning PBM /pci@1f,0
[   31.946474] sabre f005f9c0: PCI host bridge to bus 0000:00
[   31.946620] pci_bus 0000:00: root bus resource [io  0x1fe02000000-0x1fe02ffffff] (bus address [0x0000-0xffffff])
[   31.946783] pci_bus 0000:00: root bus resource [mem 0x1ff00000000-0x1ffffffffff] (bus address [0x00000000-0xffffffff])
[   31.946958] pci_bus 0000:00: root bus resource [bus 00-02]
[   31.973408] pci 0000:00:01.0: can't claim BAR 8 [mem 0x1ff00000000-0x1ffbfffffff]: address conflict with Video RAM area [??? 0x1ff000a0000-0x1ff000bffff flags 0x80000000]
[   32.340123] vgaarb: device added: PCI:0000:01:02.0,decodes=io+mem,owns=none,locks=none
[   32.340300] vgaarb: loaded
[   32.340361] vgaarb: bridge control possible 0000:01:02.0
[   32.343154] SCSI subsystem initialized
[   32.357287] libata version 3.00 loaded.
[   32.370610] /pci@1f,0/pci@1,1/ebus@1/eeprom@14,0: Mostek regs at 0x1fff1000000
[   32.570285] DMA-API: preallocated 32768 debug entries
[   32.570403] DMA-API: debugging enabled by kernel config
[   32.571542] AUXIO: Found device at /pci@1f,0/pci@1,1/ebus@1/auxio@14,726000
[   32.572742] clocksource: Switched to clocksource tick
[   33.063464] kworker/u2:1 (210) used greatest stack depth: 7592 bytes left
[   33.253628] NET: Registered protocol family 2
[   33.259784] TCP established hash table entries: 4096 (order: 2, 32768 bytes)
[   33.260149] TCP bind hash table entries: 4096 (order: 5, 262144 bytes)
[   33.263629] TCP: Hash tables configured (established 4096 bind 4096)
[   33.264986] UDP hash table entries: 256 (order: 2, 40960 bytes)
[   33.265639] UDP-Lite hash table entries: 256 (order: 2, 40960 bytes)
[   33.268770] NET: Registered protocol family 1
[   33.269433] PCI: CLS 64 bytes, default 64
[   33.271600] power: Control reg at 1fff1724000
[   33.296810] futex hash table entries: 256 (order: 1, 20480 bytes)
[   33.297321] Initialise system trusted keyring
[   33.298478] ====[ backtrace testing ]===========
[   33.298556] Testing a backtrace from process context.
[   33.298622] The following trace is a kernel self test and not a bug!
[   33.298712] CPU: 0 PID: 1 Comm: swapper Not tainted 4.1.0-12127-g4da3064 #19
[   33.298793] Call Trace:
[   33.298872]  [00000000004d2870] backtrace_regression_test+0x30/0x100
[   33.298975]  [0000000000426e2c] do_one_initcall+0xec/0x1e0
[   33.299077]  [0000000000b58b60] kernel_init_freeable+0x114/0x1c4
[   33.299187]  [000000000091b28c] kernel_init+0xc/0x100
[   33.299291]  [0000000000405fe4] ret_from_fork+0x1c/0x2c
[   33.299372]  [0000000000000000]           (null)
[   33.299440] Testing a backtrace from irq context.
[   33.299506] The following trace is a kernel self test and not a bug!
[   33.302829] CPU: 0 PID: 10 Comm: kworker/u2:1 Not tainted 4.1.0-12127-g4da3064 #19
[   33.302972] Workqueue: khelper __call_usermodehelper
[   33.303066] Call Trace:
[   33.303159]  [00000000004d280c] backtrace_test_irq_callback+0xc/0x40
[   33.303266]  [0000000000460118] tasklet_action+0x78/0xe0
[   33.303358]  [000000000045f378] __do_softirq+0x278/0x680
[   33.303459]  [000000000042be28] do_softirq_own_stack+0x28/0x40
[   33.303554]  [000000000045fa6c] irq_exit+0x4c/0xc0
[   33.303658]  [00000000009289d0] timer_interrupt+0x70/0xa0
[   33.303751]  [0000000000426b34] sys_call_table+0x5b8/0x744
[   33.303858]  [000000000049592c] debug_check_no_locks_freed+0x14c/0x180
[   33.303963]  [000000000049c290] __raw_spin_lock_init+0x10/0x60
[   33.304058]  [0000000000490324] __mutex_init+0x24/0x60
[   33.304161]  [000000000051e030] perf_event_init_task+0x30/0x2e0
[   33.304258]  [00000000004590ec] copy_process.isra.47+0x50c/0x1580
[   33.304351]  [000000000045a28c] _do_fork+0x6c/0x7c0
[   33.304439]  [000000000045aa48] kernel_thread+0x28/0x40
[   33.304535]  [000000000047171c] __call_usermodehelper+0x3c/0x80
[   33.304631]  [000000000047639c] process_one_work+0x3dc/0x800
[   33.317115] Testing a saved backtrace.
[   33.317213] The following trace is a kernel self test and not a bug!
[   33.317291]  [<00000000004d290c>] backtrace_regression_test+0xcc/0x100
[   33.317440]  [<0000000000426e2c>] do_one_initcall+0xec/0x1e0
[   33.317553]  [<0000000000b58b60>] kernel_init_freeable+0x114/0x1c4
[   33.317672]  [<000000000091b28c>] kernel_init+0xc/0x100
[   33.317788]  [<0000000000405fe4>] ret_from_fork+0x1c/0x2c
[   33.317912]  [<          (null)>]           (null)
[   33.318001] ====[ end of backtrace testing ]====
[   33.318238] audit: initializing netlink subsys (disabled)
[   33.319378] audit: type=2000 audit(5.640:1): initialized
[   33.334435] HugeTLB registered 8 MB page size, pre-allocated 0 pages
[   33.348288] Key type big_key registered
[   33.385207] io scheduler noop registered
[   33.385647] io scheduler cfq registered (default)
[   33.385768] start plist test
[   33.405224] end plist test
[   33.417168] test_string_helpers: Running tests...
[   33.425061] Running rhashtable test nelem=8, max_size=65536, shrinking=0
[   33.425154] Test 00:
[   33.534470]   Adding 50000 keys
[   34.743553] Info: encountered resize
[   34.743698] Info: encountered resize
[   34.743838] Info: encountered resize
[   34.744057] Info: encountered resize
[   34.744430] Info: encountered resize
[   34.745139] Info: encountered resize
[   34.746441] Info: encountered resize
[   34.749055] Info: encountered resize
[   34.754469] Info: encountered resize
[   34.764836] Info: encountered resize
[   34.785696] Info: encountered resize
[   34.827448] Info: encountered resize
[   34.896936]   Traversal complete: counted=49993, nelems=50000, entries=50000, table-jumps=12
[   34.897056] Test failed: Total count mismatch ^^^
[   37.899226] Info: encountered resize
[   37.899388] Info: encountered resize
[   37.899527] Info: encountered resize
[   37.899739] Info: encountered resize
[   37.900111] Info: encountered resize
[   37.900786] Info: encountered resize
[   37.902245] Info: encountered resize
[   37.904816] Info: encountered resize
[   37.910126] Info: encountered resize
[   37.920624] Info: encountered resize
[   37.941462] Info: encountered resize
[   37.983086] Info: encountered resize
[   38.051598]   Traversal complete: counted=49993, nelems=50000, entries=50000, table-jumps=12
[   38.051720] Test failed: Total count mismatch ^^^
[   38.051765]   Deleting 50000 keys
[   43.854160]   Duration of test: 10321152039 ns
[   43.854721] Test 01:
[   43.963966]   Adding 50000 keys
[   45.186303] Info: encountered resize
[   45.186453] Info: encountered resize
[   45.186592] Info: encountered resize
[   45.186813] Info: encountered resize
[   45.187340] Info: encountered resize
[   45.188042] Info: encountered resize
[   45.189346] Info: encountered resize
[   45.192140] Info: encountered resize
[   45.197298] Info: encountered resize
[   45.207569] Info: encountered resize
[   45.228530] Info: encountered resize
[   45.270347] Info: encountered resize
[   45.339753]   Traversal complete: counted=49991, nelems=50000, entries=50000, table-jumps=12
[   45.339875] Test failed: Total count mismatch ^^^
[   48.390556] Info: encountered resize
[   48.390721] Info: encountered resize
[   48.390861] Info: encountered resize
[   48.391076] Info: encountered resize
[   48.391599] Info: encountered resize
[   48.392297] Info: encountered resize
[   48.393619] Info: encountered resize
[   48.396218] Info: encountered resize
[   48.401554] Info: encountered resize
[   48.411775] Info: encountered resize
[   48.433176] Info: encountered resize
[   48.475163] Info: encountered resize
[   48.544405]   Traversal complete: counted=49991, nelems=50000, entries=50000, table-jumps=12
[   48.544525] Test failed: Total count mismatch ^^^
[   48.544568]   Deleting 50000 keys
[   54.399553]   Duration of test: 10437068986 ns
[   54.399787] Test 02:
[   54.508934]   Adding 50000 keys
[   55.720094] Info: encountered resize
[   55.720241] Info: encountered resize
[   55.720380] Info: encountered resize
[   55.720600] Info: encountered resize
[   55.720974] Info: encountered resize
[   55.721670] Info: encountered resize
[   55.722982] Info: encountered resize
[   55.725613] Info: encountered resize
[   55.730891] Info: encountered resize
[   55.741233] Info: encountered resize
[   55.762081] Info: encountered resize
[   55.804253] Info: encountered resize
[   55.873125]   Traversal complete: counted=49995, nelems=50000, entries=50000, table-jumps=12
[   55.873245] Test failed: Total count mismatch ^^^
[   58.458765] NMI watchdog: BUG: soft lockup - CPU#0 stuck for 22s! [swapper:1]
[   58.458912] Modules linked in:
[   58.459004] irq event stamp: 5557672
[   58.459078] hardirqs last  enabled at (5557671): [<0000000000404b1c>] rtrap_xcall+0x18/0x20
[   58.459254] hardirqs last disabled at (5557672): [<0000000000426b28>] sys_call_table+0x5ac/0x744
[   58.459439] softirqs last  enabled at (5557670): [<000000000045f5fc>] __do_softirq+0x4fc/0x680
[   58.459626] softirqs last disabled at (5557663): [<000000000042be28>] do_softirq_own_stack+0x28/0x40
[   58.459836] CPU: 0 PID: 1 Comm: swapper Not tainted 4.1.0-12127-g4da3064 #19
[   58.459929] task: fffff8001f09ef60 ti: fffff8001f0fc000 task.ti: fffff8001f0fc000
[   58.460025] TSTATE: 0000009980001607 TPC: 0000000000b7a514 TNPC: 0000000000b7a518 Y: 00000000    Not tainted
[   58.460192] TPC: <test_rht_lookup.constprop.10+0x188/0x4ac>
[   58.460295] g0: 0000000000000000 g1: 0000000000000200 g2: 540a160f2557bdc1 g3: 63067b5c008c4807
[   58.460439] g4: fffff8001f09ef60 g5: 0000000000000000 g6: fffff8001f0fc000 g7: 27d5475238ec8000
[   58.460582] o0: 0000000002f98f0e o1: 0000000000000010 o2: 60505515260d6422 o3: 0000000000000002
[   58.460725] o4: 5ee1b4a55ec87d18 o5: 0000000000000000 sp: fffff8001f0ff1a1 ret_pc: 0000000000b7a504
[   58.460881] RPC: <test_rht_lookup.constprop.10+0x178/0x4ac>
[   58.460984] l0: 0000000000000053 l1: fffff8001f0ffa6c l2: 0000000000b46c00 l3: 0000000000b7a3e4
[   58.461100] l4: 0000000000aef000 l5: 0000000000b46c00 l6: 0000000000aef058 l7: 0000000000000001
[   58.461213] i0: 0000000000000000 i1: fffff8001e3e2000 i2: 0000000000000001 i3: 0000000000015060
[   58.461328] i4: 00000000018d1320 i5: 00000000300000a7 i6: fffff8001f0ff281 i7: 0000000000b7afdc
[   58.461449] I7: <test_rhashtable.constprop.8+0x7a4/0x1100>
[   58.461527] Call Trace:
[   58.461604]  [0000000000b7afdc] test_rhashtable.constprop.8+0x7a4/0x1100
[   58.461708]  [0000000000b7ba0c] test_rht_init+0xd4/0x148
[   58.461804]  [0000000000426e2c] do_one_initcall+0xec/0x1e0
[   58.461910]  [0000000000b58b60] kernel_init_freeable+0x114/0x1c4
[   58.462019]  [000000000091b28c] kernel_init+0xc/0x100
[   58.462122]  [0000000000405fe4] ret_from_fork+0x1c/0x2c
[   58.462206]  [0000000000000000]           (null)
[   58.904394] Info: encountered resize
[   58.904531] Info: encountered resize
[   58.904667] Info: encountered resize
[   58.904881] Info: encountered resize
[   58.905249] Info: encountered resize
[   58.905925] Info: encountered resize
[   58.907207] Info: encountered resize
[   58.909992] Info: encountered resize
[   58.915245] Info: encountered resize
[   58.925539] Info: encountered resize
[   58.946221] Info: encountered resize
[   58.988001] Info: encountered resize
[   59.057287]   Traversal complete: counted=49995, nelems=50000, entries=50000, table-jumps=12
[   59.057408] Test failed: Total count mismatch ^^^
[   59.057452]   Deleting 50000 keys
[   64.868833]   Duration of test: 10361368028 ns
[   64.869070] Test 03:
[   64.978442]   Adding 50000 keys
[   66.192720] Info: encountered resize
[   66.192870] Info: encountered resize
[   66.193010] Info: encountered resize
[   66.193231] Info: encountered resize
[   66.193639] Info: encountered resize
[   66.194328] Info: encountered resize
[   66.195663] Info: encountered resize
[   66.198450] Info: encountered resize
[   66.203650] Info: encountered resize
[   66.214122] Info: encountered resize
[   66.234884] Info: encountered resize
[   66.276586] Info: encountered resize
[   66.345411]   Traversal complete: counted=49998, nelems=50000, entries=50000, table-jumps=12
[   66.345532] Test failed: Total count mismatch ^^^
[   69.344815] Info: encountered resize
[   69.344978] Info: encountered resize
[   69.345117] Info: encountered resize
[   69.345330] Info: encountered resize
[   69.345732] Info: encountered resize
[   69.346396] Info: encountered resize
[   69.347897] Info: encountered resize
[   69.350507] Info: encountered resize
[   69.355796] Info: encountered resize
[   69.366153] Info: encountered resize
[   69.387253] Info: encountered resize
[   69.429246] Info: encountered resize
[   69.498295]   Traversal complete: counted=49998, nelems=50000, entries=50000, table-jumps=12
[   69.498415] Test failed: Total count mismatch ^^^
[   69.498459]   Deleting 50000 keys
[   75.296599]   Duration of test: 10319626444 ns
[   75.296839] Average test time: 10359803874
[   75.297375] rbtree testing -> 36602 cycles
[   86.173845] augmented rbtree testing -> 52609 cycles
[  101.793151] PCI: Enabling device: (0000:01:02.0), cmd 82
[  101.793306] atyfb: 3D RAGE PRO (Mach64 GP, PQFP, PCI) [0x4750 rev 0x7c]
[  101.793454] atyfb: 4M SGRAM (1:1), 14.31818 MHz XTAL, 230 MHz PLL, 100 Mhz MCLK, 100 MHz XCLK
[  101.857143] Console: switching to colour frame buffer device 80x30
[  101.867747] atyfb: fb0: ATY Mach64 frame buffer device on PCI
[  101.895537] f0061c64: ttyS0 at MMIO 0x1fff1400000 (irq = 5, base_baud = 115200) is a SAB82532 V3.2
[  101.901211] Console: ttyS0 (SAB82532)
[  122.044083] console [ttyS0] enabled
[  122.082621] f0061c64: ttyS1 at MMIO 0x1fff1400040 (irq = 5, base_baud = 115200) is a SAB82532 V3.2
[  122.536596] Floppy drive(s): fd0 is 1.44M
[  122.730651] loop: module loaded
[  122.813302] scsi host0: pata_cmd64x
[  122.853562] scsi host1: pata_cmd64x
[  122.886354] ata1: PATA max MWDMA2 cmd 0x1fe02c00000 ctl 0x1fe02c00008 bmdma 0x1fe02c00020 irq 14
[  122.983115] ata2: PATA max MWDMA2 cmd 0x1fe02c00010 ctl 0x1fe02c00018 bmdma 0x1fe02c00028 irq 14
[  123.085651] pata_cmd64x: active 10 recovery 10 setup 3.
[  123.085780] pata_cmd64x: active 10 recovery 10 setup 3.
[  123.100447] FDC 0 is a National Semiconductor PC87306
[  123.152055] mousedev: PS/2 mouse device common for all mice
[  123.233973] rtc-m48t59 rtc-m48t59.0: rtc core: registered m48t59 as rtc0
[  123.307724] NET: Registered protocol family 10
[  123.372471] ata1.00: ATA-6: ST3120026A, 3.06, max UDMA/100
[  123.425994] ata1.00: 234441648 sectors, multi 0: LBA48 
[  123.476265] pata_cmd64x: active 3 recovery 1 setup 1.
[  123.476364] pata_cmd64x: active 3 recovery 1 setup 1.
[  123.506017] NET: Registered protocol family 17
[  123.553092] ata1.00: configured for MWDMA2
[  123.596059] scsi 0:0:0:0: Direct-Access     ATA      ST3120026A       3.06 PQ: 0 ANSI: 5
[  123.697127] sd 0:0:0:0: [sda] 234441648 512-byte logical blocks: (120 GB/111 GiB)
[  123.775936] sd 0:0:0:0: [sda] Write Protect is off
[  123.820713] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[  123.821393] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  123.929672] pata_cmd64x: active 10 recovery 10 setup 3.
[  123.929767] pata_cmd64x: active 10 recovery 10 setup 3.
[  123.950540] Loading compiled-in X.509 certificates
[  123.995852] registered taskstats version 1
[  124.032372] Running tests on trace events:
[  124.068546] Testing event sys_exit: 
[  124.095483] ata2.00: ATAPI: CRD-8322B, 1.06, max MWDMA2
[  124.150209] pata_cmd64x: active 3 recovery 1 setup 1.
[  124.150324] pata_cmd64x: active 3 recovery 1 setup 1.
[  124.172415] OK
[  124.179558] Testing event sys_enter: 
[  124.207232] ata2.00: configured for MWDMA2
[  124.249814]  sda: sda1 sda2 sda3
[  124.302409] sd 0:0:0:0: [sda] Attached SCSI disk
[  124.349119] OK
[  124.355672] Testing event task_rename: 
[  124.391867] scsi 1:0:0:0: CD-ROM               LG    CD-ROM CRD-8322B 1.06 PQ: 0 ANSI: 5
[  124.504045] OK
[  124.510839] Testing event task_newtask: 
[  124.548139] sr 1:0:0:0: [sr0] scsi3-mmc drive: 32x/32x cd/rw xa/form2 cdda tray
[  124.627257] cdrom: Uniform CD-ROM driver Revision: 3.20
[  124.693279] sr 1:0:0:0: Attached scsi CD-ROM sr0
[  124.700134] OK
[  124.706754] Testing event softirq_raise: OK
[  124.766631] Testing event softirq_exit: OK
[  124.816036] Testing event softirq_entry: OK
[  124.866266] Testing event irq_handler_exit: OK
[  124.926053] Testing event irq_handler_entry: OK
[  124.985587] Testing event signal_deliver: OK
[  125.035714] Testing event signal_generate: OK
[  125.095624] Testing event workqueue_execute_end: OK
[  125.155589] Testing event workqueue_execute_start: OK
[  125.215307] Testing event workqueue_activate_work: OK
[  125.275570] Testing event workqueue_queue_work: OK
[  125.335372] Testing event sched_wake_idle_without_ipi: OK
[  125.405425] Testing event sched_swap_numa: OK
[  125.464883] Testing event sched_stick_numa: OK
[  125.525343] Testing event sched_move_numa: OK
[  125.585084] Testing event sched_process_hang: OK
[  125.644902] Testing event sched_pi_setprio: OK
[  125.705136] Testing event sched_stat_runtime: OK
[  125.765101] Testing event sched_stat_blocked: OK
[  125.824588] Testing event sched_stat_iowait: OK
[  125.884739] Testing event sched_stat_sleep: OK
[  125.944363] Testing event sched_stat_wait: OK
[  125.994494] Testing event sched_process_exec: OK
[  126.054022] Testing event sched_process_fork: OK
[  126.114205] Testing event sched_process_wait: OK
[  126.174000] Testing event sched_wait_task: OK
[  126.224121] Testing event sched_process_exit: OK
[  126.283918] Testing event sched_process_free: OK
[  126.344072] Testing event sched_migrate_task: OK
[  126.404072] Testing event sched_switch: OK
[  126.453933] Testing event sched_wakeup_new: OK
[  126.513825] Testing event sched_wakeup: OK
[  126.564078] Testing event sched_kthread_stop_ret: OK
[  126.623988] Testing event sched_kthread_stop: OK
[  126.683963] Testing event lock_release: OK
[  126.735113] Testing event lock_acquire: OK
[  126.784514] Testing event console: OK
[  126.833954] Testing event rcu_utilization: OK
[  126.883650] Testing event tick_stop: OK
[  126.933967] Testing event itimer_expire: OK
[  126.983643] Testing event itimer_state: OK
[  127.033929] Testing event hrtimer_cancel: OK
[  127.083614] Testing event hrtimer_expire_exit: OK
[  127.143940] Testing event hrtimer_expire_entry: OK
[  127.203917] Testing event hrtimer_start: OK
[  127.253923] Testing event hrtimer_init: OK
[  127.303597] Testing event timer_cancel: OK
[  127.353885] Testing event timer_expire_exit: OK
[  127.413905] Testing event timer_expire_entry: OK
[  127.473904] Testing event timer_start: OK
[  127.523889] Testing event timer_init: OK
[  127.573540] Testing event module_request: OK
[  127.623889] Testing event module_put: OK
[  127.673867] Testing event module_get: OK
[  127.723503] Testing event module_free: OK
[  127.773796] Testing event module_load: OK
[  127.823461] Testing event ftrace_test_filter: OK
[  127.883755] Testing event dev_pm_qos_remove_request: OK
[  127.943491] Testing event dev_pm_qos_update_request: OK
[  128.003744] Testing event dev_pm_qos_add_request: OK
[  128.063661] Testing event pm_qos_update_flags: OK
[  128.123893] Testing event pm_qos_update_target: OK
[  128.183535] Testing event pm_qos_update_request_timeout: OK
[  128.253841] Testing event pm_qos_remove_request: OK
[  128.313726] Testing event pm_qos_update_request: OK
[  128.373487] Testing event pm_qos_add_request: OK
[  128.433798] Testing event power_domain_target: OK
[  128.493690] Testing event clock_set_rate: OK
[  128.543831] Testing event clock_disable: OK
[  128.593494] Testing event clock_enable: OK
[  128.643804] Testing event wakeup_source_deactivate: OK
[  128.704039] Testing event wakeup_source_activate: OK
[  128.763815] Testing event suspend_resume: OK
[  128.813745] Testing event device_pm_callback_end: OK
[  128.873868] Testing event device_pm_callback_start: OK
[  128.933853] Testing event cpu_frequency: OK
[  128.983552] Testing event pstate_sample: OK
[  129.033854] Testing event cpu_idle: OK
[  129.083573] Testing event rpm_return_int: OK
[  129.134016] Testing event rpm_idle: OK
[  129.183613] Testing event rpm_resume: OK
[  129.233881] Testing event rpm_suspend: OK
[  129.283500] Testing event mm_filemap_add_to_page_cache: OK
[  129.353870] Testing event mm_filemap_delete_from_page_cache: OK
[  129.423569] Testing event oom_score_adj_update: OK
[  129.484001] Testing event mm_lru_activate: OK
[  129.533814] Testing event mm_lru_insertion: OK
[  129.593789] Testing event mm_vmscan_lru_shrink_inactive: OK
[  129.663697] Testing event mm_vmscan_writepage: OK
[  129.724470] Testing event mm_vmscan_memcg_isolate: OK
[  129.783920] Testing event mm_vmscan_lru_isolate: OK
[  129.843686] Testing event mm_shrink_slab_end: OK
[  129.903982] Testing event mm_shrink_slab_start: OK
[  129.963848] Testing event mm_vmscan_memcg_softlimit_reclaim_end: OK
[  130.044022] Testing event mm_vmscan_memcg_reclaim_end: OK
[  130.113684] Testing event mm_vmscan_direct_reclaim_end: OK
[  130.184001] Testing event mm_vmscan_memcg_softlimit_reclaim_begin: OK
[  130.263690] Testing event mm_vmscan_memcg_reclaim_begin: OK
[  130.333990] Testing event mm_vmscan_direct_reclaim_begin: OK
[  130.404015] Testing event mm_vmscan_wakeup_kswapd: OK
[  130.463679] Testing event mm_vmscan_kswapd_wake: OK
[  130.523994] Testing event mm_vmscan_kswapd_sleep: OK
[  130.583850] Testing event mm_page_alloc_extfrag: OK
[  130.643951] Testing event mm_page_pcpu_drain: OK
[  130.704471] Testing event mm_page_alloc_zone_locked: OK
[  130.773647] Testing event mm_page_alloc: OK
[  130.823963] Testing event mm_page_free_batched: OK
[  130.883696] Testing event mm_page_free: OK
[  130.933951] Testing event kmem_cache_free: OK
[  130.983578] Testing event kfree: OK
[  131.023869] Testing event kmem_cache_alloc_node: OK
[  131.083568] Testing event kmalloc_node: OK
[  131.133849] Testing event kmem_cache_alloc: OK
[  131.193512] Testing event kmalloc: OK
[  131.243811] Testing event mm_compaction_defer_reset: OK
[  131.303522] Testing event mm_compaction_defer_compaction: OK
[  131.373795] Testing event mm_compaction_deferred: OK
[  131.433693] Testing event mm_compaction_suitable: OK
[  131.493382] Testing event mm_compaction_finished: OK
[  131.553639] Testing event mm_compaction_try_to_compact_pages: OK
[  131.623315] Testing event mm_compaction_end: OK
[  131.683590] Testing event mm_compaction_begin: OK
[  131.743213] Testing event mm_compaction_migratepages: OK
[  131.813700] Testing event mm_compaction_isolate_freepages: OK
[  131.883154] Testing event mm_compaction_isolate_migratepages: OK
[  131.953448] Testing event mm_numa_migrate_ratelimit: OK
[  132.013391] Testing event mm_migrate_pages: OK
[  132.073300] Testing event writeback_dirty_inode_enqueue: OK
[  132.143217] Testing event writeback_lazytime_iput: OK
[  132.203525] Testing event writeback_lazytime: OK
[  132.263493] Testing event writeback_single_inode: OK
[  132.323268] Testing event writeback_single_inode_start: OK
[  132.393456] Testing event writeback_wait_iff_congested: OK
[  132.463433] Testing event writeback_congestion_wait: OK
[  132.523223] Testing event writeback_sb_inodes_requeue: OK
[  132.593507] Testing event balance_dirty_pages: OK
[  132.653201] Testing event bdi_dirty_ratelimit: OK
[  132.714646] Testing event global_dirty_state: OK
[  132.773183] Testing event writeback_queue_io: OK
[  132.833449] Testing event wbc_writepage: OK
[  132.883358] Testing event writeback_bdi_register: OK
[  132.943159] Testing event writeback_wake_background: OK
[  133.003490] Testing event writeback_nowork: OK
[  133.063397] Testing event writeback_pages_written: OK
[  133.123473] Testing event writeback_wait: OK
[  133.173132] Testing event writeback_written: OK
[  133.233441] Testing event writeback_start: OK
[  133.283411] Testing event writeback_exec: OK
[  133.333051] Testing event writeback_queue: OK
[  133.383335] Testing event writeback_write_inode: OK
[  133.442956] Testing event writeback_write_inode_start: OK
[  133.513207] Testing event writeback_dirty_inode: OK
[  133.572844] Testing event writeback_dirty_inode_start: OK
[  133.643101] Testing event writeback_mark_inode_dirty: OK
[  133.713114] Testing event writeback_dirty_page: OK
[  133.772915] Testing event time_out_leases: OK
[  133.823143] Testing event generic_delete_lease: OK
[  133.882947] Testing event generic_add_lease: OK
[  133.943236] Testing event break_lease_unblock: OK
[  134.002919] Testing event break_lease_block: OK
[  134.063163] Testing event break_lease_noblock: OK
[  134.122707] Testing event ext4_es_shrink: OK
[  134.173122] Testing event ext4_insert_range: OK
[  134.232797] Testing event ext4_collapse_range: OK
[  134.293082] Testing event ext4_es_shrink_scan_exit: OK
[  134.352957] Testing event ext4_es_shrink_scan_enter: OK
[  134.412700] Testing event ext4_es_shrink_count: OK
[  134.472993] Testing event ext4_es_lookup_extent_exit: OK
[  134.542677] Testing event ext4_es_lookup_extent_enter: OK
[  134.612945] Testing event ext4_es_find_delayed_extent_range_exit: OK
[  134.692679] Testing event ext4_es_find_delayed_extent_range_enter: OK
[  134.772963] Testing event ext4_es_remove_extent: OK
[  134.832714] Testing event ext4_es_cache_extent: OK
[  134.893027] Testing event ext4_es_insert_extent: OK
[  134.952904] Testing event ext4_ext_remove_space_done: OK
[  135.023036] Testing event ext4_ext_remove_space: OK
[  135.082682] Testing event ext4_ext_rm_idx: OK
[  135.133001] Testing event ext4_ext_rm_leaf: OK
[  135.192948] Testing event ext4_remove_blocks: OK
[  135.252711] Testing event ext4_ext_show_extent: OK
[  135.312998] Testing event ext4_get_reserved_cluster_alloc: OK
[  135.382890] Testing event ext4_find_delalloc_range: OK
[  135.442697] Testing event ext4_ext_in_cache: OK
[  135.502894] Testing event ext4_ext_put_in_cache: OK
[  135.562791] Testing event ext4_get_implied_cluster_alloc_exit: OK
[  135.642842] Testing event ext4_ext_handle_unwritten_extents: OK
[  135.712746] Testing event ext4_trim_all_free: OK
[  135.773089] Testing event ext4_trim_extent: OK
[  135.832746] Testing event ext4_journal_start_reserved: OK
[  135.903056] Testing event ext4_journal_start: OK
[  135.962944] Testing event ext4_load_inode: OK
[  136.013052] Testing event ext4_ext_load_extent: OK
[  136.072718] Testing event ext4_ind_map_blocks_exit: OK
[  136.133062] Testing event ext4_ext_map_blocks_exit: OK
[  136.192961] Testing event ext4_ind_map_blocks_enter: OK
[  136.252646] Testing event ext4_ext_map_blocks_enter: OK
[  136.312861] Testing event ext4_ext_convert_to_initialized_fastpath: OK
[  136.392895] Testing event ext4_ext_convert_to_initialized_enter: OK
[  136.472550] Testing event ext4_truncate_exit: OK
[  136.532889] Testing event ext4_truncate_enter: OK
[  136.592871] Testing event ext4_unlink_exit: OK
[  136.652869] Testing event ext4_unlink_enter: OK
[  136.713482] Testing event ext4_fallocate_exit: OK
[  136.772734] Testing event ext4_zero_range: OK
[  136.822943] Testing event ext4_punch_hole: OK
[  136.872553] Testing event ext4_fallocate_enter: OK
[  136.932825] Testing event ext4_direct_IO_exit: OK
[  136.992691] Testing event ext4_direct_IO_enter: OK
[  137.052444] Testing event ext4_load_inode_bitmap: OK
[  137.113330] Testing event ext4_read_block_bitmap_load: OK
[  137.182334] Testing event ext4_mb_buddy_bitmap_load: OK
[  137.242618] Testing event ext4_mb_bitmap_load: OK
[  137.302316] Testing event ext4_da_release_space: OK
[  137.362603] Testing event ext4_da_reserve_space: OK
[  137.422565] Testing event ext4_da_update_reserve_space: OK
[  137.492246] Testing event ext4_forget: OK
[  137.542570] Testing event ext4_mballoc_free: OK
[  137.602427] Testing event ext4_mballoc_discard: OK
[  137.662547] Testing event ext4_mballoc_prealloc: OK
[  137.722215] Testing event ext4_mballoc_alloc: OK
[  137.782541] Testing event ext4_alloc_da_blocks: OK
[  137.842471] Testing event ext4_sync_fs: OK
[  137.892169] Testing event ext4_sync_file_exit: OK
[  137.952397] Testing event ext4_sync_file_enter: OK
[  138.012074] Testing event ext4_free_blocks: OK
[  138.062376] Testing event ext4_allocate_blocks: OK
[  138.122185] Testing event ext4_request_blocks: OK
[  138.182484] Testing event ext4_mb_discard_preallocations: OK
[  138.252080] Testing event ext4_discard_preallocations: OK
[  138.322539] Testing event ext4_mb_release_group_pa: OK
[  138.382227] Testing event ext4_mb_release_inode_pa: OK
[  138.442698] Testing event ext4_mb_new_group_pa: OK
[  138.502205] Testing event ext4_mb_new_inode_pa: OK
[  138.562463] Testing event ext4_discard_blocks: OK
[  138.622128] Testing event ext4_journalled_invalidatepage: OK
[  138.692438] Testing event ext4_invalidatepage: OK
[  138.752452] Testing event ext4_releasepage: OK
[  138.812213] Testing event ext4_readpage: OK
[  138.862126] Testing event ext4_writepage: OK
[  138.912393] Testing event ext4_writepages_result: OK
[  138.972025] Testing event ext4_da_write_pages_extent: OK
[  139.042348] Testing event ext4_da_write_pages: OK
[  139.102018] Testing event ext4_writepages: OK
[  139.152344] Testing event ext4_da_write_end: OK
[  139.212023] Testing event ext4_journalled_write_end: OK
[  139.272340] Testing event ext4_write_end: OK
[  139.322342] Testing event ext4_da_write_begin: OK
[  139.382029] Testing event ext4_write_begin: OK
[  139.442258] Testing event ext4_begin_ordered_truncate: OK
[  139.512051] Testing event ext4_mark_inode_dirty: OK
[  139.572373] Testing event ext4_drop_inode: OK
[  139.622142] Testing event ext4_evict_inode: OK
[  139.682191] Testing event ext4_allocate_inode: OK
[  139.742253] Testing event ext4_request_inode: OK
[  139.802010] Testing event ext4_free_inode: OK
[  139.852346] Testing event ext4_other_inode_update_time: OK
[  139.922237] Testing event jbd2_lock_buffer_stall: OK
[  139.982413] Testing event jbd2_write_superblock: OK
[  140.042089] Testing event jbd2_update_log_tail: OK
[  140.102359] Testing event jbd2_checkpoint_stats: OK
[  140.162321] Testing event jbd2_run_stats: OK
[  140.212003] Testing event jbd2_handle_stats: OK
[  140.272310] Testing event jbd2_handle_extend: OK
[  140.331977] Testing event jbd2_handle_start: OK
[  140.392269] Testing event jbd2_submit_inode_data: OK
[  140.451934] Testing event jbd2_end_commit: OK
[  140.502262] Testing event jbd2_drop_transaction: OK
[  140.562149] Testing event jbd2_commit_logging: OK
[  140.622258] Testing event jbd2_commit_flushing: OK
[  140.681893] Testing event jbd2_commit_locking: OK
[  140.742164] Testing event jbd2_start_commit: OK
[  140.802144] Testing event jbd2_checkpoint: OK
[  140.851803] Testing event block_rq_remap: OK
[  140.902086] Testing event block_bio_remap: OK
[  140.951824] Testing event block_split: OK
[  141.002012] Testing event block_unplug: OK
[  141.051780] Testing event block_plug: OK
[  141.102060] Testing event block_sleeprq: OK
[  141.151720] Testing event block_getrq: OK
[  141.202002] Testing event block_bio_queue: OK
[  141.251640] Testing event block_bio_frontmerge: OK
[  141.311884] Testing event block_bio_backmerge: OK
[  141.371540] Testing event block_bio_complete: OK
[  141.431827] Testing event block_bio_bounce: OK
[  141.481377] Testing event block_rq_issue: OK
[  141.531764] Testing event block_rq_insert: OK
[  141.581423] Testing event block_rq_complete: OK
[  141.641727] Testing event block_rq_requeue: OK
[  141.701509] Testing event block_rq_abort: OK
[  141.751360] Testing event block_dirty_buffer: OK
[  141.811855] Testing event block_touch_buffer: OK
[  141.871274] Testing event urandom_read: OK
[  141.921585] Testing event random_read: OK
[  141.971274] Testing event extract_entropy_user: OK
[  142.031610] Testing event extract_entropy: OK
[  142.081262] Testing event get_random_bytes_arch: OK
[  142.141593] Testing event get_random_bytes: OK
[  142.191243] Testing event xfer_secondary_pool: OK
[  142.251571] Testing event add_disk_randomness: OK
[  142.311367] Testing event add_input_randomness: OK
[  142.371589] Testing event debit_entropy: OK
[  142.421406] Testing event push_to_pool: OK
[  142.471724] Testing event credit_entropy_bits: OK
[  142.531437] Testing event mix_pool_bytes_nolock: OK
[  142.591765] Testing event mix_pool_bytes: OK
[  142.641430] Testing event add_device_randomness: OK
[  142.702184] Testing event scsi_eh_wakeup: OK
[  142.751475] Testing event scsi_dispatch_cmd_timeout: OK
[  142.811805] Testing event scsi_dispatch_cmd_done: OK
[  142.871472] Testing event scsi_dispatch_cmd_error: OK
[  142.931768] Testing event scsi_dispatch_cmd_start: OK
[  142.991424] Testing event ata_eh_link_autopsy_qc: OK
[  143.051763] Testing event ata_eh_link_autopsy: OK
[  143.111629] Testing event ata_qc_complete_done: OK
[  143.171743] Testing event ata_qc_complete_failed: OK
[  143.231426] Testing event ata_qc_complete_internal: OK
[  143.291695] Testing event ata_qc_issue: OK
[  143.341702] Testing event udp_fail_queue_rcv_skb: OK
[  143.401376] Testing event sock_exceed_buf_limit: OK
[  143.461720] Testing event sock_rcvqueue_full: OK
[  143.521584] Testing event napi_poll: OK
[  143.571722] Testing event netif_rx_ni_entry: OK
[  143.631385] Testing event netif_rx_entry: OK
[  143.681678] Testing event netif_receive_skb_entry: OK
[  143.741661] Testing event napi_gro_receive_entry: OK
[  143.801444] Testing event napi_gro_frags_entry: OK
[  143.861748] Testing event netif_rx: OK
[  143.911420] Testing event netif_receive_skb: OK
[  143.971690] Testing event net_dev_queue: OK
[  144.021384] Testing event net_dev_xmit: OK
[  144.071645] Testing event net_dev_start_xmit: OK
[  144.131292] Testing event skb_copy_datagram_iovec: OK
[  144.191593] Testing event consume_skb: OK
[  144.241310] Testing event kfree_skb: OK
[  144.291629] Running tests on trace event systems:
[  144.333101] Testing event system skb: OK
[  144.383198] Testing event system net: OK
[  144.432859] Testing event system napi: OK
[  144.481972] Testing event system sock: OK
[  144.532056] Testing event system udp: OK
[  144.581926] Testing event system libata: OK
[  144.632299] Testing event system scsi: OK
[  144.682240] Testing event system random: OK
[  144.733123] Testing event system block: OK
[  144.783290] Testing event system jbd2: OK
[  144.832928] Testing event system ext4: OK
[  144.899949] Testing event system filelock: OK
[  144.961806] Testing event system writeback: OK
[  145.023858] Testing event system migrate: OK
[  145.081616] Testing event system compaction: OK
[  145.142319] Testing event system kmem: OK
[  145.192383] Testing event system vmscan: OK
[  145.242571] Testing event system pagemap: OK
[  145.301073] Testing event system oom: OK
[  145.351489] Testing event system filemap: OK
[  145.401472] Testing event system rpm: OK
[  145.451729] Testing event system power: OK
[  145.503122] Testing event system test: OK
[  145.551323] Testing event system module: OK
[  145.601550] Testing event system timer: OK
[  145.652303] Testing event system rcu: OK
[  145.701158] Testing event system printk: OK
[  145.751157] Testing event system lock: OK
[  145.803141] Testing event system sched: OK
[  145.852929] Testing event system workqueue: OK
[  145.911255] Testing event system signal: OK
[  145.961357] Testing event system irq: OK
[  146.011557] Testing event system task: OK
[  146.061225] Testing event system raw_syscalls: OK
[  146.121336] Running tests on all trace events:
[  146.159258] Testing all events: OK
[  146.290662] Running tests again, along with the function tracer
[  146.359790] Running tests on trace events:
[  146.407102] Testing event sys_exit: OK
[  146.548512] Testing event sys_enter: OK
[  146.618985] Testing event task_rename: OK
[  146.689194] Testing event task_newtask: OK
[  146.768970] Testing event softirq_raise: OK
[  146.847902] Testing event softirq_exit: OK
[  146.919231] Testing event softirq_entry: OK
[  146.997649] Testing event irq_handler_exit: OK
[  147.078668] Testing event irq_handler_entry: OK
[  147.159013] Testing event signal_deliver: OK
[  147.238969] Testing event signal_generate: OK
[  147.318677] Testing event workqueue_execute_end: OK
[  147.399251] Testing event workqueue_execute_start: OK
[  147.489275] Testing event workqueue_activate_work: OK
[  147.579320] Testing event workqueue_queue_work: OK
[  147.659191] Testing event sched_wake_idle_without_ipi: OK
[  147.748595] Testing event sched_swap_numa: OK
[  147.829382] Testing event sched_stick_numa: OK
[  147.909185] Testing event sched_move_numa: OK
[  147.988672] Testing event sched_process_hang: OK
[  148.069636] Testing event sched_pi_setprio: OK
[  148.148720] Testing event sched_stat_runtime: OK
[  148.228772] Testing event sched_stat_blocked: OK
[  148.308448] Testing event sched_stat_iowait: OK
[  148.388167] Testing event sched_stat_sleep: OK
[  148.468592] Testing event sched_stat_wait: OK
[  148.548244] Testing event sched_process_exec: OK
[  148.628147] Testing event sched_process_fork: OK
[  148.708467] Testing event sched_process_wait: OK
[  148.788248] Testing event sched_wait_task: OK
[  148.868209] Testing event sched_process_exit: OK
[  148.948199] Testing event sched_process_free: OK
[  149.027982] Testing event sched_migrate_task: OK
[  149.108110] Testing event sched_switch: OK
[  149.177793] Testing event sched_wakeup_new: OK
[  149.257687] Testing event sched_wakeup: OK
[  149.337097] Testing event sched_kthread_stop_ret: OK
[  149.417842] Testing event sched_kthread_stop: OK
[  149.498158] Testing event lock_release: OK
[  149.578009] Testing event lock_acquire: OK
[  149.648390] Testing event console: OK
[  149.718279] Testing event rcu_utilization: OK
[  149.797640] Testing event tick_stop: OK
[  149.866876] Testing event itimer_expire: OK
[  149.947057] Testing event itimer_state: OK
[  150.017601] Testing event hrtimer_cancel: OK
[  150.096984] Testing event hrtimer_expire_exit: OK
[  150.177280] Testing event hrtimer_expire_entry: OK
[  150.257785] Testing event hrtimer_start: OK
[  150.327472] Testing event hrtimer_init: OK
[  150.397741] Testing event timer_cancel: OK
[  150.468331] Testing event timer_expire_exit: OK
[  150.547674] Testing event timer_expire_entry: OK
[  150.627905] Testing event timer_start: OK
[  150.698495] Testing event timer_init: OK
[  150.777780] Testing event module_request: OK
[  150.856667] Testing event module_put: OK
[  150.927668] Testing event module_get: OK
[  150.996940] Testing event module_free: OK
[  151.067055] Testing event module_load: OK
[  151.137515] Testing event ftrace_test_filter: OK
[  151.217399] Testing event dev_pm_qos_remove_request: OK
[  151.308056] Testing event dev_pm_qos_update_request: OK
[  151.398037] Testing event dev_pm_qos_add_request: OK
[  151.487110] Testing event pm_qos_update_flags: OK
[  151.567860] Testing event pm_qos_update_target: OK
[  151.647736] Testing event pm_qos_update_request_timeout: OK
[  151.738168] Testing event pm_qos_remove_request: OK
[  151.817948] Testing event pm_qos_update_request: OK
[  151.897757] Testing event pm_qos_add_request: OK
[  151.977361] Testing event power_domain_target: OK
[  152.057834] Testing event clock_set_rate: OK
[  152.137719] Testing event clock_disable: OK
[  152.217250] Testing event clock_enable: OK
[  152.287874] Testing event wakeup_source_deactivate: OK
[  152.378073] Testing event wakeup_source_activate: OK
[  152.467201] Testing event suspend_resume: OK
[  152.548925] Testing event device_pm_callback_end: OK
[  152.638357] Testing event device_pm_callback_start: OK
[  152.730765] Testing event cpu_frequency: OK
[  152.807757] Testing event pstate_sample: OK
[  152.887150] Testing event cpu_idle: OK
[  152.958421] Testing event rpm_return_int: OK
[  153.038639] Testing event rpm_idle: OK
[  153.107812] Testing event rpm_resume: OK
[  153.179056] Testing event rpm_suspend: OK
[  153.247842] Testing event mm_filemap_add_to_page_cache: OK
[  153.337849] Testing event mm_filemap_delete_from_page_cache: OK
[  153.438170] Testing event oom_score_adj_update: OK
[  153.518063] Testing event mm_lru_activate: OK
[  153.597926] Testing event mm_lru_insertion: OK
[  153.678239] Testing event mm_vmscan_lru_shrink_inactive: OK
[  153.768111] Testing event mm_vmscan_writepage: OK
[  153.847666] Testing event mm_vmscan_memcg_isolate: OK
[  153.936945] Testing event mm_vmscan_lru_isolate: OK
[  154.018710] Testing event mm_shrink_slab_end: OK
[  154.098016] Testing event mm_shrink_slab_start: OK
[  154.177937] Testing event mm_vmscan_memcg_softlimit_reclaim_end: OK
[  154.278116] Testing event mm_vmscan_memcg_reclaim_end: OK
[  154.368142] Testing event mm_vmscan_direct_reclaim_end: OK
[  154.459284] Testing event mm_vmscan_memcg_softlimit_reclaim_begin: OK
[  154.557476] Testing event mm_vmscan_memcg_reclaim_begin: OK
[  154.648668] Testing event mm_vmscan_direct_reclaim_begin: OK
[  154.748618] Testing event mm_vmscan_wakeup_kswapd: OK
[  154.837835] Testing event mm_vmscan_kswapd_wake: OK
[  154.927558] Testing event mm_vmscan_kswapd_sleep: OK
[  155.017630] Testing event mm_page_alloc_extfrag: OK
[  155.099133] Testing event mm_page_pcpu_drain: OK
[  155.178217] Testing event mm_page_alloc_zone_locked: OK
[  155.268217] Testing event mm_page_alloc: OK
[  155.348240] Testing event mm_page_free_batched: OK
[  155.428165] Testing event mm_page_free: OK
[  155.507140] Testing event kmem_cache_free: OK
[  155.588102] Testing event kfree: OK
[  155.658036] Testing event kmem_cache_alloc_node: OK
[  155.737884] Testing event kmalloc_node: OK
[  155.807612] Testing event kmem_cache_alloc: OK
[  155.887891] Testing event kmalloc: OK
[  155.957852] Testing event mm_compaction_defer_reset: OK
[  156.047959] Testing event mm_compaction_defer_compaction: OK
[  156.137502] Testing event mm_compaction_deferred: OK
[  156.227133] Testing event mm_compaction_suitable: OK
[  156.307699] Testing event mm_compaction_finished: OK
[  156.396930] Testing event mm_compaction_try_to_compact_pages: OK
[  156.497526] Testing event mm_compaction_end: OK
[  156.576737] Testing event mm_compaction_begin: OK
[  156.657355] Testing event mm_compaction_migratepages: OK
[  156.748250] Testing event mm_compaction_isolate_freepages: OK
[  156.846269] Testing event mm_compaction_isolate_migratepages: OK
[  156.948487] Testing event mm_numa_migrate_ratelimit: OK
[  157.037244] Testing event mm_migrate_pages: OK
[  157.116782] Testing event writeback_dirty_inode_enqueue: OK
[  157.207715] Testing event writeback_lazytime_iput: OK
[  157.297655] Testing event writeback_lazytime: OK
[  157.378024] Testing event writeback_single_inode: OK
[  157.467841] Testing event writeback_single_inode_start: OK
[  157.556866] Testing event writeback_wait_iff_congested: OK
[  157.647600] Testing event writeback_congestion_wait: OK
[  157.737499] Testing event writeback_sb_inodes_requeue: OK
[  157.828115] Testing event balance_dirty_pages: OK
[  157.907391] Testing event bdi_dirty_ratelimit: OK
[  157.987267] Testing event global_dirty_state: OK
[  158.067346] Testing event writeback_queue_io: OK
[  158.147213] Testing event wbc_writepage: OK
[  158.226660] Testing event writeback_bdi_register: OK
[  158.316105] Testing event writeback_wake_background: OK
[  158.407326] Testing event writeback_nowork: OK
[  158.487143] Testing event writeback_pages_written: OK
[  158.576595] Testing event writeback_wait: OK
[  158.657296] Testing event writeback_written: OK
[  158.737624] Testing event writeback_start: OK
[  158.816752] Testing event writeback_exec: OK
[  158.897216] Testing event writeback_queue: OK
[  158.977100] Testing event writeback_write_inode: OK
[  159.057623] Testing event writeback_write_inode_start: OK
[  159.147245] Testing event writeback_dirty_inode: OK
[  159.226969] Testing event writeback_dirty_inode_start: OK
[  159.316360] Testing event writeback_mark_inode_dirty: OK
[  159.407018] Testing event writeback_dirty_page: OK
[  159.487819] Testing event time_out_leases: OK
[  159.567138] Testing event generic_delete_lease: OK
[  159.647107] Testing event generic_add_lease: OK
[  159.727251] Testing event break_lease_unblock: OK
[  159.807362] Testing event break_lease_block: OK
[  159.887483] Testing event break_lease_noblock: OK
[  159.967363] Testing event ext4_es_shrink: OK
[  160.046781] Testing event ext4_insert_range: OK
[  160.126718] Testing event ext4_collapse_range: OK
[  160.207149] Testing event ext4_es_shrink_scan_exit: OK
[  160.297370] Testing event ext4_es_shrink_scan_enter: OK
[  160.387167] Testing event ext4_es_shrink_count: OK
[  160.466948] Testing event ext4_es_lookup_extent_exit: OK
[  160.557118] Testing event ext4_es_lookup_extent_enter: OK
[  160.646873] Testing event ext4_es_find_delayed_extent_range_exit: OK
[  160.756238] Testing event ext4_es_find_delayed_extent_range_enter: OK
[  160.856294] Testing event ext4_es_remove_extent: OK
[  160.936972] Testing event ext4_es_cache_extent: OK
[  161.016403] Testing event ext4_es_insert_extent: OK
[  161.096942] Testing event ext4_ext_remove_space_done: OK
[  161.186843] Testing event ext4_ext_remove_space: OK
[  161.266635] Testing event ext4_ext_rm_idx: OK
[  161.347226] Testing event ext4_ext_rm_leaf: OK
[  161.426914] Testing event ext4_remove_blocks: OK
[  161.506604] Testing event ext4_ext_show_extent: OK
[  161.586636] Testing event ext4_get_reserved_cluster_alloc: OK
[  161.676342] Testing event ext4_find_delalloc_range: OK
[  161.766894] Testing event ext4_ext_in_cache: OK
[  161.846604] Testing event ext4_ext_put_in_cache: OK
[  161.926514] Testing event ext4_get_implied_cluster_alloc_exit: OK
[  162.025969] Testing event ext4_ext_handle_unwritten_extents: OK
[  162.125800] Testing event ext4_trim_all_free: OK
[  162.206858] Testing event ext4_trim_extent: OK
[  162.286647] Testing event ext4_journal_start_reserved: OK
[  162.377211] Testing event ext4_journal_start: OK
[  162.457371] Testing event ext4_load_inode: OK
[  162.536330] Testing event ext4_ext_load_extent: OK
[  162.616829] Testing event ext4_ind_map_blocks_exit: OK
[  162.707038] Testing event ext4_ext_map_blocks_exit: OK
[  162.797761] Testing event ext4_ind_map_blocks_enter: OK
[  162.886664] Testing event ext4_ext_map_blocks_enter: OK
[  162.977053] Testing event ext4_ext_convert_to_initialized_fastpath: OK
[  163.085753] Testing event ext4_ext_convert_to_initialized_enter: OK
[  163.187089] Testing event ext4_truncate_exit: OK
[  163.267065] Testing event ext4_truncate_enter: OK
[  163.346858] Testing event ext4_unlink_exit: OK
[  163.426300] Testing event ext4_unlink_enter: OK
[  163.506704] Testing event ext4_fallocate_exit: OK
[  163.587381] Testing event ext4_zero_range: OK
[  163.667231] Testing event ext4_punch_hole: OK
[  163.746844] Testing event ext4_fallocate_enter: OK
[  163.826915] Testing event ext4_direct_IO_exit: OK
[  163.906656] Testing event ext4_direct_IO_enter: OK
[  163.986799] Testing event ext4_load_inode_bitmap: OK
[  164.076565] Testing event ext4_read_block_bitmap_load: OK
[  164.166252] Testing event ext4_mb_buddy_bitmap_load: OK
[  164.256482] Testing event ext4_mb_bitmap_load: OK
[  164.336187] Testing event ext4_da_release_space: OK
[  164.416731] Testing event ext4_da_reserve_space: OK
[  164.505613] Testing event ext4_da_update_reserve_space: OK
[  164.595900] Testing event ext4_forget: OK
[  164.666538] Testing event ext4_mballoc_free: OK
[  164.746119] Testing event ext4_mballoc_discard: OK
[  164.826630] Testing event ext4_mballoc_prealloc: OK
[  164.915380] Testing event ext4_mballoc_alloc: OK
[  164.996328] Testing event ext4_alloc_da_blocks: OK
[  165.076045] Testing event ext4_sync_fs: OK
[  165.146198] Testing event ext4_sync_file_exit: OK
[  165.225775] Testing event ext4_sync_file_enter: OK
[  165.305942] Testing event ext4_free_blocks: OK
[  165.385704] Testing event ext4_allocate_blocks: OK
[  165.466202] Testing event ext4_request_blocks: OK
[  165.546091] Testing event ext4_mb_discard_preallocations: OK
[  165.635882] Testing event ext4_discard_preallocations: OK
[  165.726090] Testing event ext4_mb_release_group_pa: OK
[  165.816016] Testing event ext4_mb_release_inode_pa: OK
[  165.905712] Testing event ext4_mb_new_group_pa: OK
[  165.986216] Testing event ext4_mb_new_inode_pa: OK
[  166.065944] Testing event ext4_discard_blocks: OK
[  166.146046] Testing event ext4_journalled_invalidatepage: OK
[  166.235872] Testing event ext4_invalidatepage: OK
[  166.316177] Testing event ext4_releasepage: OK
[  166.395958] Testing event ext4_readpage: OK
[  166.474768] Testing event ext4_writepage: OK
[  166.555096] Testing event ext4_writepages_result: OK
[  166.634922] Testing event ext4_da_write_pages_extent: OK
[  166.727863] Testing event ext4_da_write_pages: OK
[  166.805847] Testing event ext4_writepages: OK
[  166.885783] Testing event ext4_da_write_end: OK
[  166.965978] Testing event ext4_journalled_write_end: OK
[  167.055644] Testing event ext4_write_end: OK
[  167.135977] Testing event ext4_da_write_begin: OK
[  167.215986] Testing event ext4_write_begin: OK
[  167.295982] Testing event ext4_begin_ordered_truncate: OK
[  167.385835] Testing event ext4_mark_inode_dirty: OK
[  167.465950] Testing event ext4_drop_inode: OK
[  167.545520] Testing event ext4_evict_inode: OK
[  167.625984] Testing event ext4_allocate_inode: OK
[  167.705738] Testing event ext4_request_inode: OK
[  167.785915] Testing event ext4_free_inode: OK
[  167.865663] Testing event ext4_other_inode_update_time: OK
[  167.955602] Testing event jbd2_lock_buffer_stall: OK
[  168.045120] Testing event jbd2_write_superblock: OK
[  168.125294] Testing event jbd2_update_log_tail: OK
[  168.205748] Testing event jbd2_checkpoint_stats: OK
[  168.285840] Testing event jbd2_run_stats: OK
[  168.365853] Testing event jbd2_handle_stats: OK
[  168.446089] Testing event jbd2_handle_extend: OK
[  168.525785] Testing event jbd2_handle_start: OK
[  168.605838] Testing event jbd2_submit_inode_data: OK
[  168.695047] Testing event jbd2_end_commit: OK
[  168.776342] Testing event jbd2_drop_transaction: OK
[  168.865055] Testing event jbd2_commit_logging: OK
[  168.945811] Testing event jbd2_commit_flushing: OK
[  169.025185] Testing event jbd2_commit_locking: OK
[  169.105576] Testing event jbd2_start_commit: OK
[  169.186004] Testing event jbd2_checkpoint: OK
[  169.265691] Testing event block_rq_remap: OK
[  169.344914] Testing event block_bio_remap: OK
[  169.425391] Testing event block_split: OK
[  169.494364] Testing event block_unplug: OK
[  169.565059] Testing event block_plug: OK
[  169.635295] Testing event block_sleeprq: OK
[  169.713922] Testing event block_getrq: OK
[  169.784673] Testing event block_bio_queue: OK
[  169.864751] Testing event block_bio_frontmerge: OK
[  169.944110] Testing event block_bio_backmerge: OK
[  170.024905] Testing event block_bio_complete: OK
[  170.105062] Testing event block_bio_bounce: OK
[  170.184600] Testing event block_rq_issue: OK
[  170.263626] Testing event block_rq_insert: OK
[  170.344112] Testing event block_rq_complete: OK
[  170.424970] Testing event block_rq_requeue: OK
[  170.504955] Testing event block_rq_abort: OK
[  170.583676] Testing event block_dirty_buffer: OK
[  170.664733] Testing event block_touch_buffer: OK
[  170.744385] Testing event urandom_read: OK
[  170.814299] Testing event random_read: OK
[  170.884293] Testing event extract_entropy_user: OK
[  170.964379] Testing event extract_entropy: OK
[  171.044505] Testing event get_random_bytes_arch: OK
[  171.124676] Testing event get_random_bytes: OK
[  171.204325] Testing event xfer_secondary_pool: OK
[  171.284709] Testing event add_disk_randomness: OK
[  171.364454] Testing event add_input_randomness: OK
[  171.445149] Testing event debit_entropy: OK
[  171.524962] Testing event push_to_pool: OK
[  171.594730] Testing event credit_entropy_bits: OK
[  171.674949] Testing event mix_pool_bytes_nolock: OK
[  171.754849] Testing event mix_pool_bytes: OK
[  171.834134] Testing event add_device_randomness: OK
[  171.914942] Testing event scsi_eh_wakeup: OK
[  171.994254] Testing event scsi_dispatch_cmd_timeout: OK
[  172.085361] Testing event scsi_dispatch_cmd_done: OK
[  172.174681] Testing event scsi_dispatch_cmd_error: OK
[  172.263797] Testing event scsi_dispatch_cmd_start: OK
[  172.354308] Testing event ata_eh_link_autopsy_qc: OK
[  172.435040] Testing event ata_eh_link_autopsy: OK
[  172.514688] Testing event ata_qc_complete_done: OK
[  172.595273] Testing event ata_qc_complete_failed: OK
[  172.683861] Testing event ata_qc_complete_internal: OK
[  172.775178] Testing event ata_qc_issue: OK
[  172.844863] Testing event udp_fail_queue_rcv_skb: OK
[  172.934675] Testing event sock_exceed_buf_limit: OK
[  173.015310] Testing event sock_rcvqueue_full: OK
[  173.094893] Testing event napi_poll: OK
[  173.164861] Testing event netif_rx_ni_entry: OK
[  173.244885] Testing event netif_rx_entry: OK
[  173.325063] Testing event netif_receive_skb_entry: OK
[  173.415152] Testing event napi_gro_receive_entry: OK
[  173.504033] Testing event napi_gro_frags_entry: OK
[  173.586391] Testing event netif_rx: OK
[  173.655084] Testing event netif_receive_skb: OK
[  173.735120] Testing event net_dev_queue: OK
[  173.815146] Testing event net_dev_xmit: OK
[  173.884882] Testing event net_dev_start_xmit: OK
[  173.964673] Testing event skb_copy_datagram_iovec: OK
[  174.055205] Testing event consume_skb: OK
[  174.124985] Testing event kfree_skb: OK
[  174.195063] Running tests on trace event systems:
[  174.250070] Testing event system skb: OK
[  174.326558] Testing event system net: OK
[  174.408491] Testing event system napi: OK
[  174.485801] Testing event system sock: OK
[  174.565669] Testing event system udp: OK
[  174.635579] Testing event system libata: OK
[  174.720345] Testing event system scsi: OK
[  174.796433] Testing event system random: OK
[  174.880303] Testing event system block: OK
[  174.972349] Testing event system jbd2: OK
[  175.061090] Testing event system ext4: OK
[  175.189938] Testing event system filelock: OK
[  175.287017] Testing event system writeback: OK
[  175.385228] Testing event system migrate: OK
[  175.465069] Testing event system compaction: OK
[  175.548708] Testing event system kmem: OK
[  175.628382] Testing event system vmscan: OK
[  175.718548] Testing event system pagemap: OK
[  175.794961] Testing event system oom: OK
[  175.864542] Testing event system filemap: OK
[  175.944512] Testing event system rpm: OK
[  176.016168] Testing event system power: OK
[  176.102757] Testing event system test: OK
[  176.182680] Testing event system module: OK
[  176.264617] Testing event system timer: OK
[  176.347823] Testing event system rcu: OK
[  176.423851] Testing event system printk: OK
[  176.503801] Testing event system lock: OK
[  176.575178] Testing event system sched: OK
[  176.660827] Testing event system workqueue: OK
[  176.744859] Testing event system signal: OK
[  176.824301] Testing event system irq: OK
[  176.895390] Testing event system task: OK
[  176.972868] Testing event system raw_syscalls: OK
[  177.053686] Running tests on all trace events:
[  177.104196] Testing all events: OK
[  177.439932] Testing ftrace filter: OK
[  177.525120] Key type encrypted registered
[  177.563142] rtc-m48t59 rtc-m48t59.0: setting system clock to 2015-07-02 18:47:52 UTC (1435862872)
[  177.684187] EXT4-fs (sda1): couldn't mount as ext3 due to feature incompatibilities
[  177.768225] EXT4-fs (sda1): couldn't mount as ext2 due to feature incompatibilities
[  177.988868] EXT4-fs (sda1): mounted filesystem with ordered data mode. Opts: (null)
[  178.066725] VFS: Mounted root (ext4 filesystem) readonly on device 8:1.
[  178.178525] devtmpfs: mounted
[  180.138787] systemd[1]: Inserted module 'autofs4'
[  180.425094] random: systemd urandom read with 13 bits of entropy available
[  180.646505] systemd[1]: systemd 218 running in system mode. (+PAM +AUDIT +SELINUX +IMA +APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT -GNUTLS +ACL +XZ -LZ4 -SECCOMP +BLKID -ELFUTILS +KMOD -IDN)
[  180.858109] systemd[1]: Detected architecture 'sparc64'.
[  181.051206] systemd[1]: Set hostname to <u5>.
[  181.708769] systemd-system- (1149) used greatest stack depth: 5528 bytes left
[  182.163032] systemd-fstab-g (1152) used greatest stack depth: 4744 bytes left
[  184.063903] systemd[1]: Cannot add dependency job for unit display-manager.service, ignoring: Unit display-manager.service failed to load: No such file or directory.
[  184.243330] systemd[1]: Expecting device dev-ttyS0.device...
[  184.370412] systemd[1]: Starting Remote File Systems (Pre).
[  184.500237] systemd[1]: Reached target Remote File Systems (Pre).
[  184.561438] systemd[1]: Starting Dispatch Password Requests to Console Directory Watch.
[  184.649385] systemd[1]: Started Dispatch Password Requests to Console Directory Watch.
[  184.733450] systemd[1]: Expecting device dev-sda2.device...
[  184.850303] systemd[1]: Starting Forward Password Requests to Wall Directory Watch.
[  184.932652] systemd[1]: Started Forward Password Requests to Wall Directory Watch.
[  185.011340] systemd[1]: Starting Paths.
[  185.100146] systemd[1]: Reached target Paths.
[  185.140389] systemd[1]: Starting Root Slice.
[  185.230118] systemd[1]: Created slice Root Slice.
[  185.274686] systemd[1]: Starting Journal Audit Socket.
[  185.400118] systemd[1]: Listening on Journal Audit Socket.
[  185.453581] systemd[1]: Starting System Slice.
[  185.570098] systemd[1]: Created slice System Slice.
[  185.616093] systemd[1]: Starting /dev/initctl Compatibility Named Pipe.
[  185.780059] systemd[1]: Listening on /dev/initctl Compatibility Named Pipe.
[  185.850829] systemd[1]: Starting Journal Socket (/dev/log).
[  185.980025] systemd[1]: Listening on Journal Socket (/dev/log).
[  186.038340] systemd[1]: Starting Journal Socket.
[  186.140199] systemd[1]: Listening on Journal Socket.
[  186.190464] systemd[1]: Starting Create list of required static device nodes for the current kernel...
[  186.654314] systemd[1]: Starting Load Kernel Modules...
[  186.797718] systemd[1]: Mounting POSIX Message Queue File System...
[  186.979031] systemd[1]: Starting system-serial\x2dgetty.slice.
[  187.129764] systemd[1]: Created slice system-serial\x2dgetty.slice.
[  187.247619] systemd[1]: Mounting Huge Pages File System...
[  187.350241] fuse init (API version 7.23)
[  187.426028] systemd[1]: Starting File System Check on Root Device...
[  187.746370] systemd[1]: Starting User and Session Slice.
[  187.953724] systemd[1]: Created slice User and Session Slice.
[  188.065384] systemd[1]: Starting udev Control Socket.
[  188.122526] systemd[1]: Listening on udev Control Socket.
[  188.183321] systemd[1]: Mounting Debug File System...
[  188.272901] systemd[1]: Starting Encrypted Volumes.
[  188.407572] systemd[1]: Reached target Encrypted Volumes.
[  188.518728] systemd[1]: Starting Arbitrary Executable File Formats File System Automount Point.
[  188.635063] systemd[1]: Set up automount Arbitrary Executable File Formats File System Automount Point.
[  188.928864] systemd[1]: Started Set Up Additional Binary Formats.
[  189.003145] systemd[1]: Starting udev Kernel Socket.
[  189.061843] systemd[1]: Listening on udev Kernel Socket.
[  189.117673] systemd[1]: Starting udev Coldplug all Devices...
[  189.239326] systemd[1]: Starting system-getty.slice.
[  189.323083] systemd[1]: Created slice system-getty.slice.
[  189.390700] systemd[1]: Starting Slices.
[  189.529583] systemd[1]: Reached target Slices.
[  189.619015] systemd[1]: Starting Delayed Shutdown Socket.
[  189.830617] systemd[1]: Listening on Delayed Shutdown Socket.
[  189.999212] systemd[1]: Starting Syslog Socket.
[  190.099411] systemd[1]: Listening on Syslog Socket.
[  190.144923] systemd[1]: Starting Journal Service...
[  190.350478] systemd[1]: Mounted Debug File System.
[  190.469149] systemd[1]: Mounted Huge Pages File System.
[  190.599358] systemd[1]: Mounted POSIX Message Queue File System.
[  190.819212] systemd[1]: Started Create list of required static device nodes for the current kernel.
[  191.129769] systemd[1]: Started Load Kernel Modules.
[  191.379018] systemd[1]: Started File System Check on Root Device.
[  192.625406] systemd[1]: Mounted Configuration File System.
[  192.895359] systemd[1]: Starting Apply Kernel Variables...
[  193.284003] systemd[1]: Mounting FUSE Control File System...
[  193.779201] systemd[1]: Starting Create Static Device Nodes in /dev...
[  194.188805] systemd[1]: Mounted FUSE Control File System.
[  194.438711] systemd[1]: Started udev Coldplug all Devices.
[  194.608224] systemd[1]: Started Apply Kernel Variables.
[  194.830944] systemd[1]: Started Journal Service.
[  197.268545] blk_update_request: I/O error, dev fd0, sector 0
[  197.322720] floppy: error -5 while reading block 0
[  199.228979] PCI: Enabling device: (0000:01:01.1), cmd 2
[  199.229187] sunhme.c:v3.10 August 26, 2008 David S. Miller (davem@davemloft.net)
[  199.321365] eth0: HAPPY MEAL (PCI/CheerIO) 10/100BaseT Ethernet 08:00:20:f8:c7:72
[  199.950488] sd 0:0:0:0: Attached scsi generic sg0 type 0
[  200.403702] sr 1:0:0:0: Attached scsi generic sg1 type 5
[  200.928453] cdrom_id (1492) used greatest stack depth: 4552 bytes left
[  206.817869] Adding 1984016k swap on /dev/sda2.  Priority:-1 extents:1 across:1984016k 
[  208.393594] EXT4-fs (sda1): re-mounted. Opts: errors=remount-ro
[  209.608710] systemd-udevd (1457) used greatest stack depth: 3624 bytes left
[  209.821962] systemd-journald[1247]: Received request to flush runtime journal from PID 1
[  219.183825] eth0: Link is up using internal transceiver at 100Mb/s, Full Duplex.
[  309.383382] random: nonblocking pool is initialized

-- 
Meelis Roos (mroos@linux.ee)
