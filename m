From: Meelis Roos <mroos@linux.ee>
Subject: 4.1 regression in resizable hashtable tests
Date: Wed, 1 Jul 2015 13:21:08 +0300 (EEST)
Message-ID: <alpine.LRH.2.11.1507011259180.4092@math.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: sparclinux@vger.kernel.org,
	Linux Kernel list <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <sparclinux-owner@vger.kernel.org>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is 4.1 on sparc64 - one of my boxes that happens to have most 
runtime test left on from some debugging effort. In 4.0 it was fine, 4.1 
gives this in dmesg:

[   31.898697] Running resizable hashtable tests...
[   31.898915]   Adding 2048 keys
[   31.952911]   Traversal complete: counted=17, nelems=2048, entries=2048
[   31.953004] Test failed: Total count mismatch ^^^
[   32.022676]   Traversal complete: counted=17, nelems=2048, entries=2048
[   32.022788] Test failed: Total count mismatch ^^^
[   32.022828]   Deleting 2048 keys


Full dmesg:
[    0.000000] PROMLIB: Sun IEEE Boot Prom 'OBP 3.31.0 2001/07/25 20:36'
[    0.000000] PROMLIB: Root node compatible: 
[    0.000000] Linux version 4.1.0 (mroos@u5) (gcc version 4.9.2 (Debian 4.9.2-20) ) #18 Wed Jul 1 02:33:02 EEST 2015
[    0.000000] bootconsole [earlyprom0] enabled
[    0.000000] ARCH: SUN4U
[    0.000000] Ethernet address: 08:00:20:f8:c7:72
[    0.000000] MM: PAGE_OFFSET is 0xfffff80000000000 (max_phys_bits == 40)
[    0.000000] MM: VMALLOC [0x0000000100000000 --> 0x0000060000000000]
[    0.000000] MM: VMEMMAP [0x0000060000000000 --> 0x00000c0000000000]
[    0.000000] Kernel: Using 6 locked TLB entries for main kernel image.
[    0.000000] Remapping the kernel... done.
[    0.000000] kmemleak: Kernel memory leak detector disabled
[    0.000000] OF stdout device is: /pci@1f,0/pci@1,1/ebus@1/se@14,400000:a
[    0.000000] PROM: Built device tree with 70282 bytes of memory.
[    0.000000] Top of RAM: 0x1ff3e000, Total RAM: 0x1ff2e000
[    0.000000] Memory hole size: 0MB
[    0.000000] Allocated 16384 bytes for kernel page tables.
[    0.000000] Zone ranges:
[    0.000000]   Normal   [mem 0x0000000000000000-0x000000001ff3dfff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000000000-0x000000001fefdfff]
[    0.000000]   node   0: [mem 0x000000001ff00000-0x000000001ff2bfff]
[    0.000000]   node   0: [mem 0x000000001ff3a000-0x000000001ff3dfff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000000000-0x000000001ff3dfff]
[    0.000000] On node 0 totalpages: 65431
[    0.000000]   Normal zone: 512 pages used for memmap
[    0.000000]   Normal zone: 0 pages reserved
[    0.000000]   Normal zone: 65431 pages, LIFO batch:15
[    0.000000] Booting Linux...
[    0.000000] CPU CAPS: [flush,stbar,swap,muldiv,v9,mul32,div32,v8plus]
[    0.000000] CPU CAPS: [vis]
[    0.000000] pcpu-alloc: s0 r0 d32768 u32768 alloc=1*32768
[    0.000000] pcpu-alloc: [0] 0 
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 64919
[    0.000000] Kernel command line: root=/dev/sda1 ro
[    0.000000] PID hash table entries: 2048 (order: 1, 16384 bytes)
[    0.000000] Dentry cache hash table entries: 65536 (order: 6, 524288 bytes)
[    0.000000] Inode-cache hash table entries: 32768 (order: 5, 262144 bytes)
[    0.000000] Sorting __ex_table...
[    0.000000] Memory: 491632K/523448K available (5216K kernel code, 509K rwdata, 1656K rodata, 520K init, 14578K bss, 31816K reserved, 0K cma-reserved)
[    0.000000] Running RCU self tests
[    0.000000] Testing tracer nop: PASSED
[    0.000000] NR_IRQS:2048 nr_irqs:2048 1
[   25.662551] clocksource tick: mask: 0xffffffffffffffff max_cycles: 0x5306eb473f, max_idle_ns: 440795213232 ns
[   25.765203] clocksource: mult[2c71c72] shift[24]
[   25.804735] clockevent: mult[5c28f5c3] shift[32]
[   25.846767] Console: colour dummy device 80x25
[   25.882817] console [tty0] enabled
[   25.907574] bootconsole [earlyprom0] disabled
[   25.944044] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
[   25.944112] ... MAX_LOCKDEP_SUBCLASSES:  8
[   25.944151] ... MAX_LOCK_DEPTH:          48
[   25.944190] ... MAX_LOCKDEP_KEYS:        8191
[   25.944229] ... CLASSHASH_SIZE:          4096
[   25.944268] ... MAX_LOCKDEP_ENTRIES:     32768
[   25.944308] ... MAX_LOCKDEP_CHAINS:      65536
[   25.944349] ... CHAINHASH_SIZE:          32768
[   25.944390]  memory used by lock dependency info: 8159 kB
[   25.944437]  per task-struct memory footprint: 1920 bytes
[   25.944483] ------------------------
[   25.944516] | Locking API testsuite:
[   25.944550] ----------------------------------------------------------------------------
[   25.944615]                                  | spin |wlock |rlock |mutex | wsem | rsem |
[   25.944678]   --------------------------------------------------------------------------
[   25.944780]                      A-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   26.011037]                  A-B-B-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   26.077813]              A-B-B-C-C-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   26.144938]              A-B-C-A-B-C deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   26.212077]          A-B-B-C-C-D-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   26.279658]          A-B-C-D-B-D-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   26.347348]          A-B-C-D-B-C-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   26.415093]                     double unlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   26.481784]                   initialize held:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   26.548352]                  bad unlock order:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   26.615397]   --------------------------------------------------------------------------
[   26.615487]               recursive read-lock:             |  ok  |             |  ok  |
[   26.637854]            recursive read-lock #2:             |  ok  |             |  ok  |
[   26.660228]             mixed read-write-lock:             |  ok  |             |  ok  |
[   26.682625]             mixed write-read-lock:             |  ok  |             |  ok  |
[   26.705017]   --------------------------------------------------------------------------
[   26.705108]      hard-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
[   26.738521]      soft-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
[   26.771975]      hard-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
[   26.805402]      soft-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
[   26.838845]        sirq-safe-A => hirqs-on/12:  ok  |  ok  |  ok  |
[   26.872298]        sirq-safe-A => hirqs-on/21:  ok  |  ok  |  ok  |
[   26.905746]          hard-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
[   26.939172]          soft-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
[   26.972629]          hard-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
[   27.006066]          soft-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
[   27.039523]     hard-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
[   27.073132]     soft-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
[   27.106752]     hard-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
[   27.140339]     soft-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
[   27.173940]     hard-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
[   27.207533]     soft-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
[   27.241136]     hard-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
[   27.274717]     soft-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
[   27.308325]     hard-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
[   27.341827]     soft-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
[   27.375346]     hard-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
[   27.408917]     soft-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
[   27.442497]     hard-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
[   27.476112]     soft-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
[   27.509747]     hard-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
[   27.543378]     soft-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
[   27.577039]     hard-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
[   27.610684]     soft-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
[   27.644366]     hard-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
[   27.677991]     soft-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
[   27.711628]     hard-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
[   27.745250]     soft-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
[   27.778923]     hard-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
[   27.812516]     soft-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
[   27.846149]       hard-irq lock-inversion/123:  ok  |  ok  |  ok  |
[   27.879804]       soft-irq lock-inversion/123:  ok  |  ok  |  ok  |
[   27.913479]       hard-irq lock-inversion/132:  ok  |  ok  |  ok  |
[   27.947156]       soft-irq lock-inversion/132:  ok  |  ok  |  ok  |
[   27.980856]       hard-irq lock-inversion/213:  ok  |  ok  |  ok  |
[   28.014543]       soft-irq lock-inversion/213:  ok  |  ok  |  ok  |
[   28.048258]       hard-irq lock-inversion/231:  ok  |  ok  |  ok  |
[   28.081907]       soft-irq lock-inversion/231:  ok  |  ok  |  ok  |
[   28.115588]       hard-irq lock-inversion/312:  ok  |  ok  |  ok  |
[   28.149260]       soft-irq lock-inversion/312:  ok  |  ok  |  ok  |
[   28.182966]       hard-irq lock-inversion/321:  ok  |  ok  |  ok  |
[   28.216611]       soft-irq lock-inversion/321:  ok  |  ok  |  ok  |
[   28.250285]       hard-irq read-recursion/123:  ok  |
[   28.261582]       soft-irq read-recursion/123:  ok  |
[   28.272883]       hard-irq read-recursion/132:  ok  |
[   28.284188]       soft-irq read-recursion/132:  ok  |
[   28.295489]       hard-irq read-recursion/213:  ok  |
[   28.306793]       soft-irq read-recursion/213:  ok  |
[   28.318094]       hard-irq read-recursion/231:  ok  |
[   28.329396]       soft-irq read-recursion/231:  ok  |
[   28.340696]       hard-irq read-recursion/312:  ok  |
[   28.351991]       soft-irq read-recursion/312:  ok  |
[   28.363307]       hard-irq read-recursion/321:  ok  |
[   28.374606]       soft-irq read-recursion/321:  ok  |
[   28.385911]   --------------------------------------------------------------------------
[   28.385994]   | Wound/wait tests |
[   28.386046]   ---------------------
[   28.386105]                   ww api failures:  ok  |  ok  |  ok  |
[   28.419844]                ww contexts mixing:  ok  |  ok  |
[   28.442284]              finishing ww context:  ok  |  ok  |  ok  |  ok  |
[   28.487050]                locking mismatches:  ok  |  ok  |  ok  |
[   28.520696]                  EDEADLK handling:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   28.633222]            spinlock nest unlocked:  ok  |
[   28.644462]   -----------------------------------------------------
[   28.644534]                                  |block | try  |context|
[   28.644602]   -----------------------------------------------------
[   28.644679]                           context:  ok  |  ok  |  ok  |
[   28.678472]                               try:  ok  |  ok  |  ok  |
[   28.712126]                             block:  ok  |  ok  |  ok  |
[   28.745781]                          spinlock:  ok  |  ok  |  ok  |
[   28.779729] -------------------------------------------------------
[   28.779817] Good, all 253 testcases passed! |
[   28.779875] ---------------------------------
[   28.788269] ODEBUG: selftest passed
[   28.788638] kmemleak: Early log buffer exceeded (2062), please increase DEBUG_KMEMLEAK_EARLY_LOG_SIZE
[   28.930221] Calibrating delay using timer specific routine.. 726.73 BogoMIPS (lpj=3633650)
[   28.930354] pid_max: default: 32768 minimum: 301
[   28.931806] Mount-cache hash table entries: 1024 (order: 0, 8192 bytes)
[   28.931914] Mountpoint-cache hash table entries: 1024 (order: 0, 8192 bytes)
[   28.939799] ftrace: allocating 14948 entries in 30 pages
[   29.014585] devtmpfs: initialized
[   29.059991] Performance events: No support for PMU type 'ultra12'
[   29.063740] clocksource jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 19112604462750000 ns
[   29.066949] Testing tracer function: 
[   29.069634] kworker/u2:0 (11) used greatest stack depth: 7832 bytes left
[   29.240888] PASSED
[   29.240976] Testing dynamic ftrace: PASSED
[   29.520938] Testing dynamic ftrace ops #1: (1 0 1 0 0) (1 1 2 0 0) (2 1 3 0 74) (2 2 4 0 162) PASSED
[   29.808368] Testing dynamic ftrace ops #2: (1 0 1 78 0) (1 1 2 166 0) (2 1 3 1 3) (2 2 4 86 88) PASSED
[   30.119554] Testing ftrace recursion: PASSED
[   30.185567] Testing ftrace recursion safe: PASSED
[   30.251551] Testing ftrace regs(no arch support): PASSED
[   30.317783] Testing tracer irqsoff: PASSED
[   30.361258] Testing tracer function_graph: PASSED
[   30.535475] atomic64_test: passed
[   30.540551] NET: Registered protocol family 16
[   30.610279] /pci@1f,0: PCI IO[1fe02000000] MEM[1ff00000000]
[   30.610516] /pci@1f,0: SABRE PCI Bus Module ver[0:0]
[   30.610587] PCI: Scanning PBM /pci@1f,0
[   30.614237] sabre f005f9c0: PCI host bridge to bus 0000:00
[   30.614368] pci_bus 0000:00: root bus resource [io  0x1fe02000000-0x1fe02ffffff] (bus address [0x0000-0xffffff])
[   30.614512] pci_bus 0000:00: root bus resource [mem 0x1ff00000000-0x1ffffffffff] (bus address [0x00000000-0xffffffff])
[   30.614665] pci_bus 0000:00: root bus resource [bus 00-02]
[   30.638710] pci 0000:00:01.0: can't claim BAR 8 [mem 0x1ff00000000-0x1ffbfffffff]: address conflict with Video RAM area [??? 0x1ff000a0000-0x1ff000bffff flags 0x80000000]
[   30.942142] vgaarb: device added: PCI:0000:01:02.0,decodes=io+mem,owns=none,locks=none
[   30.942300] vgaarb: loaded
[   30.942356] vgaarb: bridge control possible 0000:01:02.0
[   30.944870] SCSI subsystem initialized
[   30.956120] libata version 3.00 loaded.
[   30.969205] /pci@1f,0/pci@1,1/ebus@1/eeprom@14,0: Mostek regs at 0x1fff1000000
[   31.120093] DMA-API: preallocated 32768 debug entries
[   31.120216] DMA-API: debugging enabled by kernel config
[   31.121271] AUXIO: Found device at /pci@1f,0/pci@1,1/ebus@1/auxio@14,726000
[   31.122278] Switched to clocksource tick
[   31.758526] NET: Registered protocol family 2
[   31.764886] TCP established hash table entries: 4096 (order: 2, 32768 bytes)
[   31.765493] TCP bind hash table entries: 4096 (order: 5, 262144 bytes)
[   31.768830] TCP: Hash tables configured (established 4096 bind 4096)
[   31.770336] UDP hash table entries: 256 (order: 2, 40960 bytes)
[   31.770995] UDP-Lite hash table entries: 256 (order: 2, 40960 bytes)
[   31.774198] NET: Registered protocol family 1
[   31.774836] PCI: CLS 64 bytes, default 64
[   31.776734] power: Control reg at 1fff1724000
[   31.798023] futex hash table entries: 256 (order: 1, 20480 bytes)
[   31.798393] Initialise system trusted keyring
[   31.799440] ====[ backtrace testing ]===========
[   31.799519] Testing a backtrace from process context.
[   31.799581] The following trace is a kernel self test and not a bug!
[   31.799667] CPU: 0 PID: 1 Comm: swapper Not tainted 4.1.0 #18
[   31.799736] Call Trace:
[   31.799810]  [00000000004d1b90] backtrace_regression_test+0x30/0x100
[   31.799904]  [0000000000426e2c] do_one_initcall+0xec/0x1e0
[   31.800004]  [0000000000b46b30] kernel_init_freeable+0x104/0x1b4
[   31.800107]  [000000000090e9ac] kernel_init+0xc/0x100
[   31.800207]  [0000000000405fe4] ret_from_fork+0x1c/0x2c
[   31.800278]  [0000000000000000]           (null)
[   31.800340] Testing a backtrace from irq context.
[   31.800401] The following trace is a kernel self test and not a bug!
[   31.802340] CPU: 0 PID: 10 Comm: kworker/u2:1 Not tainted 4.1.0 #18
[   31.802474] Workqueue: khelper __call_usermodehelper
[   31.802556] Call Trace:
[   31.802635]  [00000000004d1b2c] backtrace_test_irq_callback+0xc/0x40
[   31.802731]  [0000000000460058] tasklet_action+0x78/0xe0
[   31.802814]  [000000000045f2d8] __do_softirq+0x278/0x660
[   31.802905]  [000000000042be28] do_softirq_own_stack+0x28/0x40
[   31.802988]  [000000000045f9ac] irq_exit+0x4c/0xc0
[   31.803085]  [000000000091c150] timer_interrupt+0x70/0xa0
[   31.803170]  [0000000000426b34] sys_call_table+0x5b8/0x744
[   31.803264]  [00000000006e952c] clear_page_common+0x54/0x80
[   31.803354]  [000000000052a728] __alloc_pages_nodemask+0x148/0xaa0
[   31.803450]  [000000000052b25c] alloc_kmem_pages_node+0x1c/0x40
[   31.803538]  [0000000000458c74] copy_process+0xf4/0x1580
[   31.803618]  [000000000045a22c] do_fork+0x6c/0x7c0
[   31.803697]  [000000000045a9a4] kernel_thread+0x24/0x40
[   31.803782]  [00000000004714fc] __call_usermodehelper+0x3c/0x80
[   31.803867]  [000000000047605c] process_one_work+0x3dc/0x800
[   31.803949]  [0000000000476790] worker_thread+0x310/0x500
[   31.816221] Testing a saved backtrace.
[   31.816313] The following trace is a kernel self test and not a bug!
[   31.816387]  [<00000000004d1c2c>] backtrace_regression_test+0xcc/0x100
[   31.816524]  [<0000000000426e2c>] do_one_initcall+0xec/0x1e0
[   31.816622]  [<0000000000b46b30>] kernel_init_freeable+0x104/0x1b4
[   31.816738]  [<000000000090e9ac>] kernel_init+0xc/0x100
[   31.816856]  [<0000000000405fe4>] ret_from_fork+0x1c/0x2c
[   31.816957]  [<          (null)>]           (null)
[   31.817037] ====[ end of backtrace testing ]====
[   31.817286] audit: initializing netlink subsys (disabled)
[   31.818371] audit: type=2000 audit(5.510:1): initialized
[   31.832647] HugeTLB registered 8 MB page size, pre-allocated 0 pages
[   31.845758] Key type big_key registered
[   31.857361] io scheduler noop registered
[   31.857820] io scheduler cfq registered (default)
[   31.857941] start plist test
[   31.885201] end plist test
[   31.893269] test_string_helpers: Running tests...
[   31.898697] Running resizable hashtable tests...
[   31.898915]   Adding 2048 keys
[   31.952911]   Traversal complete: counted=17, nelems=2048, entries=2048
[   31.953004] Test failed: Total count mismatch ^^^
[   32.022676]   Traversal complete: counted=17, nelems=2048, entries=2048
[   32.022788] Test failed: Total count mismatch ^^^
[   32.022828]   Deleting 2048 keys
[   32.174849] rbtree testing -> 21705 cycles
[   38.644425] augmented rbtree testing -> 31609 cycles
[   48.032926] PCI: Enabling device: (0000:01:02.0), cmd 82
[   48.033083] atyfb: 3D RAGE PRO (Mach64 GP, PQFP, PCI) [0x4750 rev 0x7c]
[   48.033221] atyfb: 4M SGRAM (1:1), 14.31818 MHz XTAL, 230 MHz PLL, 100 Mhz MCLK, 100 MHz XCLK
[   48.095799] Console: switching to colour frame buffer device 80x30
[   48.107585] atyfb: fb0: ATY Mach64 frame buffer device on PCI
[   48.132420] f0061c64: ttyS0 at MMIO 0x1fff1400000 (irq = 5, base_baud = 115200) is a SAB82532 V3.2
[   48.140672] Console: ttyS0 (SAB82532)
[   62.466065] console [ttyS0] enabled
[   62.505116] f0061c64: ttyS1 at MMIO 0x1fff1400040 (irq = 5, base_baud = 115200) is a SAB82532 V3.2
[   62.957181] Floppy drive(s): fd0 is 1.44M
[   63.142024] loop: module loaded
[   63.219179] scsi host0: pata_cmd64x
[   63.258480] scsi host1: pata_cmd64x
[   63.291363] ata1: PATA max MWDMA2 cmd 0x1fe02c00000 ctl 0x1fe02c00008 bmdma 0x1fe02c00020 irq 14
[   63.388402] ata2: PATA max MWDMA2 cmd 0x1fe02c00010 ctl 0x1fe02c00018 bmdma 0x1fe02c00028 irq 14
[   63.491328] pata_cmd64x: active 10 recovery 10 setup 3.
[   63.491447] pata_cmd64x: active 10 recovery 10 setup 3.
[   63.505033] FDC 0 is a National Semiconductor PC87306
[   63.555632] mousedev: PS/2 mouse device common for all mice
[   63.634455] rtc-m48t59 rtc-m48t59.0: rtc core: registered m48t59 as rtc0
[   63.707959] NET: Registered protocol family 10
[   63.772137] ata1.00: ATA-6: ST3120026A, 3.06, max UDMA/100
[   63.825753] ata1.00: 234441648 sectors, multi 0: LBA48 
[   63.876026] pata_cmd64x: active 3 recovery 1 setup 1.
[   63.876118] pata_cmd64x: active 3 recovery 1 setup 1.
[   63.877862] kworker/u2:3 (344) used greatest stack depth: 7664 bytes left
[   63.968979] NET: Registered protocol family 17
[   64.016143] ata1.00: configured for MWDMA2
[   64.059495] scsi 0:0:0:0: Direct-Access     ATA      ST3120026A       3.06 PQ: 0 ANSI: 5
[   64.161468] sd 0:0:0:0: [sda] 234441648 512-byte logical blocks: (120 GB/111 GiB)
[   64.239903] sd 0:0:0:0: [sda] Write Protect is off
[   64.284707] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[   64.285230] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   64.392586] pata_cmd64x: active 10 recovery 10 setup 3.
[   64.392664] pata_cmd64x: active 10 recovery 10 setup 3.
[   64.409513] Loading compiled-in X.509 certificates
[   64.454761] registered taskstats version 1
[   64.491278] Running tests on trace events:
[   64.527765] Testing event sys_exit: 
[   64.554363] ata2.00: ATAPI: CRD-8322B, 1.06, max MWDMA2
[   64.609639] pata_cmd64x: active 3 recovery 1 setup 1.
[   64.609734] pata_cmd64x: active 3 recovery 1 setup 1.
[   64.630809] OK
[   64.638344] Testing event sys_enter: 
[   64.665592] ata2.00: configured for MWDMA2
[   64.708326]  sda: sda1 sda2 sda3
[   64.753618] sd 0:0:0:0: [sda] Attached SCSI disk
[   64.799155] OK
[   64.805886] Testing event task_rename: 
[   64.845732] scsi 1:0:0:0: CD-ROM               LG    CD-ROM CRD-8322B 1.06 PQ: 0 ANSI: 5
[   64.936919] OK
[   64.943778] Testing event task_newtask: 
[   64.994612] sr 1:0:0:0: [sr0] scsi3-mmc drive: 32x/32x cd/rw xa/form2 cdda tray
[   65.073988] cdrom: Uniform CD-ROM driver Revision: 3.20
[   65.132039] OK
[   65.139026] Testing event softirq_raise: 
[   65.177208] sr 1:0:0:0: Attached scsi CD-ROM sr0
[   65.190859] OK
[   65.197739] Testing event softirq_exit: OK
[   65.254902] Testing event softirq_entry: OK
[   65.304761] Testing event irq_handler_exit: OK
[   65.364512] Testing event irq_handler_entry: OK
[   65.424295] Testing event signal_deliver: OK
[   65.474227] Testing event signal_generate: OK
[   65.534042] Testing event workqueue_execute_end: OK
[   65.594236] Testing event workqueue_execute_start: OK
[   65.654068] Testing event workqueue_activate_work: OK
[   65.713762] Testing event workqueue_queue_work: OK
[   65.773984] Testing event sched_wake_idle_without_ipi: OK
[   65.843866] Testing event sched_swap_numa: OK
[   65.893849] Testing event sched_stick_numa: OK
[   65.953789] Testing event sched_move_numa: OK
[   66.003701] Testing event sched_process_hang: OK
[   66.063740] Testing event sched_pi_setprio: OK
[   66.123892] Testing event sched_stat_runtime: OK
[   66.183619] Testing event sched_stat_blocked: OK
[   66.243332] Testing event sched_stat_iowait: OK
[   66.303272] Testing event sched_stat_sleep: OK
[   66.363105] Testing event sched_stat_wait: OK
[   66.412907] Testing event sched_process_exec: OK
[   66.472803] Testing event sched_process_fork: OK
[   66.532932] Testing event sched_process_wait: OK
[   66.592649] Testing event sched_wait_task: OK
[   66.642587] Testing event sched_process_exit: OK
[   66.702598] Testing event sched_process_free: OK
[   66.762544] Testing event sched_migrate_task: OK
[   66.822543] Testing event sched_switch: OK
[   66.872615] Testing event sched_wakeup_new: OK
[   66.922508] Testing event sched_wakeup: OK
[   66.972550] Testing event sched_kthread_stop_ret: OK
[   67.032458] Testing event sched_kthread_stop: OK
[   67.092434] Testing event lock_release: OK
[   67.143691] Testing event lock_acquire: OK
[   67.193711] Testing event console: OK
[   67.242322] Testing event rcu_utilization: OK
[   67.292326] Testing event tick_stop: OK
[   67.342436] Testing event itimer_expire: OK
[   67.392429] Testing event itimer_state: OK
[   67.442395] Testing event hrtimer_cancel: OK
[   67.492395] Testing event hrtimer_expire_exit: OK
[   67.552410] Testing event hrtimer_expire_entry: OK
[   67.612380] Testing event hrtimer_start: OK
[   67.662392] Testing event hrtimer_init: OK
[   67.712382] Testing event timer_cancel: OK
[   67.762351] Testing event timer_expire_exit: OK
[   67.822380] Testing event timer_expire_entry: OK
[   67.882374] Testing event timer_start: OK
[   67.932354] Testing event timer_init: OK
[   67.982331] Testing event module_request: OK
[   68.032355] Testing event module_put: OK
[   68.082335] Testing event module_get: OK
[   68.132294] Testing event module_free: OK
[   68.182250] Testing event module_load: OK
[   68.232246] Testing event ftrace_test_filter: OK
[   68.292230] Testing event dev_pm_qos_remove_request: OK
[   68.353115] Testing event dev_pm_qos_update_request: OK
[   68.412523] Testing event dev_pm_qos_add_request: OK
[   68.472246] Testing event pm_qos_update_flags: OK
[   68.532254] Testing event pm_qos_update_target: OK
[   68.592222] Testing event pm_qos_update_request_timeout: OK
[   68.662212] Testing event pm_qos_remove_request: OK
[   68.722195] Testing event pm_qos_update_request: OK
[   68.782173] Testing event pm_qos_add_request: OK
[   68.842482] Testing event power_domain_target: OK
[   68.902166] Testing event clock_set_rate: OK
[   68.952197] Testing event clock_disable: OK
[   69.002179] Testing event clock_enable: OK
[   69.052171] Testing event wakeup_source_deactivate: OK
[   69.112301] Testing event wakeup_source_activate: OK
[   69.172289] Testing event suspend_resume: OK
[   69.222534] Testing event device_pm_callback_end: OK
[   69.282332] Testing event device_pm_callback_start: OK
[   69.342323] Testing event cpu_frequency: OK
[   69.392335] Testing event pstate_sample: OK
[   69.442337] Testing event cpu_idle: OK
[   69.492362] Testing event rpm_return_int: OK
[   69.542377] Testing event rpm_idle: OK
[   69.592405] Testing event rpm_resume: OK
[   69.642354] Testing event rpm_suspend: OK
[   69.692300] Testing event mm_filemap_add_to_page_cache: OK
[   69.762347] Testing event mm_filemap_delete_from_page_cache: OK
[   69.832360] Testing event oom_score_adj_update: OK
[   69.892373] Testing event mm_lru_activate: OK
[   69.942388] Testing event mm_lru_insertion: OK
[   70.002253] Testing event mm_vmscan_lru_shrink_inactive: OK
[   70.072687] Testing event mm_vmscan_writepage: OK
[   70.132415] Testing event mm_vmscan_memcg_isolate: OK
[   70.192386] Testing event mm_vmscan_lru_isolate: OK
[   70.252469] Testing event mm_shrink_slab_end: OK
[   70.312454] Testing event mm_shrink_slab_start: OK
[   70.372440] Testing event mm_vmscan_memcg_softlimit_reclaim_end: OK
[   70.452497] Testing event mm_vmscan_memcg_reclaim_end: OK
[   70.522475] Testing event mm_vmscan_direct_reclaim_end: OK
[   70.592470] Testing event mm_vmscan_memcg_softlimit_reclaim_begin: OK
[   70.672483] Testing event mm_vmscan_memcg_reclaim_begin: OK
[   70.742466] Testing event mm_vmscan_direct_reclaim_begin: OK
[   70.812487] Testing event mm_vmscan_wakeup_kswapd: OK
[   70.872476] Testing event mm_vmscan_kswapd_wake: OK
[   70.932472] Testing event mm_vmscan_kswapd_sleep: OK
[   70.992438] Testing event mm_page_alloc_extfrag: OK
[   71.052427] Testing event mm_page_pcpu_drain: OK
[   71.112425] Testing event mm_page_alloc_zone_locked: OK
[   71.172441] Testing event mm_page_alloc: OK
[   71.222440] Testing event mm_page_free_batched: OK
[   71.282383] Testing event mm_page_free: OK
[   71.332328] Testing event kmem_cache_free: OK
[   71.382375] Testing event kfree: OK
[   71.422341] Testing event kmem_cache_alloc_node: OK
[   71.482261] Testing event kmalloc_node: OK
[   71.532217] Testing event kmem_cache_alloc: OK
[   71.592087] Testing event kmalloc: OK
[   71.642286] Testing event mm_compaction_defer_reset: OK
[   71.702311] Testing event mm_compaction_defer_compaction: OK
[   71.772168] Testing event mm_compaction_deferred: OK
[   71.832275] Testing event mm_compaction_suitable: OK
[   71.892165] Testing event mm_compaction_finished: OK
[   71.952114] Testing event mm_compaction_try_to_compact_pages: OK
[   72.022102] Testing event mm_compaction_end: OK
[   72.082056] Testing event mm_compaction_begin: OK
[   72.141999] Testing event mm_compaction_migratepages: OK
[   72.211750] Testing event mm_compaction_isolate_freepages: OK
[   72.281934] Testing event mm_compaction_isolate_migratepages: OK
[   72.352760] Testing event mm_numa_migrate_ratelimit: OK
[   72.421654] Testing event mm_migrate_pages: OK
[   72.471984] Testing event writeback_dirty_inode_enqueue: OK
[   72.542000] Testing event writeback_lazytime_iput: OK
[   72.602202] Testing event writeback_lazytime: OK
[   72.661967] Testing event writeback_single_inode: OK
[   72.721954] Testing event writeback_single_inode_start: OK
[   72.791931] Testing event writeback_wait_iff_congested: OK
[   72.861907] Testing event writeback_congestion_wait: OK
[   72.921906] Testing event writeback_sb_inodes_requeue: OK
[   72.991877] Testing event balance_dirty_pages: OK
[   73.051888] Testing event bdi_dirty_ratelimit: OK
[   73.111975] Testing event global_dirty_state: OK
[   73.171974] Testing event writeback_queue_io: OK
[   73.231922] Testing event wbc_writepage: OK
[   73.281933] Testing event writeback_bdi_register: OK
[   73.341952] Testing event writeback_wake_background: OK
[   73.401969] Testing event writeback_nowork: OK
[   73.462088] Testing event writeback_pages_written: OK
[   73.521954] Testing event writeback_wait: OK
[   73.571924] Testing event writeback_written: OK
[   73.631917] Testing event writeback_start: OK
[   73.681885] Testing event writeback_exec: OK
[   73.731845] Testing event writeback_queue: OK
[   73.781810] Testing event writeback_write_inode: OK
[   73.841750] Testing event writeback_write_inode_start: OK
[   73.911680] Testing event writeback_dirty_inode: OK
[   73.971618] Testing event writeback_dirty_inode_start: OK
[   74.041576] Testing event writeback_mark_inode_dirty: OK
[   74.111489] Testing event writeback_dirty_page: OK
[   74.171599] Testing event time_out_leases: OK
[   74.221623] Testing event generic_delete_lease: OK
[   74.281634] Testing event generic_add_lease: OK
[   74.342130] Testing event break_lease_unblock: OK
[   74.401600] Testing event break_lease_block: OK
[   74.461537] Testing event break_lease_noblock: OK
[   74.521501] Testing event ext4_es_shrink: OK
[   74.571502] Testing event ext4_collapse_range: OK
[   74.631584] Testing event ext4_es_shrink_scan_exit: OK
[   74.691576] Testing event ext4_es_shrink_scan_enter: OK
[   74.751516] Testing event ext4_es_shrink_count: OK
[   74.811490] Testing event ext4_es_lookup_extent_exit: OK
[   74.881490] Testing event ext4_es_lookup_extent_enter: OK
[   74.951444] Testing event ext4_es_find_delayed_extent_range_exit: OK
[   75.031466] Testing event ext4_es_find_delayed_extent_range_enter: OK
[   75.111445] Testing event ext4_es_remove_extent: OK
[   75.171500] Testing event ext4_es_cache_extent: OK
[   75.231503] Testing event ext4_es_insert_extent: OK
[   75.291511] Testing event ext4_ext_remove_space_done: OK
[   75.361296] Testing event ext4_ext_remove_space: OK
[   75.421600] Testing event ext4_ext_rm_idx: OK
[   75.471473] Testing event ext4_ext_rm_leaf: OK
[   75.521457] Testing event ext4_remove_blocks: OK
[   75.581433] Testing event ext4_ext_show_extent: OK
[   75.641407] Testing event ext4_get_reserved_cluster_alloc: OK
[   75.711412] Testing event ext4_find_delalloc_range: OK
[   75.771408] Testing event ext4_ext_in_cache: OK
[   75.831410] Testing event ext4_ext_put_in_cache: OK
[   75.891367] Testing event ext4_get_implied_cluster_alloc_exit: OK
[   75.961729] Testing event ext4_ext_handle_unwritten_extents: OK
[   76.031575] Testing event ext4_trim_all_free: OK
[   76.091585] Testing event ext4_trim_extent: OK
[   76.151237] Testing event ext4_journal_start_reserved: OK
[   76.221540] Testing event ext4_journal_start: OK
[   76.281547] Testing event ext4_load_inode: OK
[   76.331542] Testing event ext4_ext_load_extent: OK
[   76.391523] Testing event ext4_ind_map_blocks_exit: OK
[   76.451550] Testing event ext4_ext_map_blocks_exit: OK
[   76.511450] Testing event ext4_ind_map_blocks_enter: OK
[   76.571449] Testing event ext4_ext_map_blocks_enter: OK
[   76.631549] Testing event ext4_ext_convert_to_initialized_fastpath: OK
[   76.711381] Testing event ext4_ext_convert_to_initialized_enter: OK
[   76.791360] Testing event ext4_truncate_exit: OK
[   76.851384] Testing event ext4_truncate_enter: OK
[   76.911361] Testing event ext4_unlink_exit: OK
[   76.971265] Testing event ext4_unlink_enter: OK
[   77.031660] Testing event ext4_fallocate_exit: OK
[   77.091342] Testing event ext4_zero_range: OK
[   77.141332] Testing event ext4_punch_hole: OK
[   77.191268] Testing event ext4_fallocate_enter: OK
[   77.251219] Testing event ext4_direct_IO_exit: OK
[   77.311192] Testing event ext4_direct_IO_enter: OK
[   77.371251] Testing event ext4_load_inode_bitmap: OK
[   77.431405] Testing event ext4_read_block_bitmap_load: OK
[   77.501145] Testing event ext4_mb_buddy_bitmap_load: OK
[   77.561111] Testing event ext4_mb_bitmap_load: OK
[   77.621123] Testing event ext4_da_release_space: OK
[   77.681094] Testing event ext4_da_reserve_space: OK
[   77.741063] Testing event ext4_da_update_reserve_space: OK
[   77.811056] Testing event ext4_forget: OK
[   77.861271] Testing event ext4_mballoc_free: OK
[   77.921028] Testing event ext4_mballoc_discard: OK
[   77.981041] Testing event ext4_mballoc_prealloc: OK
[   78.041021] Testing event ext4_mballoc_alloc: OK
[   78.101030] Testing event ext4_alloc_da_blocks: OK
[   78.160964] Testing event ext4_sync_fs: OK
[   78.210967] Testing event ext4_sync_file_exit: OK
[   78.270891] Testing event ext4_sync_file_enter: OK
[   78.330879] Testing event ext4_free_blocks: OK
[   78.390761] Testing event ext4_allocate_blocks: OK
[   78.450874] Testing event ext4_request_blocks: OK
[   78.511176] Testing event ext4_mb_discard_preallocations: OK
[   78.580885] Testing event ext4_discard_preallocations: OK
[   78.650922] Testing event ext4_mb_release_group_pa: OK
[   78.711236] Testing event ext4_mb_release_inode_pa: OK
[   78.770983] Testing event ext4_mb_new_group_pa: OK
[   78.830994] Testing event ext4_mb_new_inode_pa: OK
[   78.890949] Testing event ext4_discard_blocks: OK
[   78.950929] Testing event ext4_journalled_invalidatepage: OK
[   79.020919] Testing event ext4_invalidatepage: OK
[   79.080937] Testing event ext4_releasepage: OK
[   79.131120] Testing event ext4_readpage: OK
[   79.180927] Testing event ext4_writepage: OK
[   79.230876] Testing event ext4_writepages_result: OK
[   79.290828] Testing event ext4_da_write_pages_extent: OK
[   79.360832] Testing event ext4_da_write_pages: OK
[   79.420826] Testing event ext4_writepages: OK
[   79.470827] Testing event ext4_da_write_end: OK
[   79.531031] Testing event ext4_journalled_write_end: OK
[   79.590828] Testing event ext4_write_end: OK
[   79.640835] Testing event ext4_da_write_begin: OK
[   79.700832] Testing event ext4_write_begin: OK
[   79.760750] Testing event ext4_begin_ordered_truncate: OK
[   79.830852] Testing event ext4_mark_inode_dirty: OK
[   79.890862] Testing event ext4_drop_inode: OK
[   79.940841] Testing event ext4_evict_inode: OK
[   80.000687] Testing event ext4_allocate_inode: OK
[   80.060747] Testing event ext4_request_inode: OK
[   80.120715] Testing event ext4_free_inode: OK
[   80.170734] Testing event ext4_other_inode_update_time: OK
[   80.240838] Testing event jbd2_lock_buffer_stall: OK
[   80.300904] Testing event jbd2_write_superblock: OK
[   80.360789] Testing event jbd2_update_log_tail: OK
[   80.420857] Testing event jbd2_checkpoint_stats: OK
[   80.480818] Testing event jbd2_run_stats: OK
[   80.530808] Testing event jbd2_handle_stats: OK
[   80.590805] Testing event jbd2_handle_extend: OK
[   80.650779] Testing event jbd2_handle_start: OK
[   80.710761] Testing event jbd2_submit_inode_data: OK
[   80.770738] Testing event jbd2_end_commit: OK
[   80.820761] Testing event jbd2_drop_transaction: OK
[   80.880750] Testing event jbd2_commit_logging: OK
[   80.940754] Testing event jbd2_commit_flushing: OK
[   81.000703] Testing event jbd2_commit_locking: OK
[   81.060653] Testing event jbd2_start_commit: OK
[   81.120632] Testing event jbd2_checkpoint: OK
[   81.170617] Testing event block_rq_remap: OK
[   81.220581] Testing event block_bio_remap: OK
[   81.270519] Testing event block_split: OK
[   81.320507] Testing event block_unplug: OK
[   81.370475] Testing event block_plug: OK
[   81.420547] Testing event block_sleeprq: OK
[   81.470421] Testing event block_getrq: OK
[   81.520492] Testing event block_bio_queue: OK
[   81.570341] Testing event block_bio_frontmerge: OK
[   81.630374] Testing event block_bio_backmerge: OK
[   81.690338] Testing event block_bio_complete: OK
[   81.750214] Testing event block_bio_bounce: OK
[   81.800176] Testing event block_rq_issue: OK
[   81.850246] Testing event block_rq_insert: OK
[   81.900224] Testing event block_rq_complete: OK
[   81.960214] Testing event block_rq_requeue: OK
[   82.010206] Testing event block_rq_abort: OK
[   82.060164] Testing event block_dirty_buffer: OK
[   82.120134] Testing event block_touch_buffer: OK
[   82.180077] Testing event urandom_read: OK
[   82.230070] Testing event random_read: OK
[   82.280075] Testing event extract_entropy_user: OK
[   82.340618] Testing event extract_entropy: OK
[   82.390063] Testing event get_random_bytes_arch: OK
[   82.450080] Testing event get_random_bytes: OK
[   82.500039] Testing event xfer_secondary_pool: OK
[   82.560063] Testing event add_disk_randomness: OK
[   82.620065] Testing event add_input_randomness: OK
[   82.680280] Testing event debit_entropy: OK
[   82.730103] Testing event push_to_pool: OK
[   82.780111] Testing event credit_entropy_bits: OK
[   82.840133] Testing event mix_pool_bytes_nolock: OK
[   82.900144] Testing event mix_pool_bytes: OK
[   82.950131] Testing event add_device_randomness: OK
[   83.010251] Testing event scsi_eh_wakeup: OK
[   83.060179] Testing event scsi_dispatch_cmd_timeout: OK
[   83.120302] Testing event scsi_dispatch_cmd_done: OK
[   83.180272] Testing event scsi_dispatch_cmd_error: OK
[   83.240262] Testing event scsi_dispatch_cmd_start: OK
[   83.300435] Testing event ata_eh_link_autopsy_qc: OK
[   83.360258] Testing event ata_eh_link_autopsy: OK
[   83.420235] Testing event ata_qc_complete_done: OK
[   83.480231] Testing event ata_qc_complete_failed: OK
[   83.540230] Testing event ata_qc_complete_internal: OK
[   83.600185] Testing event ata_qc_issue: OK
[   83.650195] Testing event udp_fail_queue_rcv_skb: OK
[   83.710180] Testing event sock_exceed_buf_limit: OK
[   83.770211] Testing event sock_rcvqueue_full: OK
[   83.830191] Testing event napi_poll: OK
[   83.880216] Testing event netif_rx_ni_entry: OK
[   83.940198] Testing event netif_rx_entry: OK
[   83.990172] Testing event netif_receive_skb_entry: OK
[   84.050157] Testing event napi_gro_receive_entry: OK
[   84.110152] Testing event napi_gro_frags_entry: OK
[   84.170448] Testing event netif_rx: OK
[   84.220127] Testing event netif_receive_skb: OK
[   84.280081] Testing event net_dev_queue: OK
[   84.330101] Testing event net_dev_xmit: OK
[   84.380036] Testing event net_dev_start_xmit: OK
[   84.439990] Testing event skb_copy_datagram_iovec: OK
[   84.500090] Testing event consume_skb: OK
[   84.550112] Testing event kfree_skb: OK
[   84.600115] Running tests on trace event systems:
[   84.641601] Testing event system skb: OK
[   84.692021] Testing event system net: OK
[   84.741248] Testing event system napi: OK
[   84.790474] Testing event system sock: OK
[   84.840550] Testing event system udp: OK
[   84.890419] Testing event system libata: OK
[   84.940794] Testing event system scsi: OK
[   84.990631] Testing event system random: OK
[   85.041621] Testing event system block: OK
[   85.091676] Testing event system jbd2: OK
[   85.141421] Testing event system ext4: OK
[   85.208122] Testing event system filelock: OK
[   85.270192] Testing event system writeback: OK
[   85.332242] Testing event system migrate: OK
[   85.390092] Testing event system compaction: OK
[   85.450804] Testing event system kmem: OK
[   85.500976] Testing event system vmscan: OK
[   85.551060] Testing event system pagemap: OK
[   85.599974] Testing event system oom: OK
[   85.649975] Testing event system filemap: OK
[   85.700060] Testing event system rpm: OK
[   85.750199] Testing event system power: OK
[   85.801606] Testing event system test: OK
[   85.849802] Testing event system module: OK
[   85.900034] Testing event system timer: OK
[   85.950775] Testing event system rcu: OK
[   85.999636] Testing event system printk: OK
[   86.049635] Testing event system lock: OK
[   86.101828] Testing event system sched: OK
[   86.151403] Testing event system workqueue: OK
[   86.209937] Testing event system signal: OK
[   86.259731] Testing event system irq: OK
[   86.310032] Testing event system task: OK
[   86.359710] Testing event system raw_syscalls: OK
[   86.419808] Running tests on all trace events:
[   86.457748] Testing all events: OK
[   86.589157] Running tests again, along with the function tracer
[   86.657872] Running tests on trace events:
[   86.704430] Testing event sys_exit: OK
[   86.846418] Testing event sys_enter: OK
[   86.916825] Testing event task_rename: OK
[   86.986856] Testing event task_newtask: OK
[   87.056905] Testing event softirq_raise: OK
[   87.136076] Testing event softirq_exit: OK
[   87.206899] Testing event softirq_entry: OK
[   87.276469] Testing event irq_handler_exit: OK
[   87.356245] Testing event irq_handler_entry: OK
[   87.436807] Testing event signal_deliver: OK
[   87.516171] Testing event signal_generate: OK
[   87.597199] Testing event workqueue_execute_end: OK
[   87.677203] Testing event workqueue_execute_start: OK
[   87.767055] Testing event workqueue_activate_work: OK
[   87.856030] Testing event workqueue_queue_work: OK
[   87.938680] Testing event sched_wake_idle_without_ipi: OK
[   88.026647] Testing event sched_swap_numa: OK
[   88.107355] Testing event sched_stick_numa: OK
[   88.186632] Testing event sched_move_numa: OK
[   88.267254] Testing event sched_process_hang: OK
[   88.347618] Testing event sched_pi_setprio: OK
[   88.426806] Testing event sched_stat_runtime: OK
[   88.506926] Testing event sched_stat_blocked: OK
[   88.585853] Testing event sched_stat_iowait: OK
[   88.666345] Testing event sched_stat_sleep: OK
[   88.745742] Testing event sched_stat_wait: OK
[   88.826333] Testing event sched_process_exec: OK
[   88.906138] Testing event sched_process_fork: OK
[   88.986086] Testing event sched_process_wait: OK
[   89.065931] Testing event sched_wait_task: OK
[   89.146330] Testing event sched_process_exit: OK
[   89.226257] Testing event sched_process_free: OK
[   89.306204] Testing event sched_migrate_task: OK
[   89.385261] Testing event sched_switch: OK
[   89.455856] Testing event sched_wakeup_new: OK
[   89.535847] Testing event sched_wakeup: OK
[   89.605581] Testing event sched_kthread_stop_ret: OK
[   89.685843] Testing event sched_kthread_stop: OK
[   89.765340] Testing event lock_release: OK
[   89.836650] Testing event lock_acquire: OK
[   89.906280] Testing event console: OK
[   89.975787] Testing event rcu_utilization: OK
[   90.055813] Testing event tick_stop: OK
[   90.125597] Testing event itimer_expire: OK
[   90.196710] Testing event itimer_state: OK
[   90.265764] Testing event hrtimer_cancel: OK
[   90.344591] Testing event hrtimer_expire_exit: OK
[   90.425925] Testing event hrtimer_expire_entry: OK
[   90.505630] Testing event hrtimer_start: OK
[   90.575413] Testing event hrtimer_init: OK
[   90.645241] Testing event timer_cancel: OK
[   90.715540] Testing event timer_expire_exit: OK
[   90.796678] Testing event timer_expire_entry: OK
[   90.875636] Testing event timer_start: OK
[   90.945160] Testing event timer_init: OK
[   91.015591] Testing event module_request: OK
[   91.094999] Testing event module_put: OK
[   91.165628] Testing event module_get: OK
[   91.235507] Testing event module_free: OK
[   91.305534] Testing event module_load: OK
[   91.375476] Testing event ftrace_test_filter: OK
[   91.454750] Testing event dev_pm_qos_remove_request: OK
[   91.544077] Testing event dev_pm_qos_update_request: OK
[   91.634392] Testing event dev_pm_qos_add_request: OK
[   91.715636] Testing event pm_qos_update_flags: OK
[   91.795782] Testing event pm_qos_update_target: OK
[   91.875571] Testing event pm_qos_update_request_timeout: OK
[   91.965768] Testing event pm_qos_remove_request: OK
[   92.045507] Testing event pm_qos_update_request: OK
[   92.125350] Testing event pm_qos_add_request: OK
[   92.205686] Testing event power_domain_target: OK
[   92.285745] Testing event clock_set_rate: OK
[   92.364950] Testing event clock_disable: OK
[   92.435373] Testing event clock_enable: OK
[   92.505786] Testing event wakeup_source_deactivate: OK
[   92.594876] Testing event wakeup_source_activate: OK
[   92.676380] Testing event suspend_resume: OK
[   92.757380] Testing event device_pm_callback_end: OK
[   92.845071] Testing event device_pm_callback_start: OK
[   92.936357] Testing event cpu_frequency: OK
[   93.014680] Testing event pstate_sample: OK
[   93.085718] Testing event cpu_idle: OK
[   93.156256] Testing event rpm_return_int: OK
[   93.235580] Testing event rpm_idle: OK
[   93.307466] Testing event rpm_resume: OK
[   93.376034] Testing event rpm_suspend: OK
[   93.445628] Testing event mm_filemap_add_to_page_cache: OK
[   93.535967] Testing event mm_filemap_delete_from_page_cache: OK
[   93.634948] Testing event oom_score_adj_update: OK
[   93.715501] Testing event mm_lru_activate: OK
[   93.796045] Testing event mm_lru_insertion: OK
[   93.875856] Testing event mm_vmscan_lru_shrink_inactive: OK
[   93.965961] Testing event mm_vmscan_writepage: OK
[   94.046141] Testing event mm_vmscan_memcg_isolate: OK
[   94.135273] Testing event mm_vmscan_lru_isolate: OK
[   94.216152] Testing event mm_shrink_slab_end: OK
[   94.295885] Testing event mm_shrink_slab_start: OK
[   94.385161] Testing event mm_vmscan_memcg_softlimit_reclaim_end: OK
[   94.485906] Testing event mm_vmscan_memcg_reclaim_end: OK
[   94.576125] Testing event mm_vmscan_direct_reclaim_end: OK
[   94.666118] Testing event mm_vmscan_memcg_softlimit_reclaim_begin: OK
[   94.766036] Testing event mm_vmscan_memcg_reclaim_begin: OK
[   94.856028] Testing event mm_vmscan_direct_reclaim_begin: OK
[   94.946439] Testing event mm_vmscan_wakeup_kswapd: OK
[   95.035847] Testing event mm_vmscan_kswapd_wake: OK
[   95.116221] Testing event mm_vmscan_kswapd_sleep: OK
[   95.205600] Testing event mm_page_alloc_extfrag: OK
[   95.286219] Testing event mm_page_pcpu_drain: OK
[   95.366593] Testing event mm_page_alloc_zone_locked: OK
[   95.455762] Testing event mm_page_alloc: OK
[   95.525340] Testing event mm_page_free_batched: OK
[   95.606228] Testing event mm_page_free: OK
[   95.676019] Testing event kmem_cache_free: OK
[   95.755885] Testing event kfree: OK
[   95.825763] Testing event kmem_cache_alloc_node: OK
[   95.905785] Testing event kmalloc_node: OK
[   95.975867] Testing event kmem_cache_alloc: OK
[   96.055990] Testing event kmalloc: OK
[   96.125163] Testing event mm_compaction_defer_reset: OK
[   96.215801] Testing event mm_compaction_defer_compaction: OK
[   96.305632] Testing event mm_compaction_deferred: OK
[   96.396934] Testing event mm_compaction_suitable: OK
[   96.483995] Testing event mm_compaction_finished: OK
[   96.565675] Testing event mm_compaction_try_to_compact_pages: OK
[   96.665407] Testing event mm_compaction_end: OK
[   96.745298] Testing event mm_compaction_begin: OK
[   96.825569] Testing event mm_compaction_migratepages: OK
[   96.915525] Testing event mm_compaction_isolate_freepages: OK
[   97.005296] Testing event mm_compaction_isolate_migratepages: OK
[   97.104508] Testing event mm_numa_migrate_ratelimit: OK
[   97.194647] Testing event mm_migrate_pages: OK
[   97.276666] Testing event writeback_dirty_inode_enqueue: OK
[   97.364846] Testing event writeback_lazytime_iput: OK
[   97.445342] Testing event writeback_lazytime: OK
[   97.524814] Testing event writeback_single_inode: OK
[   97.604807] Testing event writeback_single_inode_start: OK
[   97.696546] Testing event writeback_wait_iff_congested: OK
[   97.785326] Testing event writeback_congestion_wait: OK
[   97.875641] Testing event writeback_sb_inodes_requeue: OK
[   97.965585] Testing event balance_dirty_pages: OK
[   98.045428] Testing event bdi_dirty_ratelimit: OK
[   98.125379] Testing event global_dirty_state: OK
[   98.204602] Testing event writeback_queue_io: OK
[   98.285546] Testing event wbc_writepage: OK
[   98.364412] Testing event writeback_bdi_register: OK
[   98.445140] Testing event writeback_wake_background: OK
[   98.535318] Testing event writeback_nowork: OK
[   98.615262] Testing event writeback_pages_written: OK
[   98.705400] Testing event writeback_wait: OK
[   98.784712] Testing event writeback_written: OK
[   98.865405] Testing event writeback_start: OK
[   98.945435] Testing event writeback_exec: OK
[   99.024513] Testing event writeback_queue: OK
[   99.104783] Testing event writeback_write_inode: OK
[   99.185354] Testing event writeback_write_inode_start: OK
[   99.274915] Testing event writeback_dirty_inode: OK
[   99.354881] Testing event writeback_dirty_inode_start: OK
[   99.444878] Testing event writeback_mark_inode_dirty: OK
[   99.535924] Testing event writeback_dirty_page: OK
[   99.614313] Testing event time_out_leases: OK
[   99.694202] Testing event generic_delete_lease: OK
[   99.774628] Testing event generic_add_lease: OK
[   99.855223] Testing event break_lease_unblock: OK
[   99.935654] Testing event break_lease_block: OK
[  100.015322] Testing event break_lease_noblock: OK
[  100.094972] Testing event ext4_es_shrink: OK
[  100.173949] Testing event ext4_collapse_range: OK
[  100.255501] Testing event ext4_es_shrink_scan_exit: OK
[  100.345202] Testing event ext4_es_shrink_scan_enter: OK
[  100.434710] Testing event ext4_es_shrink_count: OK
[  100.514347] Testing event ext4_es_lookup_extent_exit: OK
[  100.605099] Testing event ext4_es_lookup_extent_enter: OK
[  100.694218] Testing event ext4_es_find_delayed_extent_range_exit: OK
[  100.795076] Testing event ext4_es_find_delayed_extent_range_enter: OK
[  100.894683] Testing event ext4_es_remove_extent: OK
[  100.976077] Testing event ext4_es_cache_extent: OK
[  101.055034] Testing event ext4_es_insert_extent: OK
[  101.135076] Testing event ext4_ext_remove_space_done: OK
[  101.224911] Testing event ext4_ext_remove_space: OK
[  101.305053] Testing event ext4_ext_rm_idx: OK
[  101.384511] Testing event ext4_ext_rm_leaf: OK
[  101.464372] Testing event ext4_remove_blocks: OK
[  101.544703] Testing event ext4_ext_show_extent: OK
[  101.624661] Testing event ext4_get_reserved_cluster_alloc: OK
[  101.714513] Testing event ext4_find_delalloc_range: OK
[  101.805083] Testing event ext4_ext_in_cache: OK
[  101.884510] Testing event ext4_ext_put_in_cache: OK
[  101.963758] Testing event ext4_get_implied_cluster_alloc_exit: OK
[  102.064704] Testing event ext4_ext_handle_unwritten_extents: OK
[  102.163732] Testing event ext4_trim_all_free: OK
[  102.244819] Testing event ext4_trim_extent: OK
[  102.324626] Testing event ext4_journal_start_reserved: OK
[  102.415156] Testing event ext4_journal_start: OK
[  102.495030] Testing event ext4_load_inode: OK
[  102.574825] Testing event ext4_ext_load_extent: OK
[  102.654188] Testing event ext4_ind_map_blocks_exit: OK
[  102.743766] Testing event ext4_ext_map_blocks_exit: OK
[  102.835166] Testing event ext4_ind_map_blocks_enter: OK
[  102.924575] Testing event ext4_ext_map_blocks_enter: OK
[  103.014833] Testing event ext4_ext_convert_to_initialized_fastpath: OK
[  103.115003] Testing event ext4_ext_convert_to_initialized_enter: OK
[  103.214633] Testing event ext4_truncate_exit: OK
[  103.294400] Testing event ext4_truncate_enter: OK
[  103.374718] Testing event ext4_unlink_exit: OK
[  103.454744] Testing event ext4_unlink_enter: OK
[  103.534984] Testing event ext4_fallocate_exit: OK
[  103.615004] Testing event ext4_zero_range: OK
[  103.695130] Testing event ext4_punch_hole: OK
[  103.774696] Testing event ext4_fallocate_enter: OK
[  103.854738] Testing event ext4_direct_IO_exit: OK
[  103.934599] Testing event ext4_direct_IO_enter: OK
[  104.014933] Testing event ext4_load_inode_bitmap: OK
[  104.103592] Testing event ext4_read_block_bitmap_load: OK
[  104.194293] Testing event ext4_mb_buddy_bitmap_load: OK
[  104.283489] Testing event ext4_mb_bitmap_load: OK
[  104.366686] Testing event ext4_da_release_space: OK
[  104.454405] Testing event ext4_da_reserve_space: OK
[  104.534622] Testing event ext4_da_update_reserve_space: OK
[  104.624146] Testing event ext4_forget: OK
[  104.694225] Testing event ext4_mballoc_free: OK
[  104.774083] Testing event ext4_mballoc_discard: OK
[  104.854586] Testing event ext4_mballoc_prealloc: OK
[  104.934319] Testing event ext4_mballoc_alloc: OK
[  105.013950] Testing event ext4_alloc_da_blocks: OK
[  105.094534] Testing event ext4_sync_fs: OK
[  105.163477] Testing event ext4_sync_file_exit: OK
[  105.243827] Testing event ext4_sync_file_enter: OK
[  105.323826] Testing event ext4_free_blocks: OK
[  105.403901] Testing event ext4_allocate_blocks: OK
[  105.484267] Testing event ext4_request_blocks: OK
[  105.563968] Testing event ext4_mb_discard_preallocations: OK
[  105.653909] Testing event ext4_discard_preallocations: OK
[  105.743852] Testing event ext4_mb_release_group_pa: OK
[  105.833193] Testing event ext4_mb_release_inode_pa: OK
[  105.922909] Testing event ext4_mb_new_group_pa: OK
[  106.004283] Testing event ext4_mb_new_inode_pa: OK
[  106.083947] Testing event ext4_discard_blocks: OK
[  106.163901] Testing event ext4_journalled_invalidatepage: OK
[  106.253766] Testing event ext4_invalidatepage: OK
[  106.334258] Testing event ext4_releasepage: OK
[  106.413420] Testing event ext4_readpage: OK
[  106.483750] Testing event ext4_writepage: OK
[  106.562724] Testing event ext4_writepages_result: OK
[  106.643919] Testing event ext4_da_write_pages_extent: OK
[  106.734042] Testing event ext4_da_write_pages: OK
[  106.813927] Testing event ext4_writepages: OK
[  106.893256] Testing event ext4_da_write_end: OK
[  106.973785] Testing event ext4_journalled_write_end: OK
[  107.063778] Testing event ext4_write_end: OK
[  107.142779] Testing event ext4_da_write_begin: OK
[  107.223942] Testing event ext4_write_begin: OK
[  107.303949] Testing event ext4_begin_ordered_truncate: OK
[  107.393917] Testing event ext4_mark_inode_dirty: OK
[  107.473714] Testing event ext4_drop_inode: OK
[  107.553864] Testing event ext4_evict_inode: OK
[  107.634110] Testing event ext4_allocate_inode: OK
[  107.713707] Testing event ext4_request_inode: OK
[  107.793700] Testing event ext4_free_inode: OK
[  107.872682] Testing event ext4_other_inode_update_time: OK
[  107.964413] Testing event jbd2_lock_buffer_stall: OK
[  108.052589] Testing event jbd2_write_superblock: OK
[  108.134023] Testing event jbd2_update_log_tail: OK
[  108.213821] Testing event jbd2_checkpoint_stats: OK
[  108.293837] Testing event jbd2_run_stats: OK
[  108.373217] Testing event jbd2_handle_stats: OK
[  108.453993] Testing event jbd2_handle_extend: OK
[  108.533763] Testing event jbd2_handle_start: OK
[  108.613748] Testing event jbd2_submit_inode_data: OK
[  108.693023] Testing event jbd2_end_commit: OK
[  108.774130] Testing event jbd2_drop_transaction: OK
[  108.853798] Testing event jbd2_commit_logging: OK
[  108.933723] Testing event jbd2_commit_flushing: OK
[  109.013645] Testing event jbd2_commit_locking: OK
[  109.094203] Testing event jbd2_start_commit: OK
[  109.173308] Testing event jbd2_checkpoint: OK
[  109.253726] Testing event block_rq_remap: OK
[  109.332293] Testing event block_bio_remap: OK
[  109.411959] Testing event block_split: OK
[  109.482391] Testing event block_unplug: OK
[  109.553243] Testing event block_plug: OK
[  109.623088] Testing event block_sleeprq: OK
[  109.693108] Testing event block_getrq: OK
[  109.762893] Testing event block_bio_queue: OK
[  109.842886] Testing event block_bio_frontmerge: OK
[  109.922661] Testing event block_bio_backmerge: OK
[  110.003006] Testing event block_bio_complete: OK
[  110.082814] Testing event block_bio_bounce: OK
[  110.162579] Testing event block_rq_issue: OK
[  110.241466] Testing event block_rq_insert: OK
[  110.321988] Testing event block_rq_complete: OK
[  110.402840] Testing event block_rq_requeue: OK
[  110.482950] Testing event block_rq_abort: OK
[  110.561228] Testing event block_dirty_buffer: OK
[  110.642624] Testing event block_touch_buffer: OK
[  110.722339] Testing event urandom_read: OK
[  110.792298] Testing event random_read: OK
[  110.861601] Testing event extract_entropy_user: OK
[  110.942452] Testing event extract_entropy: OK
[  111.021628] Testing event get_random_bytes_arch: OK
[  111.102651] Testing event get_random_bytes: OK
[  111.182403] Testing event xfer_secondary_pool: OK
[  111.262723] Testing event add_disk_randomness: OK
[  111.342563] Testing event add_input_randomness: OK
[  111.422992] Testing event debit_entropy: OK
[  111.502089] Testing event push_to_pool: OK
[  111.572673] Testing event credit_entropy_bits: OK
[  111.652736] Testing event mix_pool_bytes_nolock: OK
[  111.732756] Testing event mix_pool_bytes: OK
[  111.811723] Testing event add_device_randomness: OK
[  111.893211] Testing event scsi_eh_wakeup: OK
[  111.971948] Testing event scsi_dispatch_cmd_timeout: OK
[  112.062190] Testing event scsi_dispatch_cmd_done: OK
[  112.143319] Testing event scsi_dispatch_cmd_error: OK
[  112.231740] Testing event scsi_dispatch_cmd_start: OK
[  112.312967] Testing event ata_eh_link_autopsy_qc: OK
[  112.402338] Testing event ata_eh_link_autopsy: OK
[  112.483199] Testing event ata_qc_complete_done: OK
[  112.563143] Testing event ata_qc_complete_failed: OK
[  112.642920] Testing event ata_qc_complete_internal: OK
[  112.732158] Testing event ata_qc_issue: OK
[  112.802760] Testing event udp_fail_queue_rcv_skb: OK
[  112.883282] Testing event sock_exceed_buf_limit: OK
[  112.963089] Testing event sock_rcvqueue_full: OK
[  113.042960] Testing event napi_poll: OK
[  113.112814] Testing event netif_rx_ni_entry: OK
[  113.192948] Testing event netif_rx_entry: OK
[  113.271997] Testing event netif_receive_skb_entry: OK
[  113.361844] Testing event napi_gro_receive_entry: OK
[  113.443092] Testing event napi_gro_frags_entry: OK
[  113.523367] Testing event netif_rx: OK
[  113.593298] Testing event netif_receive_skb: OK
[  113.672997] Testing event net_dev_queue: OK
[  113.751592] Testing event net_dev_xmit: OK
[  113.823280] Testing event net_dev_start_xmit: OK
[  113.902209] Testing event skb_copy_datagram_iovec: OK
[  113.992252] Testing event consume_skb: OK
[  114.062274] Testing event kfree_skb: OK
[  114.133118] Running tests on trace event systems:
[  114.187442] Testing event system skb: OK
[  114.264996] Testing event system net: OK
[  114.346501] Testing event system napi: OK
[  114.423944] Testing event system sock: OK
[  114.494096] Testing event system udp: OK
[  114.563010] Testing event system libata: OK
[  114.645326] Testing event system scsi: OK
[  114.724733] Testing event system random: OK
[  114.810378] Testing event system block: OK
[  114.899855] Testing event system jbd2: OK
[  114.987805] Testing event system ext4: OK
[  115.117298] Testing event system filelock: OK
[  115.214523] Testing event system writeback: OK
[  115.312504] Testing event system migrate: OK
[  115.392372] Testing event system compaction: OK
[  115.476881] Testing event system kmem: OK
[  115.556920] Testing event system vmscan: OK
[  115.637185] Testing event system pagemap: OK
[  115.712797] Testing event system oom: OK
[  115.782369] Testing event system filemap: OK
[  115.861399] Testing event system rpm: OK
[  115.933380] Testing event system power: OK
[  116.021172] Testing event system test: OK
[  116.101303] Testing event system module: OK
[  116.182042] Testing event system timer: OK
[  116.266465] Testing event system rcu: OK
[  116.341334] Testing event system printk: OK
[  116.421500] Testing event system lock: OK
[  116.493689] Testing event system sched: OK
[  116.579615] Testing event system workqueue: OK
[  116.662147] Testing event system signal: OK
[  116.741294] Testing event system irq: OK
[  116.813187] Testing event system task: OK
[  116.890780] Testing event system raw_syscalls: OK
[  116.972092] Running tests on all trace events:
[  117.021995] Testing all events: OK
[  117.354619] Testing ftrace filter: OK
[  117.429868] Key type encrypted registered
[  117.467527] rtc-m48t59 rtc-m48t59.0: setting system clock to 2015-07-01 10:04:41 UTC (1435745081)
[  117.590247] EXT4-fs (sda1): couldn't mount as ext3 due to feature incompatibilities
[  117.674058] EXT4-fs (sda1): couldn't mount as ext2 due to feature incompatibilities
[  117.889225] EXT4-fs (sda1): mounted filesystem with ordered data mode. Opts: (null)
[  117.966908] VFS: Mounted root (ext4 filesystem) readonly on device 8:1.
[  118.075813] devtmpfs: mounted
[  119.782383] systemd[1]: Inserted module 'autofs4'
[  120.048093] random: systemd urandom read with 12 bits of entropy available
[  120.261179] systemd[1]: systemd 218 running in system mode. (+PAM +AUDIT +SELINUX +IMA +APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT -GNUTLS +ACL +XZ -LZ4 -SECCOMP +BLKID -ELFUTILS +KMOD -IDN)
[  120.472884] systemd[1]: Detected architecture 'sparc64'.
[  120.690424] systemd[1]: Set hostname to <u5>.
[  121.189991] systemd-system- (1135) used greatest stack depth: 6088 bytes left
[  121.743658] systemd-getty-g (1142) used greatest stack depth: 6048 bytes left
[  121.850650] systemd-fstab-g (1138) used greatest stack depth: 4360 bytes left
[  123.736686] systemd[1]: Cannot add dependency job for unit display-manager.service, ignoring: Unit display-manager.service failed to load: No such file or directory.
[  123.917121] systemd[1]: Starting Forward Password Requests to Wall Directory Watch.
[  124.001818] systemd[1]: Started Forward Password Requests to Wall Directory Watch.
[  124.080535] systemd[1]: Starting Encrypted Volumes.
[  124.198871] systemd[1]: Reached target Encrypted Volumes.
[  124.251519] systemd[1]: Expecting device dev-sda2.device...
[  124.368966] systemd[1]: Starting Remote File Systems (Pre).
[  124.498805] systemd[1]: Reached target Remote File Systems (Pre).
[  124.559509] systemd[1]: Expecting device dev-ttyS0.device...
[  124.678888] systemd[1]: Starting Root Slice.
[  124.768749] systemd[1]: Created slice Root Slice.
[  124.812997] systemd[1]: Starting udev Control Socket.
[  124.938763] systemd[1]: Listening on udev Control Socket.
[  124.990966] systemd[1]: Starting User and Session Slice.
[  125.118738] systemd[1]: Created slice User and Session Slice.
[  125.175470] systemd[1]: Starting Journal Audit Socket.
[  125.298698] systemd[1]: Listening on Journal Audit Socket.
[  125.351581] systemd[1]: Starting Syslog Socket.
[  125.448676] systemd[1]: Listening on Syslog Socket.
[  125.494599] systemd[1]: Starting udev Kernel Socket.
[  125.598641] systemd[1]: Listening on udev Kernel Socket.
[  125.649213] systemd[1]: Starting System Slice.
[  125.748622] systemd[1]: Created slice System Slice.
[  125.794069] systemd[1]: Starting system-serial\x2dgetty.slice.
[  125.928604] systemd[1]: Created slice system-serial\x2dgetty.slice.
[  125.990440] systemd[1]: Starting /dev/initctl Compatibility Named Pipe.
[  126.148567] systemd[1]: Listening on /dev/initctl Compatibility Named Pipe.
[  126.218646] systemd[1]: Starting Slices.
[  126.308538] systemd[1]: Reached target Slices.
[  126.350599] systemd[1]: Starting Journal Socket.
[  126.448530] systemd[1]: Listening on Journal Socket.
[  126.498174] systemd[1]: Mounting Huge Pages File System...
[  126.643793] systemd[1]: Starting udev Coldplug all Devices...
[  126.837907] systemd[1]: Mounting Debug File System...
[  127.055125] systemd[1]: Starting Create list of required static device nodes for the current kernel...
[  127.625167] systemd[1]: Starting File System Check on Root Device...
[  127.865083] systemd[1]: Starting Dispatch Password Requests to Console Directory Watch.
[  127.959889] systemd[1]: Started Dispatch Password Requests to Console Directory Watch.
[  128.049084] systemd[1]: Starting Paths.
[  128.138739] systemd[1]: Reached target Paths.
[  128.382494] systemd[1]: Starting Load Kernel Modules...
[  128.469511] systemd[1]: Starting Journal Socket (/dev/log).
[  128.555309] systemd[1]: Listening on Journal Socket (/dev/log).
[  128.628355] systemd[1]: Starting Journal Service...
[  128.773888] systemd[1]: Mounting POSIX Message Queue File System...
[  128.891160] systemd[1]: Starting system-getty.slice.
[  129.011774] systemd[1]: Created slice system-getty.slice.
[  129.111394] systemd[1]: Starting Delayed Shutdown Socket.
[  129.171498] systemd[1]: Listening on Delayed Shutdown Socket.
[  129.235009] systemd[1]: Starting Arbitrary Executable File Formats File System Automount Point.
[  129.358385] systemd[1]: Set up automount Arbitrary Executable File Formats File System Automount Point.
[  129.688783] fuse init (API version 7.23)
[  129.823175] systemd[1]: Started Set Up Additional Binary Formats.
[  129.929061] systemd[1]: Mounted Debug File System.
[  129.993262] systemd[1]: Mounted Huge Pages File System.
[  130.129169] systemd[1]: Mounted POSIX Message Queue File System.
[  130.597869] systemd[1]: Started Create list of required static device nodes for the current kernel.
[  131.027704] systemd[1]: Started File System Check on Root Device.
[  131.307672] systemd[1]: Started Load Kernel Modules.
[  132.387464] systemd[1]: Started udev Coldplug all Devices.
[  132.961350] systemd[1]: Mounted Configuration File System.
[  133.077462] systemd[1]: Mounting FUSE Control File System...
[  133.282297] systemd[1]: Starting Apply Kernel Variables...
[  133.567396] systemd[1]: Starting Create Static Device Nodes in /dev...
[  133.869417] systemd[1]: Mounted FUSE Control File System.
[  134.007173] systemd[1]: Started Journal Service.
[  136.606733] blk_update_request: I/O error, dev fd0, sector 0
[  136.661515] floppy: error -5 while reading block 0
[  138.289944] PCI: Enabling device: (0000:01:01.1), cmd 2
[  138.290159] sunhme.c:v3.10 August 26, 2008 David S. Miller (davem@davemloft.net)
[  138.384161] eth0: HAPPY MEAL (PCI/CheerIO) 10/100BaseT Ethernet 08:00:20:f8:c7:72
[  139.038459] sd 0:0:0:0: Attached scsi generic sg0 type 0
[  139.502610] sr 1:0:0:0: Attached scsi generic sg1 type 5
[  145.506153] Adding 1984016k swap on /dev/sda2.  Priority:-1 extents:1 across:1984016k 
[  147.080009] EXT4-fs (sda1): re-mounted. Opts: errors=remount-ro
[  148.176468] systemd-udevd (1439) used greatest stack depth: 3464 bytes left
[  148.537655] systemd-journald[1223]: Received request to flush runtime journal from PID 1
[  157.952708] eth0: Link is up using internal transceiver at 100Mb/s, Full Duplex.
[  246.900938] random: nonblocking pool is initialized

-- 
Meelis Roos (mroos@linux.ee)
