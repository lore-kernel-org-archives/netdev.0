From: mroos@linux.ee
Subject: Re: [PATCH net-next v2] rhashtable: Allow other tasks to be scheduled
 in large lookup loops
Date: Fri, 17 Jul 2015 22:07:34 +0300 (EEST)
Message-ID: <alpine.LRH.2.11.1507172204220.13702@math.ut.ee>
References: <25527e380ed6701a3c73185e28f547d6e1d5907f.1437123031.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, eric.dumazet@gmail.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.it.da.ut.ee ([193.40.5.67]:58428 "EHLO smtp2.it.da.ut.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755912AbbGQTDk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jul 2015 15:03:40 -0400
In-Reply-To: <25527e380ed6701a3c73185e28f547d6e1d5907f.1437123031.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Depending on system speed, the large lookup/insert/delete loops of the testsuite can
> take a considerable amount of time to complete causing watchdog warnings to appear.
> Allow other tasks to be scheduled throughout the loops.
> 
> Reported-by: Meelis Roos <mroos@linux.ee>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> ---
> v2: Use cond_resched() instead schedule()

Tested it. The warning is gone from rhashtable test but now it is 
present in rbtree test (it was not there before). Same kernel, just your 
patch applied - but it should not change rbtree test???

[    0.000000] PROMLIB: Sun IEEE Boot Prom 'OBP 3.31.0 2001/07/25 20:36'
[    0.000000] PROMLIB: Root node compatible: 
[    0.000000] Linux version 4.2.0-rc2-00077-gf760b87-dirty (mroos@u5) (gcc version 4.9.3 (Debian 4.9.3-1) ) #21 Fri Jul 17 20:15:21 EEST 2015
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
[    0.000000] Memory: 475912K/523432K available (5270K kernel code, 516K rwdata, 1672K rodata, 520K init, 30210K bss, 47520K reserved, 0K cma-reserved)
[    0.000000] Running RCU self tests
[    0.000000] Testing tracer nop: PASSED
[    0.000000] NR_IRQS:2048 nr_irqs:2048 1
[   26.882478] clocksource: tick: mask: 0xffffffffffffffff max_cycles: 0x5306eb473f, max_idle_ns: 440795213232 ns
[   26.986192] clocksource: mult[2c71c72] shift[24]
[   27.025729] clockevent: mult[5c28f5c3] shift[32]
[   27.067997] Console: colour dummy device 80x25
[   27.104149] console [tty0] enabled
[   27.128868] bootconsole [earlyprom0] disabled
[   27.165340] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
[   27.165405] ... MAX_LOCKDEP_SUBCLASSES:  8
[   27.165445] ... MAX_LOCK_DEPTH:          48
[   27.165486] ... MAX_LOCKDEP_KEYS:        8191
[   27.165529] ... CLASSHASH_SIZE:          4096
[   27.165574] ... MAX_LOCKDEP_ENTRIES:     32768
[   27.165617] ... MAX_LOCKDEP_CHAINS:      65536
[   27.165662] ... CHAINHASH_SIZE:          32768
[   27.165706]  memory used by lock dependency info: 8159 kB
[   27.165756]  per task-struct memory footprint: 1920 bytes
[   27.165802] ------------------------
[   27.165838] | Locking API testsuite:
[   27.165873] ----------------------------------------------------------------------------
[   27.165932]                                  | spin |wlock |rlock |mutex | wsem | rsem |
[   27.165993]   --------------------------------------------------------------------------
[   27.166092]                      A-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   27.232682]                  A-B-B-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   27.299789]              A-B-B-C-C-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   27.367295]              A-B-C-A-B-C deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   27.434877]          A-B-B-C-C-D-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   27.502857]          A-B-C-D-B-D-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   27.570913]          A-B-C-D-B-C-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   27.639030]                     double unlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   27.706053]                   initialize held:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   27.772899]                  bad unlock order:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   27.840393]   --------------------------------------------------------------------------
[   27.840491]               recursive read-lock:             |  ok  |             |  ok  |
[   27.862994]            recursive read-lock #2:             |  ok  |             |  ok  |
[   27.885492]             mixed read-write-lock:             |  ok  |             |  ok  |
[   27.908000]             mixed write-read-lock:             |  ok  |             |  ok  |
[   27.930496]   --------------------------------------------------------------------------
[   27.930594]      hard-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
[   27.964173]      soft-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
[   27.997791]      hard-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
[   28.031406]      soft-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
[   28.065035]        sirq-safe-A => hirqs-on/12:  ok  |  ok  |  ok  |
[   28.098675]        sirq-safe-A => hirqs-on/21:  ok  |  ok  |  ok  |
[   28.132309]          hard-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
[   28.165911]          soft-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
[   28.199528]          hard-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
[   28.233145]          soft-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
[   28.266773]     hard-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
[   28.300558]     soft-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
[   28.334375]     hard-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
[   28.368163]     soft-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
[   28.401968]     hard-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
[   28.435786]     soft-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
[   28.469610]     hard-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
[   28.503385]     soft-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
[   28.537166]     hard-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
[   28.570842]     soft-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
[   28.604517]     hard-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
[   28.638286]     soft-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
[   28.672064]     hard-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
[   28.705863]     soft-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
[   28.739714]     hard-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
[   28.773532]     soft-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
[   28.807368]     hard-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
[   28.841217]     soft-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
[   28.875100]     hard-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
[   28.908929]     soft-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
[   28.942758]     hard-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
[   28.976574]     soft-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
[   29.010499]     hard-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
[   29.044316]     soft-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
[   29.078152]       hard-irq lock-inversion/123:  ok  |  ok  |  ok  |
[   29.112000]       soft-irq lock-inversion/123:  ok  |  ok  |  ok  |
[   29.145894]       hard-irq lock-inversion/132:  ok  |  ok  |  ok  |
[   29.179746]       soft-irq lock-inversion/132:  ok  |  ok  |  ok  |
[   29.213631]       hard-irq lock-inversion/213:  ok  |  ok  |  ok  |
[   29.247510]       soft-irq lock-inversion/213:  ok  |  ok  |  ok  |
[   29.281418]       hard-irq lock-inversion/231:  ok  |  ok  |  ok  |
[   29.315262]       soft-irq lock-inversion/231:  ok  |  ok  |  ok  |
[   29.349134]       hard-irq lock-inversion/312:  ok  |  ok  |  ok  |
[   29.382994]       soft-irq lock-inversion/312:  ok  |  ok  |  ok  |
[   29.416906]       hard-irq lock-inversion/321:  ok  |  ok  |  ok  |
[   29.450756]       soft-irq lock-inversion/321:  ok  |  ok  |  ok  |
[   29.484624]       hard-irq read-recursion/123:  ok  |
[   29.495986]       soft-irq read-recursion/123:  ok  |
[   29.507378]       hard-irq read-recursion/132:  ok  |
[   29.518743]       soft-irq read-recursion/132:  ok  |
[   29.530133]       hard-irq read-recursion/213:  ok  |
[   29.541494]       soft-irq read-recursion/213:  ok  |
[   29.552870]       hard-irq read-recursion/231:  ok  |
[   29.564247]       soft-irq read-recursion/231:  ok  |
[   29.575630]       hard-irq read-recursion/312:  ok  |
[   29.587004]       soft-irq read-recursion/312:  ok  |
[   29.598397]       hard-irq read-recursion/321:  ok  |
[   29.609776]       soft-irq read-recursion/321:  ok  |
[   29.621160]   --------------------------------------------------------------------------
[   29.621249]   | Wound/wait tests |
[   29.621306]   ---------------------
[   29.621371]                   ww api failures:  ok  |  ok  |  ok  |
[   29.655302]                ww contexts mixing:  ok  |  ok  |
[   29.677841]              finishing ww context:  ok  |  ok  |  ok  |  ok  |
[   29.722821]                locking mismatches:  ok  |  ok  |  ok  |
[   29.756630]                  EDEADLK handling:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   29.869817]            spinlock nest unlocked:  ok  |
[   29.881116]   -----------------------------------------------------
[   29.881193]                                  |block | try  |context|
[   29.881267]   -----------------------------------------------------
[   29.881346]                           context:  ok  |  ok  |  ok  |
[   29.915341]                               try:  ok  |  ok  |  ok  |
[   29.949163]                             block:  ok  |  ok  |  ok  |
[   29.982955]                          spinlock:  ok  |  ok  |  ok  |
[   30.017142] -------------------------------------------------------
[   30.017239] Good, all 253 testcases passed! |
[   30.017306] ---------------------------------
[   30.026148] ODEBUG: selftest passed
[   30.026520] kmemleak: Early log buffer exceeded (2042), please increase DEBUG_KMEMLEAK_EARLY_LOG_SIZE
[   30.167716] Calibrating delay using timer specific routine.. 727.30 BogoMIPS (lpj=3636502)
[   30.167862] pid_max: default: 32768 minimum: 301
[   30.169425] Mount-cache hash table entries: 1024 (order: 0, 8192 bytes)
[   30.169565] Mountpoint-cache hash table entries: 1024 (order: 0, 8192 bytes)
[   30.177641] ftrace: allocating 15171 entries in 30 pages
[   30.257853] devtmpfs: initialized
[   30.301402] Performance events: No support for PMU type 'ultra12'
[   30.305277] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 19112604462750000 ns
[   30.308770] Testing tracer function: 
[   30.311509] kworker/u2:0 (11) used greatest stack depth: 8168 bytes left
[   30.468249] PASSED
[   30.468339] Testing dynamic ftrace: PASSED
[   30.748319] Testing dynamic ftrace ops #1: (1 0 1 0 0) (1 1 2 0 0) (2 1 3 0 73) (2 2 4 0 161) PASSED
[   31.038108] Testing dynamic ftrace ops #2: (1 0 1 77 0) (1 1 2 165 0) (2 1 3 1 3) (2 2 4 86 88) PASSED
[   31.335881] Testing ftrace recursion: PASSED
[   31.402866] Testing ftrace recursion safe: PASSED
[   31.470396] Testing ftrace regs(no arch support): PASSED
[   31.537829] Testing tracer irqsoff: PASSED
[   31.563853] Testing tracer function_graph: PASSED
[   31.733617] atomic64_test: passed
[   31.739606] NET: Registered protocol family 16
[   31.812981] /pci@1f,0: PCI IO[1fe02000000] MEM[1ff00000000]
[   31.813239] /pci@1f,0: SABRE PCI Bus Module ver[0:0]
[   31.813337] PCI: Scanning PBM /pci@1f,0
[   31.816979] sabre f005f9c0: PCI host bridge to bus 0000:00
[   31.817127] pci_bus 0000:00: root bus resource [io  0x1fe02000000-0x1fe02ffffff] (bus address [0x0000-0xffffff])
[   31.817291] pci_bus 0000:00: root bus resource [mem 0x1ff00000000-0x1ffffffffff] (bus address [0x00000000-0xffffffff])
[   31.817466] pci_bus 0000:00: root bus resource [bus 00-02]
[   31.843473] pci 0000:00:01.0: can't claim BAR 8 [mem 0x1ff00000000-0x1ffbfffffff]: address conflict with Video RAM area [??? 0x1ff000a0000-0x1ff000bffff flags 0x80000000]
[   31.921366] kworker/u2:1 (20) used greatest stack depth: 7896 bytes left
[   32.212004] vgaarb: device added: PCI:0000:01:02.0,decodes=io+mem,owns=none,locks=none
[   32.212179] vgaarb: loaded
[   32.212240] vgaarb: bridge control possible 0000:01:02.0
[   32.215255] SCSI subsystem initialized
[   32.227747] libata version 3.00 loaded.
[   32.241232] /pci@1f,0/pci@1,1/ebus@1/eeprom@14,0: Mostek regs at 0x1fff1000000
[   32.446414] DMA-API: preallocated 32768 debug entries
[   32.446532] DMA-API: debugging enabled by kernel config
[   32.447868] AUXIO: Found device at /pci@1f,0/pci@1,1/ebus@1/auxio@14,726000
[   32.449072] clocksource: Switched to clocksource tick
[   33.122262] NET: Registered protocol family 2
[   33.128387] TCP established hash table entries: 4096 (order: 2, 32768 bytes)
[   33.128769] TCP bind hash table entries: 4096 (order: 5, 262144 bytes)
[   33.132231] TCP: Hash tables configured (established 4096 bind 4096)
[   33.133737] UDP hash table entries: 256 (order: 2, 40960 bytes)
[   33.134394] UDP-Lite hash table entries: 256 (order: 2, 40960 bytes)
[   33.137508] NET: Registered protocol family 1
[   33.138194] PCI: CLS 64 bytes, default 64
[   33.140569] power: Control reg at 1fff1724000
[   33.164530] futex hash table entries: 256 (order: 1, 20480 bytes)
[   33.165052] Initialise system trusted keyring
[   33.166138] ====[ backtrace testing ]===========
[   33.166211] Testing a backtrace from process context.
[   33.166275] The following trace is a kernel self test and not a bug!
[   33.166367] CPU: 0 PID: 1 Comm: swapper Not tainted 4.2.0-rc2-00077-gf760b87-dirty #21
[   33.166453] Call Trace:
[   33.166534]  [00000000004d2870] backtrace_regression_test+0x30/0x100
[   33.166640]  [0000000000426e2c] do_one_initcall+0xec/0x1e0
[   33.166743]  [0000000000b58b60] kernel_init_freeable+0x114/0x1c4
[   33.166859]  [000000000091c1ec] kernel_init+0xc/0x100
[   33.166968]  [0000000000405fe4] ret_from_fork+0x1c/0x2c
[   33.167053]  [0000000000000000]           (null)
[   33.167124] Testing a backtrace from irq context.
[   33.167186] The following trace is a kernel self test and not a bug!
[   33.169165] CPU: 0 PID: 10 Comm: kworker/u2:1 Not tainted 4.2.0-rc2-00077-gf760b87-dirty #21
[   33.169307] Workqueue: khelper __call_usermodehelper
[   33.169399] Call Trace:
[   33.169494]  [00000000004d280c] backtrace_test_irq_callback+0xc/0x40
[   33.169602]  [0000000000460118] tasklet_action+0x78/0xe0
[   33.169697]  [000000000045f378] __do_softirq+0x278/0x680
[   33.169802]  [000000000042be28] do_softirq_own_stack+0x28/0x40
[   33.169900]  [000000000045fa6c] irq_exit+0x4c/0xc0
[   33.170007]  [0000000000929910] timer_interrupt+0x70/0xa0
[   33.170104]  [0000000000426b34] sys_call_table+0x5b8/0x744
[   33.170206]  [00000000006f352c] clear_page_common+0x54/0x80
[   33.170310]  [000000000052bca8] __alloc_pages_nodemask+0x148/0xa60
[   33.170410]  [000000000052c8fc] alloc_kmem_pages_node+0x1c/0x40
[   33.170511]  [0000000000458cd4] copy_process.isra.47+0xf4/0x1580
[   33.170608]  [000000000045a28c] _do_fork+0x6c/0x7c0
[   33.170699]  [000000000045aa48] kernel_thread+0x28/0x40
[   33.170799]  [000000000047171c] __call_usermodehelper+0x3c/0x80
[   33.170899]  [000000000047639c] process_one_work+0x3dc/0x800
[   33.170995]  [0000000000476ad0] worker_thread+0x310/0x500
[   33.186175] Testing a saved backtrace.
[   33.186268] The following trace is a kernel self test and not a bug!
[   33.186346]  [<00000000004d290c>] backtrace_regression_test+0xcc/0x100
[   33.186497]  [<0000000000426e2c>] do_one_initcall+0xec/0x1e0
[   33.186614]  [<0000000000b58b60>] kernel_init_freeable+0x114/0x1c4
[   33.186736]  [<000000000091c1ec>] kernel_init+0xc/0x100
[   33.186855]  [<0000000000405fe4>] ret_from_fork+0x1c/0x2c
[   33.186974]  [<          (null)>]           (null)
[   33.187061] ====[ end of backtrace testing ]====
[   33.187292] audit: initializing netlink subsys (disabled)
[   33.188439] audit: type=2000 audit(5.630:1): initialized
[   33.203418] HugeTLB registered 8 MB page size, pre-allocated 0 pages
[   33.216884] Key type big_key registered
[   33.253244] io scheduler noop registered
[   33.253690] io scheduler cfq registered (default)
[   33.253830] start plist test
[   33.277753] end plist test
[   33.277825] test_string_helpers: Running tests...
[   33.284353] Running rhashtable test nelem=8, max_size=65536, shrinking=0
[   33.284453] Test 00:
[   33.393788]   Adding 50000 keys
[   35.520471]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[   36.463930]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[   36.464060]   Deleting 50000 keys
[   37.299798]   Duration of test: 3906469241 ns
[   37.301050] Test 01:
[   37.410517]   Adding 50000 keys
[   39.539627]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[   40.483583]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[   40.483714]   Deleting 50000 keys
[   41.318696]   Duration of test: 3908637840 ns
[   41.319906] Test 02:
[   41.429373]   Adding 50000 keys
[   43.555317]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[   44.498058]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[   44.498188]   Deleting 50000 keys
[   45.332522]   Duration of test: 3903606299 ns
[   45.333733] Test 03:
[   45.443216]   Adding 50000 keys
[   47.569233]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[   48.511179]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[   48.511309]   Deleting 50000 keys
[   49.346186]   Duration of test: 3903425713 ns
[   49.347555] Average test time: 3905534773
[   49.348144] rbtree testing -> 74807 cycles
[   70.333187] NMI watchdog: BUG: soft lockup - CPU#0 stuck for 22s! [swapper:1]
[   70.333401] Modules linked in:
[   70.333499] irq event stamp: 2018938
[   70.333584] hardirqs last  enabled at (2018937): [<0000000000404b1c>] rtrap_xcall+0x18/0x20
[   70.333770] hardirqs last disabled at (2018938): [<0000000000426b28>] sys_call_table+0x5ac/0x744
[   70.333967] softirqs last  enabled at (2018936): [<000000000045f5fc>] __do_softirq+0x4fc/0x680
[   70.334168] softirqs last disabled at (2018929): [<000000000042be28>] do_softirq_own_stack+0x28/0x40
[   70.334394] CPU: 0 PID: 1 Comm: swapper Not tainted 4.2.0-rc2-00077-gf760b87-dirty #21
[   70.334499] task: fffff8001f09ef60 ti: fffff8001f0fc000 task.ti: fffff8001f0fc000
[   70.334626] TSTATE: 0000009980001607 TPC: 00000000006e7a3c TNPC: 00000000006e7a40 Y: 00000000    Not tainted
[   70.334811] TPC: <rb_next+0x7c/0xa0>
[   70.334902] g0: 0000000000426b28 g1: 00000000029273d8 g2: 00000000029273d8 g3: 0000000002927310
[   70.335056] g4: fffff8001f09ef60 g5: 0000000000000000 g6: fffff8001f0fc000 g7: 0000000002927310
[   70.335210] o0: 0000000000000001 o1: fffff8001f0fc3f8 o2: 0000000000921a38 o3: 0000000000000000
[   70.335365] o4: 0000000000000000 o5: 0000000000b1c800 sp: fffff8001f0ff231 ret_pc: 0000000000404b1c
[   70.335533] RPC: <rtrap_xcall+0x18/0x20>
[   70.335628] l0: 0000000000001000 l1: 0000000080001606 l2: 0000000000921a34 l3: 0000000000000400
[   70.335754] l4: 0000000000000000 l5: 0000000000000000 l6: 0000000000000000 l7: 0000000000000008
[   70.335879] i0: 0000000002927130 i1: 0000000002927420 i2: 000000052604be08 i3: 0000000582c429c9
[   70.336005] i4: 0000000002926a00 i5: 0000000002926a01 i6: fffff8001f0ff2e1 i7: 0000000000921adc
[   70.336142] I7: <check+0x130/0x2d8>
[   70.336214] Call Trace:
[   70.336301]  [0000000000921adc] check+0x130/0x2d8
[   70.336420]  [0000000000b7cf18] rbtree_test_init+0x124/0x264
[   70.336544]  [0000000000426e2c] do_one_initcall+0xec/0x1e0
[   70.336675]  [0000000000b58b60] kernel_init_freeable+0x114/0x1c4
[   70.336812]  [000000000091c1ec] kernel_init+0xc/0x100
[   70.336939]  [0000000000405fe4] ret_from_fork+0x1c/0x2c
[   70.337045]  [0000000000000000]           (null)
[   70.606757] augmented rbtree testing -> 54275 cycles
[   86.305230] PCI: Enabling device: (0000:01:02.0), cmd 82
[   86.305404] atyfb: 3D RAGE PRO (Mach64 GP, PQFP, PCI) [0x4750 rev 0x7c]
[   86.305551] atyfb: 4M SGRAM (1:1), 14.31818 MHz XTAL, 230 MHz PLL, 100 Mhz MCLK, 100 MHz XCLK
[   86.369992] Console: switching to colour frame buffer device 80x30
[   86.382675] atyfb: fb0: ATY Mach64 frame buffer device on PCI
[   86.411787] f0061c64: ttyS0 at MMIO 0x1fff1400000 (irq = 5, base_baud = 115200) is a SAB82532 V3.2
[   86.420984] Console: ttyS0 (SAB82532)
[  103.575130] console [ttyS0] enabled
[  103.615226] f0061c64: ttyS1 at MMIO 0x1fff1400040 (irq = 5, base_baud = 115200) is a SAB82532 V3.2
[  104.070027] Floppy drive(s): fd0 is 1.44M
[  104.266698] loop: module loaded
[  104.350297] scsi host0: pata_cmd64x
[  104.390818] scsi host1: pata_cmd64x
[  104.423873] ata1: PATA max MWDMA2 cmd 0x1fe02c00000 ctl 0x1fe02c00008 bmdma 0x1fe02c00020 irq 14
[  104.520242] ata2: PATA max MWDMA2 cmd 0x1fe02c00010 ctl 0x1fe02c00018 bmdma 0x1fe02c00028 irq 14
[  104.622786] pata_cmd64x: active 10 recovery 10 setup 3.
[  104.622908] pata_cmd64x: active 10 recovery 10 setup 3.
[  104.637447] FDC 0 is a National Semiconductor PC87306
[  104.688758] mousedev: PS/2 mouse device common for all mice
[  104.770560] rtc-m48t59 rtc-m48t59.0: rtc core: registered m48t59 as rtc0
[  104.844445] NET: Registered protocol family 10
[  104.911225] ata1.00: ATA-6: ST3120026A, 3.06, max UDMA/100
[  104.964706] ata1.00: 234441648 sectors, multi 0: LBA48 
[  105.014998] pata_cmd64x: active 3 recovery 1 setup 1.
[  105.015094] pata_cmd64x: active 3 recovery 1 setup 1.
[  105.042768] NET: Registered protocol family 17
[  105.088267] ata1.00: configured for MWDMA2
[  105.130117] scsi 0:0:0:0: Direct-Access     ATA      ST3120026A       3.06 PQ: 0 ANSI: 5
[  105.231225] sd 0:0:0:0: [sda] 234441648 512-byte logical blocks: (120 GB/111 GiB)
[  105.310038] sd 0:0:0:0: [sda] Write Protect is off
[  105.354869] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[  105.355534] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  105.464628] pata_cmd64x: active 10 recovery 10 setup 3.
[  105.464706] pata_cmd64x: active 10 recovery 10 setup 3.
[  105.486362] Loading compiled-in X.509 certificates
[  105.531723] registered taskstats version 1
[  105.568193] Running tests on trace events:
[  105.604489] Testing event sys_exit: 
[  105.631832] ata2.00: ATAPI: CRD-8322B, 1.06, max MWDMA2
[  105.686562] pata_cmd64x: active 3 recovery 1 setup 1.
[  105.686657] pata_cmd64x: active 3 recovery 1 setup 1.
[  105.699521] ata2.00: configured for MWDMA2
[  105.739853] OK
[  105.746950] Testing event sys_enter: 
[  105.783288] scsi 1:0:0:0: CD-ROM               LG    CD-ROM CRD-8322B 1.06 PQ: 0 ANSI: 5
[  105.874726]  sda: sda1 sda2 sda3
[  105.909065] OK
[  105.915753] Testing event task_rename: 
[  105.969072] sd 0:0:0:0: [sda] Attached SCSI disk
[  106.020084] OK
[  106.026640] Testing event task_newtask: OK
[  106.085748] Testing event softirq_raise: 
[  106.121495] sr 1:0:0:0: [sr0] scsi3-mmc drive: 32x/32x cd/rw xa/form2 cdda tray
[  106.200669] cdrom: Uniform CD-ROM driver Revision: 3.20
[  106.260064] OK
[  106.266648] Testing event softirq_exit: 
[  106.304243] sr 1:0:0:0: Attached scsi CD-ROM sr0
[  106.320463] OK
[  106.326825] Testing event softirq_entry: OK
[  106.385469] Testing event irq_handler_exit: OK
[  106.445229] Testing event irq_handler_entry: OK
[  106.504686] Testing event signal_deliver: OK
[  106.554947] Testing event signal_generate: OK
[  106.614542] Testing event workqueue_execute_end: OK
[  106.674956] Testing event workqueue_execute_start: OK
[  106.734784] Testing event workqueue_activate_work: OK
[  106.794474] Testing event workqueue_queue_work: OK
[  106.854831] Testing event sched_wake_idle_without_ipi: OK
[  106.924393] Testing event sched_swap_numa: OK
[  106.974592] Testing event sched_stick_numa: OK
[  107.034424] Testing event sched_move_numa: OK
[  107.094169] Testing event sched_process_hang: OK
[  107.154236] Testing event sched_pi_setprio: OK
[  107.214197] Testing event sched_stat_runtime: OK
[  107.274222] Testing event sched_stat_blocked: OK
[  107.334016] Testing event sched_stat_iowait: OK
[  107.393735] Testing event sched_stat_sleep: OK
[  107.454023] Testing event sched_stat_wait: OK
[  107.503736] Testing event sched_process_exec: OK
[  107.563682] Testing event sched_process_fork: OK
[  107.623558] Testing event sched_process_wait: OK
[  107.683573] Testing event sched_wait_task: OK
[  107.733430] Testing event sched_process_exit: OK
[  107.793375] Testing event sched_process_free: OK
[  107.853310] Testing event sched_migrate_task: OK
[  107.913307] Testing event sched_switch: OK
[  107.963075] Testing event sched_wakeup_new: OK
[  108.013278] Testing event sched_wakeup: OK
[  108.063318] Testing event sched_kthread_stop_ret: OK
[  108.123234] Testing event sched_kthread_stop: OK
[  108.183207] Testing event lock_release: OK
[  108.234462] Testing event lock_acquire: OK
[  108.284387] Testing event console: OK
[  108.333092] Testing event rcu_utilization: OK
[  108.382889] Testing event tick_stop: OK
[  108.433211] Testing event itimer_expire: OK
[  108.483094] Testing event itimer_state: OK
[  108.533070] Testing event hrtimer_cancel: OK
[  108.583170] Testing event hrtimer_expire_exit: OK
[  108.643073] Testing event hrtimer_expire_entry: OK
[  108.703160] Testing event hrtimer_start: OK
[  108.753062] Testing event hrtimer_init: OK
[  108.803047] Testing event timer_cancel: OK
[  108.853126] Testing event timer_expire_exit: OK
[  108.913143] Testing event timer_expire_entry: OK
[  108.973140] Testing event timer_start: OK
[  109.023135] Testing event timer_init: OK
[  109.073098] Testing event module_request: OK
[  109.122808] Testing event module_put: OK
[  109.173113] Testing event module_get: OK
[  109.223055] Testing event module_free: OK
[  109.273029] Testing event module_load: OK
[  109.323021] Testing event ftrace_test_filter: OK
[  109.382997] Testing event dev_pm_qos_remove_request: OK
[  109.442735] Testing event dev_pm_qos_update_request: OK
[  109.502988] Testing event dev_pm_qos_add_request: OK
[  109.563219] Testing event pm_qos_update_flags: OK
[  109.623032] Testing event pm_qos_update_target: OK
[  109.682991] Testing event pm_qos_update_request_timeout: OK
[  109.752974] Testing event pm_qos_remove_request: OK
[  109.812963] Testing event pm_qos_update_request: OK
[  109.872941] Testing event pm_qos_add_request: OK
[  109.932932] Testing event power_domain_target: OK
[  109.993140] Testing event clock_set_rate: OK
[  110.042762] Testing event clock_disable: OK
[  110.093046] Testing event clock_enable: OK
[  110.142937] Testing event wakeup_source_deactivate: OK
[  110.202757] Testing event wakeup_source_activate: OK
[  110.263059] Testing event suspend_resume: OK
[  110.312987] Testing event device_pm_callback_end: OK
[  110.373106] Testing event device_pm_callback_start: OK
[  110.433093] Testing event cpu_frequency: OK
[  110.483002] Testing event pstate_sample: OK
[  110.532992] Testing event cpu_idle: OK
[  110.583128] Testing event rpm_return_int: OK
[  110.633151] Testing event rpm_idle: OK
[  110.682855] Testing event rpm_resume: OK
[  110.733126] Testing event rpm_suspend: OK
[  110.783057] Testing event mm_filemap_add_to_page_cache: OK
[  110.853114] Testing event mm_filemap_delete_from_page_cache: OK
[  110.922806] Testing event oom_score_adj_update: OK
[  110.983137] Testing event mm_lru_activate: OK
[  111.033367] Testing event mm_lru_insertion: OK
[  111.092916] Testing event mm_vmscan_lru_shrink_inactive: OK
[  111.163147] Testing event mm_vmscan_writepage: OK
[  111.222974] Testing event mm_vmscan_memcg_isolate: OK
[  111.283267] Testing event mm_vmscan_lru_isolate: OK
[  111.342928] Testing event mm_shrink_slab_end: OK
[  111.403224] Testing event mm_shrink_slab_start: OK
[  111.463306] Testing event mm_vmscan_memcg_softlimit_reclaim_end: OK
[  111.543154] Testing event mm_vmscan_memcg_reclaim_end: OK
[  111.613139] Testing event mm_vmscan_direct_reclaim_end: OK
[  111.683139] Testing event mm_vmscan_memcg_softlimit_reclaim_begin: OK
[  111.763139] Testing event mm_vmscan_memcg_reclaim_begin: OK
[  111.832917] Testing event mm_vmscan_direct_reclaim_begin: OK
[  111.903252] Testing event mm_vmscan_wakeup_kswapd: OK
[  111.962924] Testing event mm_vmscan_kswapd_wake: OK
[  112.023234] Testing event mm_vmscan_kswapd_sleep: OK
[  112.083087] Testing event mm_page_alloc_extfrag: OK
[  112.143189] Testing event mm_page_pcpu_drain: OK
[  112.202869] Testing event mm_page_alloc_zone_locked: OK
[  112.263207] Testing event mm_page_alloc: OK
[  112.313205] Testing event mm_page_free_batched: OK
[  112.373147] Testing event mm_page_free: OK
[  112.422881] Testing event kmem_cache_free: OK
[  112.473131] Testing event kfree: OK
[  112.513005] Testing event kmem_cache_alloc_node: OK
[  112.573023] Testing event kmalloc_node: OK
[  112.622991] Testing event kmem_cache_alloc: OK
[  112.682746] Testing event kmalloc: OK
[  112.733056] Testing event mm_compaction_defer_reset: OK
[  112.792972] Testing event mm_compaction_defer_compaction: OK
[  112.862928] Testing event mm_compaction_deferred: OK
[  112.922937] Testing event mm_compaction_suitable: OK
[  112.982629] Testing event mm_compaction_finished: OK
[  113.042882] Testing event mm_compaction_try_to_compact_pages: OK
[  113.112768] Testing event mm_compaction_end: OK
[  113.172827] Testing event mm_compaction_begin: OK
[  113.232762] Testing event mm_compaction_migratepages: OK
[  113.302834] Testing event mm_compaction_isolate_freepages: OK
[  113.372389] Testing event mm_compaction_isolate_migratepages: OK
[  113.442686] Testing event mm_numa_migrate_ratelimit: OK
[  113.502845] Testing event mm_migrate_pages: OK
[  113.562432] Testing event writeback_dirty_inode_enqueue: OK
[  113.632776] Testing event writeback_lazytime_iput: OK
[  113.692761] Testing event writeback_lazytime: OK
[  113.752733] Testing event writeback_single_inode: OK
[  113.812719] Testing event writeback_single_inode_start: OK
[  113.882483] Testing event writeback_wait_iff_congested: OK
[  113.952775] Testing event writeback_congestion_wait: OK
[  114.012454] Testing event writeback_sb_inodes_requeue: OK
[  114.082742] Testing event balance_dirty_pages: OK
[  114.142648] Testing event bdi_dirty_ratelimit: OK
[  114.202426] Testing event global_dirty_state: OK
[  114.262735] Testing event writeback_queue_io: OK
[  114.322581] Testing event wbc_writepage: OK
[  114.372596] Testing event writeback_bdi_register: OK
[  114.432605] Testing event writeback_wake_background: OK
[  114.492413] Testing event writeback_nowork: OK
[  114.552743] Testing event writeback_pages_written: OK
[  114.612400] Testing event writeback_wait: OK
[  114.662686] Testing event writeback_written: OK
[  114.722678] Testing event writeback_start: OK
[  114.772652] Testing event writeback_exec: OK
[  114.822600] Testing event writeback_queue: OK
[  114.872262] Testing event writeback_write_inode: OK
[  114.932510] Testing event writeback_write_inode_start: OK
[  115.002442] Testing event writeback_dirty_inode: OK
[  115.062386] Testing event writeback_dirty_inode_start: OK
[  115.132132] Testing event writeback_mark_inode_dirty: OK
[  115.202358] Testing event writeback_dirty_page: OK
[  115.262358] Testing event time_out_leases: OK
[  115.312176] Testing event generic_delete_lease: OK
[  115.372495] Testing event generic_add_lease: OK
[  115.432366] Testing event break_lease_unblock: OK
[  115.492363] Testing event break_lease_block: OK
[  115.552087] Testing event break_lease_noblock: OK
[  115.612572] Testing event ext4_es_shrink: OK
[  115.662248] Testing event ext4_insert_range: OK
[  115.722027] Testing event ext4_collapse_range: OK
[  115.782316] Testing event ext4_es_shrink_scan_exit: OK
[  115.842190] Testing event ext4_es_shrink_scan_enter: OK
[  115.902143] Testing event ext4_es_shrink_count: OK
[  115.961910] Testing event ext4_es_lookup_extent_exit: OK
[  116.032014] Testing event ext4_es_lookup_extent_enter: OK
[  116.102181] Testing event ext4_es_find_delayed_extent_range_exit: OK
[  116.182225] Testing event ext4_es_find_delayed_extent_range_enter: OK
[  116.262198] Testing event ext4_es_remove_extent: OK
[  116.322255] Testing event ext4_es_cache_extent: OK
[  116.381947] Testing event ext4_es_insert_extent: OK
[  116.442454] Testing event ext4_ext_remove_space_done: OK
[  116.512268] Testing event ext4_ext_remove_space: OK
[  116.572233] Testing event ext4_ext_rm_idx: OK
[  116.622236] Testing event ext4_ext_rm_leaf: OK
[  116.682181] Testing event ext4_remove_blocks: OK
[  116.741946] Testing event ext4_ext_show_extent: OK
[  116.802124] Testing event ext4_get_reserved_cluster_alloc: OK
[  116.872121] Testing event ext4_find_delalloc_range: OK
[  116.932144] Testing event ext4_ext_in_cache: OK
[  116.991916] Testing event ext4_ext_put_in_cache: OK
[  117.052338] Testing event ext4_get_implied_cluster_alloc_exit: OK
[  117.132178] Testing event ext4_ext_handle_unwritten_extents: OK
[  117.202189] Testing event ext4_trim_all_free: OK
[  117.262223] Testing event ext4_trim_extent: OK
[  117.322190] Testing event ext4_journal_start_reserved: OK
[  117.392286] Testing event ext4_journal_start: OK
[  117.452392] Testing event ext4_load_inode: OK
[  117.502284] Testing event ext4_ext_load_extent: OK
[  117.562264] Testing event ext4_ind_map_blocks_exit: OK
[  117.622298] Testing event ext4_ext_map_blocks_exit: OK
[  117.682195] Testing event ext4_ind_map_blocks_enter: OK
[  117.741884] Testing event ext4_ext_map_blocks_enter: OK
[  117.802092] Testing event ext4_ext_convert_to_initialized_fastpath: OK
[  117.882129] Testing event ext4_ext_convert_to_initialized_enter: OK
[  117.961889] Testing event ext4_truncate_exit: OK
[  118.022123] Testing event ext4_truncate_enter: OK
[  118.082106] Testing event ext4_unlink_exit: OK
[  118.142100] Testing event ext4_unlink_enter: OK
[  118.201872] Testing event ext4_fallocate_exit: OK
[  118.262277] Testing event ext4_zero_range: OK
[  118.311856] Testing event ext4_punch_hole: OK
[  118.362100] Testing event ext4_fallocate_enter: OK
[  118.421952] Testing event ext4_direct_IO_exit: OK
[  118.481921] Testing event ext4_direct_IO_enter: OK
[  118.541991] Testing event ext4_load_inode_bitmap: OK
[  118.601830] Testing event ext4_read_block_bitmap_load: OK
[  118.671570] Testing event ext4_mb_buddy_bitmap_load: OK
[  118.731846] Testing event ext4_mb_bitmap_load: OK
[  118.791754] Testing event ext4_da_release_space: OK
[  118.851514] Testing event ext4_da_reserve_space: OK
[  118.911795] Testing event ext4_da_update_reserve_space: OK
[  118.981790] Testing event ext4_forget: OK
[  119.031797] Testing event ext4_mballoc_free: OK
[  119.091966] Testing event ext4_mballoc_discard: OK
[  119.151564] Testing event ext4_mballoc_prealloc: OK
[  119.211758] Testing event ext4_mballoc_alloc: OK
[  119.271455] Testing event ext4_alloc_da_blocks: OK
[  119.331703] Testing event ext4_sync_fs: OK
[  119.381707] Testing event ext4_sync_file_exit: OK
[  119.441419] Testing event ext4_sync_file_enter: OK
[  119.501617] Testing event ext4_free_blocks: OK
[  119.561500] Testing event ext4_allocate_blocks: OK
[  119.621627] Testing event ext4_request_blocks: OK
[  119.681606] Testing event ext4_mb_discard_preallocations: OK
[  119.751621] Testing event ext4_discard_preallocations: OK
[  119.821659] Testing event ext4_mb_release_group_pa: OK
[  119.881454] Testing event ext4_mb_release_inode_pa: OK
[  119.941614] Testing event ext4_mb_new_group_pa: OK
[  120.001639] Testing event ext4_mb_new_inode_pa: OK
[  120.061587] Testing event ext4_discard_blocks: OK
[  120.121663] Testing event ext4_journalled_invalidatepage: OK
[  120.191658] Testing event ext4_invalidatepage: OK
[  120.251674] Testing event ext4_releasepage: OK
[  120.311235] Testing event ext4_readpage: OK
[  120.361663] Testing event ext4_writepage: OK
[  120.411622] Testing event ext4_writepages_result: OK
[  120.471256] Testing event ext4_da_write_pages_extent: OK
[  120.541577] Testing event ext4_da_write_pages: OK
[  120.601555] Testing event ext4_writepages: OK
[  120.651254] Testing event ext4_da_write_end: OK
[  120.711563] Testing event ext4_journalled_write_end: OK
[  120.771566] Testing event ext4_write_end: OK
[  120.821568] Testing event ext4_da_write_begin: OK
[  120.881567] Testing event ext4_write_begin: OK
[  120.941482] Testing event ext4_begin_ordered_truncate: OK
[  121.011592] Testing event ext4_mark_inode_dirty: OK
[  121.071597] Testing event ext4_drop_inode: OK
[  121.121581] Testing event ext4_evict_inode: OK
[  121.181105] Testing event ext4_allocate_inode: OK
[  121.241577] Testing event ext4_request_inode: OK
[  121.301442] Testing event ext4_free_inode: OK
[  121.351253] Testing event ext4_other_inode_update_time: OK
[  121.421776] Testing event jbd2_lock_buffer_stall: OK
[  121.481529] Testing event jbd2_write_superblock: OK
[  121.541309] Testing event jbd2_update_log_tail: OK
[  121.601584] Testing event jbd2_checkpoint_stats: OK
[  121.661546] Testing event jbd2_run_stats: OK
[  121.711540] Testing event jbd2_handle_stats: OK
[  121.771226] Testing event jbd2_handle_extend: OK
[  121.831515] Testing event jbd2_handle_start: OK
[  121.891183] Testing event jbd2_submit_inode_data: OK
[  121.951475] Testing event jbd2_end_commit: OK
[  122.001486] Testing event jbd2_drop_transaction: OK
[  122.061475] Testing event jbd2_commit_logging: OK
[  122.121477] Testing event jbd2_commit_flushing: OK
[  122.181426] Testing event jbd2_commit_locking: OK
[  122.241376] Testing event jbd2_start_commit: OK
[  122.301567] Testing event jbd2_checkpoint: OK
[  122.351134] Testing event block_rq_remap: OK
[  122.401307] Testing event block_bio_remap: OK
[  122.451048] Testing event block_split: OK
[  122.501445] Testing event block_unplug: OK
[  122.551212] Testing event block_plug: OK
[  122.601282] Testing event block_sleeprq: OK
[  122.650936] Testing event block_getrq: OK
[  122.701428] Testing event block_bio_queue: OK
[  122.751071] Testing event block_bio_frontmerge: OK
[  122.811001] Testing event block_bio_backmerge: OK
[  122.870972] Testing event block_bio_complete: OK
[  122.930943] Testing event block_bio_bounce: OK
[  122.980703] Testing event block_rq_issue: OK
[  123.030989] Testing event block_rq_insert: OK
[  123.080953] Testing event block_rq_complete: OK
[  123.140943] Testing event block_rq_requeue: OK
[  123.200732] Testing event block_rq_abort: OK
[  123.250898] Testing event block_dirty_buffer: OK
[  123.310755] Testing event block_touch_buffer: OK
[  123.370813] Testing event urandom_read: OK
[  123.420807] Testing event random_read: OK
[  123.470594] Testing event extract_entropy_user: OK
[  123.530830] Testing event extract_entropy: OK
[  123.581114] Testing event get_random_bytes_arch: OK
[  123.640603] Testing event get_random_bytes: OK
[  123.690776] Testing event xfer_secondary_pool: OK
[  123.750797] Testing event add_disk_randomness: OK
[  123.810581] Testing event add_input_randomness: OK
[  123.870912] Testing event debit_entropy: OK
[  123.920839] Testing event push_to_pool: OK
[  123.970842] Testing event credit_entropy_bits: OK
[  124.030862] Testing event mix_pool_bytes_nolock: OK
[  124.090878] Testing event mix_pool_bytes: OK
[  124.140653] Testing event add_device_randomness: OK
[  124.200986] Testing event scsi_eh_wakeup: OK
[  124.250900] Testing event scsi_dispatch_cmd_timeout: OK
[  124.310921] Testing event scsi_dispatch_cmd_done: OK
[  124.371006] Testing event scsi_dispatch_cmd_error: OK
[  124.430988] Testing event scsi_dispatch_cmd_start: OK
[  124.490957] Testing event ata_eh_link_autopsy_qc: OK
[  124.550983] Testing event ata_eh_link_autopsy: OK
[  124.611169] Testing event ata_qc_complete_done: OK
[  124.670954] Testing event ata_qc_complete_failed: OK
[  124.730641] Testing event ata_qc_complete_internal: OK
[  124.790917] Testing event ata_qc_issue: OK
[  124.840919] Testing event udp_fail_queue_rcv_skb: OK
[  124.900909] Testing event sock_exceed_buf_limit: OK
[  124.960940] Testing event sock_rcvqueue_full: OK
[  125.021118] Testing event napi_poll: OK
[  125.070941] Testing event netif_rx_ni_entry: OK
[  125.130911] Testing event netif_rx_entry: OK
[  125.180680] Testing event netif_receive_skb_entry: OK
[  125.240980] Testing event napi_gro_receive_entry: OK
[  125.300660] Testing event napi_gro_frags_entry: OK
[  125.360962] Testing event netif_rx: OK
[  125.410848] Testing event netif_receive_skb: OK
[  125.470808] Testing event net_dev_queue: OK
[  125.520818] Testing event net_dev_xmit: OK
[  125.570753] Testing event net_dev_start_xmit: OK
[  125.630710] Testing event skb_copy_datagram_iovec: OK
[  125.690709] Testing event consume_skb: OK
[  125.740525] Testing event kfree_skb: OK
[  125.790844] Running tests on trace event systems:
[  125.832325] Testing event system skb: OK
[  125.882834] Testing event system net: OK
[  125.932068] Testing event system napi: OK
[  125.981285] Testing event system sock: OK
[  126.031262] Testing event system udp: OK
[  126.081239] Testing event system libata: OK
[  126.131616] Testing event system scsi: OK
[  126.181453] Testing event system random: OK
[  126.232440] Testing event system block: OK
[  126.282603] Testing event system jbd2: OK
[  126.332346] Testing event system ext4: OK
[  126.400100] Testing event system filelock: OK
[  126.461122] Testing event system writeback: OK
[  126.523266] Testing event system migrate: OK
[  126.580922] Testing event system compaction: OK
[  126.641635] Testing event system kmem: OK
[  126.691691] Testing event system vmscan: OK
[  126.741880] Testing event system pagemap: OK
[  126.800495] Testing event system oom: OK
[  126.850800] Testing event system filemap: OK
[  126.900778] Testing event system rpm: OK
[  126.950933] Testing event system power: OK
[  127.002532] Testing event system test: OK
[  127.050533] Testing event system module: OK
[  127.100758] Testing event system timer: OK
[  127.151608] Testing event system rcu: OK
[  127.200363] Testing event system printk: OK
[  127.250363] Testing event system lock: OK
[  127.302560] Testing event system sched: OK
[  127.362124] Testing event system workqueue: OK
[  127.420457] Testing event system signal: OK
[  127.470556] Testing event system irq: OK
[  127.520862] Testing event system task: OK
[  127.570531] Testing event system raw_syscalls: OK
[  127.630544] Running tests on all trace events:
[  127.668475] Testing all events: OK
[  127.805073] Running tests again, along with the function tracer
[  127.874088] Running tests on trace events:
[  127.922026] Testing event sys_exit: OK
[  128.058250] Testing event sys_enter: OK
[  128.129245] Testing event task_rename: OK
[  128.207855] Testing event task_newtask: OK
[  128.278416] Testing event softirq_raise: OK
[  128.357587] Testing event softirq_exit: OK
[  128.428613] Testing event softirq_entry: OK
[  128.507441] Testing event irq_handler_exit: OK
[  128.588926] Testing event irq_handler_entry: OK
[  128.668478] Testing event signal_deliver: OK
[  128.748481] Testing event signal_generate: OK
[  128.828439] Testing event workqueue_execute_end: OK
[  128.908786] Testing event workqueue_execute_start: OK
[  128.998243] Testing event workqueue_activate_work: OK
[  129.088956] Testing event workqueue_queue_work: OK
[  129.169894] Testing event sched_wake_idle_without_ipi: OK
[  129.258935] Testing event sched_swap_numa: OK
[  129.338969] Testing event sched_stick_numa: OK
[  129.418392] Testing event sched_move_numa: OK
[  129.498397] Testing event sched_process_hang: OK
[  129.579507] Testing event sched_pi_setprio: OK
[  129.658782] Testing event sched_stat_runtime: OK
[  129.738622] Testing event sched_stat_blocked: OK
[  129.818060] Testing event sched_stat_iowait: OK
[  129.897979] Testing event sched_stat_sleep: OK
[  129.978193] Testing event sched_stat_wait: OK
[  130.057222] Testing event sched_process_exec: OK
[  130.137818] Testing event sched_process_fork: OK
[  130.217727] Testing event sched_process_wait: OK
[  130.297669] Testing event sched_wait_task: OK
[  130.378027] Testing event sched_process_exit: OK
[  130.458034] Testing event sched_process_free: OK
[  130.537890] Testing event sched_migrate_task: OK
[  130.617633] Testing event sched_switch: OK
[  130.686638] Testing event sched_wakeup_new: OK
[  130.766834] Testing event sched_wakeup: OK
[  130.846578] Testing event sched_kthread_stop_ret: OK
[  130.927341] Testing event sched_kthread_stop: OK
[  131.007719] Testing event lock_release: OK
[  131.087529] Testing event lock_acquire: OK
[  131.166804] Testing event console: OK
[  131.236970] Testing event rcu_utilization: OK
[  131.316633] Testing event tick_stop: OK
[  131.387459] Testing event itimer_expire: OK
[  131.467406] Testing event itimer_state: OK
[  131.537207] Testing event hrtimer_cancel: OK
[  131.617683] Testing event hrtimer_expire_exit: OK
[  131.697045] Testing event hrtimer_expire_entry: OK
[  131.777297] Testing event hrtimer_start: OK
[  131.856263] Testing event hrtimer_init: OK
[  131.927544] Testing event timer_cancel: OK
[  131.997159] Testing event timer_expire_exit: OK
[  132.077289] Testing event timer_expire_entry: OK
[  132.157508] Testing event timer_start: OK
[  132.227874] Testing event timer_init: OK
[  132.297540] Testing event module_request: OK
[  132.377317] Testing event module_put: OK
[  132.448082] Testing event module_get: OK
[  132.517088] Testing event module_free: OK
[  132.587139] Testing event module_load: OK
[  132.656873] Testing event ftrace_test_filter: OK
[  132.737037] Testing event dev_pm_qos_remove_request: OK
[  132.827559] Testing event dev_pm_qos_update_request: OK
[  132.917427] Testing event dev_pm_qos_add_request: 
[  132.987016] test-events (821) used greatest stack depth: 7256 bytes left
[  133.110909] OK
[  133.129162] Testing event pm_qos_update_flags: OK
[  133.208344] Testing event pm_qos_update_target: OK
[  133.287509] Testing event pm_qos_update_request_timeout: OK
[  133.378204] Testing event pm_qos_remove_request: OK
[  133.467659] Testing event pm_qos_update_request: OK
[  133.548532] Testing event pm_qos_add_request: OK
[  133.637703] Testing event power_domain_target: OK
[  133.718855] Testing event clock_set_rate: OK
[  133.798407] Testing event clock_disable: OK
[  133.878284] Testing event clock_enable: OK
[  133.956939] Testing event wakeup_source_deactivate: OK
[  134.048744] Testing event wakeup_source_activate: OK
[  134.138593] Testing event suspend_resume: OK
[  134.219307] Testing event device_pm_callback_end: OK
[  134.307959] Testing event device_pm_callback_start: OK
[  134.398501] Testing event cpu_frequency: OK
[  134.478365] Testing event pstate_sample: OK
[  134.558565] Testing event cpu_idle: OK
[  134.628803] Testing event rpm_return_int: OK
[  134.708782] Testing event rpm_idle: OK
[  134.778463] Testing event rpm_resume: OK
[  134.857837] Testing event rpm_suspend: OK
[  134.928202] Testing event mm_filemap_add_to_page_cache: OK
[  135.018383] Testing event mm_filemap_delete_from_page_cache: OK
[  135.118156] Testing event oom_score_adj_update: OK
[  135.197781] Testing event mm_lru_activate: OK
[  135.277850] Testing event mm_lru_insertion: OK
[  135.357678] Testing event mm_vmscan_lru_shrink_inactive: OK
[  135.448556] Testing event mm_vmscan_writepage: OK
[  135.527975] Testing event mm_vmscan_memcg_isolate: OK
[  135.617617] Testing event mm_vmscan_lru_isolate: OK
[  135.706914] Testing event mm_shrink_slab_end: OK
[  135.787685] Testing event mm_shrink_slab_start: OK
[  135.867918] Testing event mm_vmscan_memcg_softlimit_reclaim_end: OK
[  135.967245] Testing event mm_vmscan_memcg_reclaim_end: OK
[  136.057780] Testing event mm_vmscan_direct_reclaim_end: OK
[  136.147694] Testing event mm_vmscan_memcg_softlimit_reclaim_begin: OK
[  136.247126] Testing event mm_vmscan_memcg_reclaim_begin: OK
[  136.337559] Testing event mm_vmscan_direct_reclaim_begin: OK
[  136.427710] Testing event mm_vmscan_wakeup_kswapd: OK
[  136.517638] Testing event mm_vmscan_kswapd_wake: OK
[  136.607376] Testing event mm_vmscan_kswapd_sleep: OK
[  136.697003] Testing event mm_page_alloc_extfrag: OK
[  136.787082] Testing event mm_page_pcpu_drain: OK
[  136.867919] Testing event mm_page_alloc_zone_locked: OK
[  136.958042] Testing event mm_page_alloc: OK
[  137.037803] Testing event mm_page_free_batched: OK
[  137.117960] Testing event mm_page_free: OK
[  137.197531] Testing event kmem_cache_free: OK
[  137.277661] Testing event kfree: OK
[  137.347894] Testing event kmem_cache_alloc_node: OK
[  137.436772] Testing event kmalloc_node: OK
[  137.507099] Testing event kmem_cache_alloc: OK
[  137.587019] Testing event kmalloc: OK
[  137.657623] Testing event mm_compaction_defer_reset: OK
[  137.747873] Testing event mm_compaction_defer_compaction: OK
[  137.846706] Testing event mm_compaction_deferred: OK
[  137.936466] Testing event mm_compaction_suitable: OK
[  138.026565] Testing event mm_compaction_finished: OK
[  138.115932] Testing event mm_compaction_try_to_compact_pages: OK
[  138.217217] Testing event mm_compaction_end: OK
[  138.296322] Testing event mm_compaction_begin: OK
[  138.377292] Testing event mm_compaction_migratepages: OK
[  138.467255] Testing event mm_compaction_isolate_freepages: OK
[  138.565943] Testing event mm_compaction_isolate_migratepages: OK
[  138.667334] Testing event mm_numa_migrate_ratelimit: OK
[  138.756878] Testing event mm_migrate_pages: OK
[  138.838058] Testing event writeback_dirty_inode_enqueue: OK
[  138.927333] Testing event writeback_lazytime_iput: OK
[  139.017570] Testing event writeback_lazytime: OK
[  139.097324] Testing event writeback_single_inode: OK
[  139.186003] Testing event writeback_single_inode_start: OK
[  139.277378] Testing event writeback_wait_iff_congested: OK
[  139.367039] Testing event writeback_congestion_wait: OK
[  139.457932] Testing event writeback_sb_inodes_requeue: OK
[  139.546764] Testing event balance_dirty_pages: OK
[  139.636260] Testing event bdi_dirty_ratelimit: OK
[  139.717306] Testing event global_dirty_state: OK
[  139.797048] Testing event writeback_queue_io: OK
[  139.876774] Testing event wbc_writepage: OK
[  139.955784] Testing event writeback_bdi_register: OK
[  140.036642] Testing event writeback_wake_background: OK
[  140.127242] Testing event writeback_nowork: OK
[  140.206321] Testing event writeback_pages_written: OK
[  140.296964] Testing event writeback_wait: OK
[  140.376958] Testing event writeback_written: OK
[  140.457395] Testing event writeback_start: OK
[  140.537255] Testing event writeback_exec: OK
[  140.616552] Testing event writeback_queue: OK
[  140.696990] Testing event writeback_write_inode: OK
[  140.785301] Testing event writeback_write_inode_start: OK
[  140.877506] Testing event writeback_dirty_inode: OK
[  140.965499] Testing event writeback_dirty_inode_start: OK
[  141.057258] Testing event writeback_mark_inode_dirty: OK
[  141.146897] Testing event writeback_dirty_page: OK
[  141.226441] Testing event time_out_leases: OK
[  141.306798] Testing event generic_delete_lease: OK
[  141.387003] Testing event generic_add_lease: OK
[  141.467220] Testing event break_lease_unblock: OK
[  141.547396] Testing event break_lease_block: OK
[  141.626714] Testing event break_lease_noblock: OK
[  141.706538] Testing event ext4_es_shrink: OK
[  141.786888] Testing event ext4_insert_range: OK
[  141.867101] Testing event ext4_collapse_range: OK
[  141.946960] Testing event ext4_es_shrink_scan_exit: OK
[  142.036557] Testing event ext4_es_shrink_scan_enter: OK
[  142.126531] Testing event ext4_es_shrink_count: OK
[  142.206625] Testing event ext4_es_lookup_extent_exit: OK
[  142.297462] Testing event ext4_es_lookup_extent_enter: OK
[  142.386427] Testing event ext4_es_find_delayed_extent_range_exit: OK
[  142.486948] Testing event ext4_es_find_delayed_extent_range_enter: OK
[  142.595818] Testing event ext4_es_remove_extent: OK
[  142.676612] Testing event ext4_es_cache_extent: OK
[  142.765873] Testing event ext4_es_insert_extent: OK
[  142.846492] Testing event ext4_ext_remove_space_done: OK
[  142.937316] Testing event ext4_ext_remove_space: OK
[  143.025381] Testing event ext4_ext_rm_idx: OK
[  143.106594] Testing event ext4_ext_rm_leaf: OK
[  143.185694] Testing event ext4_remove_blocks: OK
[  143.266043] Testing event ext4_ext_show_extent: OK
[  143.345955] Testing event ext4_get_reserved_cluster_alloc: OK
[  143.445491] Testing event ext4_find_delalloc_range: OK
[  143.536006] Testing event ext4_ext_in_cache: OK
[  143.615942] Testing event ext4_ext_put_in_cache: OK
[  143.696011] Testing event ext4_get_implied_cluster_alloc_exit: OK
[  143.796279] Testing event ext4_ext_handle_unwritten_extents: OK
[  143.896394] Testing event ext4_trim_all_free: OK
[  143.976675] Testing event ext4_trim_extent: OK
[  144.056487] Testing event ext4_journal_start_reserved: OK
[  144.146400] Testing event ext4_journal_start: OK
[  144.226187] Testing event ext4_load_inode: OK
[  144.306374] Testing event ext4_ext_load_extent: OK
[  144.386859] Testing event ext4_ind_map_blocks_exit: OK
[  144.476714] Testing event ext4_ext_map_blocks_exit: OK
[  144.566445] Testing event ext4_ind_map_blocks_enter: OK
[  144.656294] Testing event ext4_ext_map_blocks_enter: OK
[  144.746259] Testing event ext4_ext_convert_to_initialized_fastpath: OK
[  144.855653] Testing event ext4_ext_convert_to_initialized_enter: OK
[  144.956267] Testing event ext4_truncate_exit: OK
[  145.036438] Testing event ext4_truncate_enter: OK
[  145.116332] Testing event ext4_unlink_exit: OK
[  145.196529] Testing event ext4_unlink_enter: OK
[  145.276488] Testing event ext4_fallocate_exit: OK
[  145.356634] Testing event ext4_zero_range: OK
[  145.436342] Testing event ext4_punch_hole: OK
[  145.516678] Testing event ext4_fallocate_enter: OK
[  145.599926] Testing event ext4_direct_IO_exit: OK
[  145.686098] Testing event ext4_direct_IO_enter: OK
[  145.766175] Testing event ext4_load_inode_bitmap: OK
[  145.855083] Testing event ext4_read_block_bitmap_load: OK
[  145.946108] Testing event ext4_mb_buddy_bitmap_load: OK
[  146.036090] Testing event ext4_mb_bitmap_load: OK
[  146.116248] Testing event ext4_da_release_space: OK
[  146.205319] Testing event ext4_da_reserve_space: OK
[  146.294794] Testing event ext4_da_update_reserve_space: OK
[  146.386240] Testing event ext4_forget: OK
[  146.456284] Testing event ext4_mballoc_free: OK
[  146.536168] Testing event ext4_mballoc_discard: OK
[  146.615834] Testing event ext4_mballoc_prealloc: OK
[  146.704080] Testing event ext4_mballoc_alloc: OK
[  146.785895] Testing event ext4_alloc_da_blocks: OK
[  146.866080] Testing event ext4_sync_fs: OK
[  146.944928] Testing event ext4_sync_file_exit: OK
[  147.025624] Testing event ext4_sync_file_enter: OK
[  147.105226] Testing event ext4_free_blocks: OK
[  147.185545] Testing event ext4_allocate_blocks: OK
[  147.265716] Testing event ext4_request_blocks: OK
[  147.345749] Testing event ext4_mb_discard_preallocations: OK
[  147.435495] Testing event ext4_discard_preallocations: OK
[  147.525520] Testing event ext4_mb_release_group_pa: OK
[  147.615654] Testing event ext4_mb_release_inode_pa: OK
[  147.706323] Testing event ext4_mb_new_group_pa: OK
[  147.785788] Testing event ext4_mb_new_inode_pa: OK
[  147.865607] Testing event ext4_discard_blocks: OK
[  147.944961] Testing event ext4_journalled_invalidatepage: OK
[  148.035299] Testing event ext4_invalidatepage: OK
[  148.115809] Testing event ext4_releasepage: OK
[  148.195614] Testing event ext4_readpage: OK
[  148.274439] Testing event ext4_writepage: OK
[  148.354655] Testing event ext4_writepages_result: OK
[  148.434190] Testing event ext4_da_write_pages_extent: OK
[  148.525730] Testing event ext4_da_write_pages: OK
[  148.605497] Testing event ext4_writepages: OK
[  148.685362] Testing event ext4_da_write_end: OK
[  148.766722] Testing event ext4_journalled_write_end: OK
[  148.855455] Testing event ext4_write_end: OK
[  148.935855] Testing event ext4_da_write_begin: OK
[  149.015614] Testing event ext4_write_begin: OK
[  149.095606] Testing event ext4_begin_ordered_truncate: OK
[  149.185554] Testing event ext4_mark_inode_dirty: OK
[  149.274804] Testing event ext4_drop_inode: OK
[  149.355938] Testing event ext4_evict_inode: OK
[  149.435409] Testing event ext4_allocate_inode: OK
[  149.515346] Testing event ext4_request_inode: OK
[  149.599222] Testing event ext4_free_inode: OK
[  149.675493] Testing event ext4_other_inode_update_time: OK
[  149.765103] Testing event jbd2_lock_buffer_stall: OK
[  149.855854] Testing event jbd2_write_superblock: OK
[  149.944460] Testing event jbd2_update_log_tail: OK
[  150.025737] Testing event jbd2_checkpoint_stats: OK
[  150.114674] Testing event jbd2_run_stats: OK
[  150.195685] Testing event jbd2_handle_stats: OK
[  150.275772] Testing event jbd2_handle_extend: OK
[  150.355356] Testing event jbd2_handle_start: OK
[  150.435287] Testing event jbd2_submit_inode_data: OK
[  150.524286] Testing event jbd2_end_commit: OK
[  150.605937] Testing event jbd2_drop_transaction: OK
[  150.694585] Testing event jbd2_commit_logging: OK
[  150.775232] Testing event jbd2_commit_flushing: OK
[  150.864521] Testing event jbd2_commit_locking: OK
[  150.945167] Testing event jbd2_start_commit: OK
[  151.025446] Testing event jbd2_checkpoint: OK
[  151.105210] Testing event block_rq_remap: OK
[  151.184879] Testing event block_bio_remap: OK
[  151.264779] Testing event block_split: OK
[  151.334594] Testing event block_unplug: OK
[  151.403726] Testing event block_plug: OK
[  151.474759] Testing event block_sleeprq: OK
[  151.553604] Testing event block_getrq: OK
[  151.634074] Testing event block_bio_queue: OK
[  151.714712] Testing event block_bio_frontmerge: OK
[  151.794188] Testing event block_bio_backmerge: OK
[  151.874273] Testing event block_bio_complete: OK
[  151.954099] Testing event block_bio_bounce: OK
[  152.034627] Testing event block_rq_issue: OK
[  152.114410] Testing event block_rq_insert: OK
[  152.193956] Testing event block_rq_complete: OK
[  152.274324] Testing event block_rq_requeue: OK
[  152.353532] Testing event block_rq_abort: OK
[  152.433203] Testing event block_dirty_buffer: OK
[  152.514195] Testing event block_touch_buffer: OK
[  152.593882] Testing event urandom_read: OK
[  152.663770] Testing event random_read: OK
[  152.733791] Testing event extract_entropy_user: OK
[  152.813844] Testing event extract_entropy: OK
[  152.893925] Testing event get_random_bytes_arch: OK
[  152.973977] Testing event get_random_bytes: OK
[  153.054498] Testing event xfer_secondary_pool: OK
[  153.134342] Testing event add_disk_randomness: OK
[  153.214084] Testing event add_input_randomness: OK
[  153.294111] Testing event debit_entropy: OK
[  153.373298] Testing event push_to_pool: OK
[  153.444574] Testing event credit_entropy_bits: OK
[  153.524415] Testing event mix_pool_bytes_nolock: OK
[  153.608547] Testing event mix_pool_bytes: OK
[  153.684589] Testing event add_device_randomness: OK
[  153.773941] Testing event scsi_eh_wakeup: OK
[  153.854699] Testing event scsi_dispatch_cmd_timeout: OK
[  153.944653] Testing event scsi_dispatch_cmd_done: OK
[  154.032981] Testing event scsi_dispatch_cmd_error: OK
[  154.123896] Testing event scsi_dispatch_cmd_start: OK
[  154.213354] Testing event ata_eh_link_autopsy_qc: OK
[  154.295058] Testing event ata_eh_link_autopsy: OK
[  154.374805] Testing event ata_qc_complete_done: OK
[  154.454597] Testing event ata_qc_complete_failed: OK
[  154.544619] Testing event ata_qc_complete_internal: OK
[  154.634505] Testing event ata_qc_issue: OK
[  154.714087] Testing event udp_fail_queue_rcv_skb: OK
[  154.803529] Testing event sock_exceed_buf_limit: OK
[  154.884808] Testing event sock_rcvqueue_full: OK
[  154.964587] Testing event napi_poll: OK
[  155.034713] Testing event netif_rx_ni_entry: OK
[  155.114668] Testing event netif_rx_entry: OK
[  155.194728] Testing event netif_receive_skb_entry: OK
[  155.284042] Testing event napi_gro_receive_entry: OK
[  155.373922] Testing event napi_gro_frags_entry: OK
[  155.454457] Testing event netif_rx: OK
[  155.524125] Testing event netif_receive_skb: OK
[  155.606493] Testing event net_dev_queue: OK
[  155.684698] Testing event net_dev_xmit: OK
[  155.763734] Testing event net_dev_start_xmit: OK
[  155.844750] Testing event skb_copy_datagram_iovec: OK
[  155.934485] Testing event consume_skb: OK
[  156.013844] Testing event kfree_skb: OK
[  156.084579] Running tests on trace event systems:
[  156.139690] Testing event system skb: OK
[  156.216431] Testing event system net: OK
[  156.298893] Testing event system napi: OK
[  156.375717] Testing event system sock: OK
[  156.455228] Testing event system udp: OK
[  156.524907] Testing event system libata: OK
[  156.606803] Testing event system scsi: OK
[  156.686414] Testing event system random: OK
[  156.770887] Testing event system block: OK
[  156.861683] Testing event system jbd2: OK
[  156.949521] Testing event system ext4: OK
[  157.081485] Testing event system filelock: OK
[  157.176198] Testing event system writeback: OK
[  157.274016] Testing event system migrate: OK
[  157.354007] Testing event system compaction: OK
[  157.438432] Testing event system kmem: OK
[  157.518831] Testing event system vmscan: OK
[  157.614440] Testing event system pagemap: OK
[  157.694126] Testing event system oom: OK
[  157.763815] Testing event system filemap: OK
[  157.844298] Testing event system rpm: OK
[  157.914642] Testing event system power: OK
[  158.002522] Testing event system test: OK
[  158.083674] Testing event system module: OK
[  158.164917] Testing event system timer: OK
[  158.248528] Testing event system rcu: OK
[  158.322896] Testing event system printk: OK
[  158.402866] Testing event system lock: OK
[  158.484389] Testing event system sched: OK
[  158.570692] Testing event system workqueue: OK
[  158.654721] Testing event system signal: OK
[  158.733597] Testing event system irq: OK
[  158.805118] Testing event system task: OK
[  158.883843] Testing event system raw_syscalls: OK
[  158.963830] Running tests on all trace events:
[  159.014810] Testing all events: OK
[  159.356882] Testing ftrace filter: OK
[  159.446319] Key type encrypted registered
[  159.494289] rtc-m48t59 rtc-m48t59.0: setting system clock to 2015-07-17 18:40:01 UTC (1437158401)
[  159.619842] EXT4-fs (sda1): couldn't mount as ext3 due to feature incompatibilities
[  159.704031] EXT4-fs (sda1): couldn't mount as ext2 due to feature incompatibilities
[  159.924771] EXT4-fs (sda1): mounted filesystem with ordered data mode. Opts: (null)
[  160.002483] VFS: Mounted root (ext4 filesystem) readonly on device 8:1.
[  160.114485] devtmpfs: mounted
[  162.079289] systemd[1]: Inserted module 'autofs4'
[  162.369280] random: systemd urandom read with 13 bits of entropy available
[  162.587983] systemd[1]: systemd 218 running in system mode. (+PAM +AUDIT +SELINUX +IMA +APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT -GNUTLS +ACL +XZ -LZ4 -SECCOMP +BLKID -ELFUTILS +KMOD -IDN)
[  162.799271] systemd[1]: Detected architecture 'sparc64'.
[  163.028157] systemd[1]: Set hostname to <u5>.
[  163.464486] systemd-system- (1149) used greatest stack depth: 6520 bytes left
[  164.148802] systemd-fstab-g (1152) used greatest stack depth: 4744 bytes left
[  166.075224] systemd[1]: Cannot add dependency job for unit display-manager.service, ignoring: Unit display-manager.service failed to load: No such file or directory.
[  166.255871] systemd[1]: Starting Arbitrary Executable File Formats File System Automount Point.
[  166.469391] systemd[1]: Set up automount Arbitrary Executable File Formats File System Automount Point.
[  166.574904] systemd[1]: Expecting device dev-sda2.device...
[  166.699785] systemd[1]: Starting Dispatch Password Requests to Console Directory Watch.
[  166.788226] systemd[1]: Started Dispatch Password Requests to Console Directory Watch.
[  166.871940] systemd[1]: Starting Root Slice.
[  166.969284] systemd[1]: Created slice Root Slice.
[  167.013738] systemd[1]: Starting Syslog Socket.
[  167.129256] systemd[1]: Listening on Syslog Socket.
[  167.175766] systemd[1]: Starting Journal Socket (/dev/log).
[  167.309237] systemd[1]: Listening on Journal Socket (/dev/log).
[  167.368789] systemd[1]: Starting Journal Audit Socket.
[  167.479183] systemd[1]: Listening on Journal Audit Socket.
[  167.532758] systemd[1]: Starting User and Session Slice.
[  167.669415] systemd[1]: Created slice User and Session Slice.
[  167.725972] systemd[1]: Starting /dev/initctl Compatibility Named Pipe.
[  167.889152] systemd[1]: Listening on /dev/initctl Compatibility Named Pipe.
[  167.960300] systemd[1]: Starting Journal Socket.
[  168.059108] systemd[1]: Listening on Journal Socket.
[  168.106714] systemd[1]: Starting udev Kernel Socket.
[  168.229087] systemd[1]: Listening on udev Kernel Socket.
[  168.280535] systemd[1]: Starting udev Control Socket.
[  168.399065] systemd[1]: Listening on udev Control Socket.
[  168.450918] systemd[1]: Starting Remote File Systems (Pre).
[  168.579025] systemd[1]: Reached target Remote File Systems (Pre).
[  168.638962] systemd[1]: Starting Encrypted Volumes.
[  168.758999] systemd[1]: Reached target Encrypted Volumes.
[  168.810432] systemd[1]: Starting Forward Password Requests to Wall Directory Watch.
[  168.891248] systemd[1]: Started Forward Password Requests to Wall Directory Watch.
[  168.969127] systemd[1]: Starting Paths.
[  169.058953] systemd[1]: Reached target Paths.
[  169.097907] systemd[1]: Starting Delayed Shutdown Socket.
[  169.228944] systemd[1]: Listening on Delayed Shutdown Socket.
[  169.284561] systemd[1]: Starting System Slice.
[  169.378892] systemd[1]: Created slice System Slice.
[  169.427100] systemd[1]: Mounting Debug File System...
[  169.534489] systemd[1]: Starting system-serial\x2dgetty.slice.
[  169.689757] systemd[1]: Created slice system-serial\x2dgetty.slice.
[  169.761820] systemd[1]: Mounting Huge Pages File System...
[  169.913105] systemd[1]: Starting system-getty.slice.
[  170.139460] systemd[1]: Created slice system-getty.slice.
[  170.218850] systemd[1]: Starting Journal Service...
[  170.370607] systemd[1]: Starting udev Coldplug all Devices...
[  170.547303] systemd[1]: Starting Slices.
[  170.659677] systemd[1]: Reached target Slices.
[  170.953945] systemd[1]: Starting Load Kernel Modules...
[  171.286810] systemd[1]: Mounting POSIX Message Queue File System...
[  171.665586] systemd[1]: Starting File System Check on Root Device...
[  172.010035] systemd[1]: Starting Create list of required static device nodes for the current kernel...
[  172.710452] systemd[1]: Started Set Up Additional Binary Formats.
[  172.847687] systemd[1]: Expecting device dev-ttyS0.device...
[  173.016392] systemd[1]: Mounted Debug File System.
[  173.159896] systemd[1]: Mounted Huge Pages File System.
[  173.331049] systemd[1]: Mounted POSIX Message Queue File System.
[  173.768130] systemd[1]: Started Load Kernel Modules.
[  174.108139] systemd[1]: Started File System Check on Root Device.
[  174.471637] systemd[1]: Started Create list of required static device nodes for the current kernel.
[  174.918039] systemd[1]: Started Journal Service.
[  178.947464] blk_update_request: I/O error, dev fd0, sector 0
[  179.001972] floppy: error -5 while reading block 0
[  180.737967] PCI: Enabling device: (0000:01:01.1), cmd 2
[  180.738173] sunhme.c:v3.10 August 26, 2008 David S. Miller (davem@davemloft.net)
[  180.831211] eth0: HAPPY MEAL (PCI/CheerIO) 10/100BaseT Ethernet 08:00:20:f8:c7:72
[  181.440052] sd 0:0:0:0: Attached scsi generic sg0 type 0
[  181.876958] sr 1:0:0:0: Attached scsi generic sg1 type 5
[  182.347615] cdrom_id (1485) used greatest stack depth: 4552 bytes left
[  182.541054] ls (1487) used greatest stack depth: 4216 bytes left
[  188.237648] Adding 1984016k swap on /dev/sda2.  Priority:-1 extents:1 across:1984016k 
[  189.973232] EXT4-fs (sda1): re-mounted. Opts: errors=remount-ro
[  191.015816] systemd-udevd (1449) used greatest stack depth: 3624 bytes left
[  191.467447] systemd-journald[1165]: Received request to flush runtime journal from PID 1
[  200.653020] eth0: Link is up using internal transceiver at 100Mb/s, Full Duplex.
[  291.022113] random: nonblocking pool is initialized

-- 
Meelis Roos (mroos@linux.ee)
