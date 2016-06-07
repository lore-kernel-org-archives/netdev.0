From: Helge Deller <deller@gmx.de>
Subject: Re: rhashtable - rhashtable_insert_fast failed
Date: Tue, 7 Jun 2016 16:47:28 +0200
Message-ID: <5756DE80.4040705@gmx.de>
References: <5751E702.5040909@gmx.de> <20160604073527.GE29740@orbyte.nwl.cc>
 <20160606035718.GA19559@gondor.apana.org.au> <5756D69E.1080402@gmx.de>
 <20160607141656.GB2237@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Phil Sutter <phil@nwl.cc>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:57048 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753453AbcFGOrl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2016 10:47:41 -0400
In-Reply-To: <20160607141656.GB2237@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07.06.2016 16:16, Herbert Xu wrote:
> On Tue, Jun 07, 2016 at 04:13:50PM +0200, Helge Deller wrote:
>>
>> What warnings do you mean specifically? Some specific CONFIG_ option ?
> 
> Look for GFP_NOWARN in lib/rhashtable.c and delete it.

Ok, removed it.
It generates a kernel warning: 

[    0.000000] Linux version 4.7.0-rc2-64bit+ (deller@p100.box) (gcc version 4.9.2 20150212 (Red Hat Cross 4.9.2-5) (GCC) ) #429 SMP Tue Jun 7 16:44:43 CEST 2016
[    0.000000] unwind_init: start = 0x40cbfcb8, end = 0x40d15008, entries = 21813
[    0.000000] FP[0] enabled: Rev 1 Model 20
[    0.000000] The 64-bit Kernel has started...
[    0.000000] Kernel default page size is 4 KB. Huge pages enabled with 1 MB physical and 2 MB virtual size.
[    0.000000] bootconsole [ttyB0] enabled
[    0.000000] Initialized PDC Console for debugging.
[    0.000000] Determining PDC firmware type: 64 bit PAT.
[    0.000000] model 000088a0 00000491 00000000 00000002 56bc8caf01697bbe 100000f0 00000008 000000b2 000000b2
[    0.000000] vers  00000301
[    0.000000] CPUID vers 20 rev 4 (0x00000284)
[    0.000000] capabilities 0x35
[    0.000000] model 9000/785/C8000
[    0.000000] parisc_cache_init: Only equivalent aliasing supported!
[    0.000000] Memory Ranges:
[    0.000000]  0) Start 0x0000000000000000 End 0x000000003fffffff Size   1024 MB
[    0.000000]  1) Start 0x0000000100000000 End 0x00000001ffdfffff Size   4094 MB
[    0.000000]  2) Start 0x0000004040000000 End 0x00000040ffffffff Size   3072 MB
[    0.000000] Total Memory: 8190 MB
[    0.000000] percpu: Embedded 14 pages/cpu @0000000043c60000 s18144 r8192 d31008 u57344
[    0.000000] SMP: bootstrap CPU ID is 0
[    0.000000] Built 3 zonelists in Zone order, mobility grouping on.  Total pages: 2067975
[    0.000000] Kernel command line: HOME=/ root=/dev/sda5 pa64_root=sda5 c3k=sda5 c8k_root=sda5 ip=bootp panic_timeout=60 panic=-1 hugepages=100 console=ttyS0 TERM=vt1x
[    0.000000] log_buf_len individual max cpu contribution: 4096 bytes
[    0.000000] log_buf_len total cpu_extra contributions: 126976 bytes
[    0.000000] log_buf_len min size: 131072 bytes
[    0.000000] log_buf_len: 262144 bytes
[    0.000000] early log buf free: 127768(97%)
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Dentry cache hash table entries: 1048576 (order: 11, 8388608 bytes)
[    0.000000] Inode-cache hash table entries: 524288 (order: 10, 4194304 bytes)
[    0.000000] Memory: 8210068K/8386560K available (8720K kernel code, 3259K rwdata, 1284K rodata, 1024K init, 16148K bss, 176492K reserved, 0K cma-reserved)
[    0.000000] SLUB: HWalign=16, Order=0-3, MinObjects=0, CPUs=32, Nodes=8
[    0.000000] Hierarchical RCU implementation.
[    0.000000]  Build-time adjustment of leaf fanout to 64.
[    0.000000] NR_IRQS:128
[    0.000000] clocksource: cr16: mask: 0xffffffffffffffff max_cycles: 0xcf914c9718, max_idle_ns: 440795231327 ns
[    0.000000] Console: colour dummy device 160x64
[    0.196000] Calibrating delay loop... 1795.07 BogoMIPS (lpj=3590144)
[    0.260010] pid_max: default: 32768 minimum: 301
[    0.296333] Mount-cache hash table entries: 16384 (order: 5, 131072 bytes)
[    0.356020] Mountpoint-cache hash table entries: 16384 (order: 5, 131072 bytes)
[    0.544764] Brought up 1 CPUs
[    0.587520] devtmpfs: initialized
[    0.633614] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645041785100000 ns
[    0.636234] xor: measuring software checksum speed
[    0.864013]    8regs     :  4355.000 MB/sec
[    0.956012]    8regs_prefetch:  3824.000 MB/sec
[    1.052012]    32regs    :  3616.000 MB/sec
[    1.144012]    32regs_prefetch:  3335.000 MB/sec
[    1.148013] xor: using function: 8regs (4355.000 MB/sec)
[    1.276455] NET: Registered protocol family 16
[    1.288884] Searching for devices...
[    1.492016] Found devices:
[    1.496019] 1. Crestone Peak Slow at 0xfffffffffe780000 [128] { 0, 0x0, 0x88a, 0x00004 }
[    1.636015] 2. Crestone Peak Slow at 0xfffffffffe781000 [129] { 0, 0x0, 0x88a, 0x00004 }
[    1.744015] 3. Memory at 0xfffffffffed08000 [8] { 1, 0x0, 0x0b6, 0x00009 }
[    1.750399] 4. Pluto BC McKinley Port at 0xfffffffffed00000 [0] { 12, 0x0, 0x880, 0x0000c }
[    1.944015] 5. Mercury PCI Bridge at 0xfffffffffed20000 [0/0] { 13, 0x0, 0x783, 0x0000a }
[    2.052016] 6. Mercury PCI Bridge at 0xfffffffffed24000 [0/2] { 13, 0x0, 0x783, 0x0000a }
[    2.160016] 7. Mercury PCI Bridge at 0xfffffffffed26000 [0/3] { 13, 0x0, 0x783, 0x0000a }
[    2.268016] 8. Quicksilver AGP Bridge at 0xfffffffffed28000 [0/4] { 13, 0x0, 0x784, 0x0000a }
[    2.380015] 9. BMC IPMI Mgmt Ctlr at 0xfffffff0f05b0000 [16] { 15, 0x0, 0x004, 0x000c0 }
[    2.488015] 10. Crestone Peak Core RS-232 at 0xfffffff0f05e0000 [17] { 10, 0x0, 0x076, 0x000ad }
[    2.604015] 11. Crestone Peak Core RS-232 at 0xfffffff0f05e2000 [18] { 10, 0x0, 0x076, 0x000ad }
[    2.720014] Enabling PDC_PAT chassis codes support v0.05
<Cpu0> 38000c6400e00000  a0e008101100c000  CC_PAT_ENCODED_FIELD_MAJOR_FWD_PROG
<Cpu0> 36000c6a00e00000  0000000000000420  CC_PAT_DATA_FIELD_MAJOR_FWD_PROG
[    3.632486] Releasing cpu 1 now, hpa=fffffffffe781000
<Cpu1> 0000099101e00000  0000000000000000  CC_BOOT_OS_RENDEZVOUS
<Cpu1> 0100142901e00000  fffffff0f0e0ac00  CC_CPU_INTRIGUE_LDB
[    4.076430] CPU(s): 2 out of 2 PA8800 (Mako) at 900.000000 MHz online
[    4.169071] Setting cache flush threshold to 32768 kB
[    4.237795] Setting TLB flush threshold to 452 kB
[    4.432102] SBA found Pluto 2.3 at 0xfffffffffed00000
[    4.564076] sba_ioc_init_pluto: reserving 512Mb of IOVA space for agpgart
[    4.668065] Mercury version TR3.2 (0x32) found at 0xfffffffffed20000
[    4.776028] LBA: lmmio_space [0xffffffff80000000-0xffffffff9fffffff] - new
[    4.880290] LBA 0:0: PCI host bridge to bus 0000:00
[    4.888030] pci_bus 0000:00: root bus resource [io  0x0000-0xffff]
[    4.952024] pci_bus 0000:00: root bus resource [mem 0xffffffff80000000-0xffffffff9fffffff] (bus address [0x80000000-0x9fffffff])
[    5.036041] pci_bus 0000:00: root bus resource [bus 00-07]
[    5.264066] Mercury version TR3.2 (0x32) found at 0xfffffffffed24000
[    5.388266] LBA 0:2: PCI host bridge to bus 0000:40
[    5.396032] pci_bus 0000:40: root bus resource [io  0x10000-0x1ffff] (bus address [0x0000-0xffff])
[    5.460021] pci_bus 0000:40: root bus resource [mem 0xffffffffa0000000-0xffffffffafffffff] (bus address [0xa0000000-0xafffffff])
[    5.576043] pci_bus 0000:40: root bus resource [bus 40-47]
[    5.808067] Mercury version TR3.2 (0x32) found at 0xfffffffffed26000
[    5.932300] LBA 0:3: PCI host bridge to bus 0000:60
[    5.940034] pci_bus 0000:60: root bus resource [io  0x20000-0x2ffff] (bus address [0x0000-0xffff])
[    6.004022] pci_bus 0000:60: root bus resource [mem 0xffffffffb0000000-0xffffffffbfffffff] (bus address [0xb0000000-0xbfffffff])
[    6.124039] pci_bus 0000:60: root bus resource [bus 60-67]
[    6.356068] Quicksilver version TR1.0 (0x10) found at 0xfffffffffed28000
[    6.468030] LBA: lmmio_space [0xffffffffc0000000-0xffffffffdfffffff] - new
[    6.572270] LBA 0:4: PCI host bridge to bus 0000:80
[    6.580031] pci_bus 0000:80: root bus resource [io  0x30000-0x3ffff] (bus address [0x0000-0xffff])
[    6.644044] pci_bus 0000:80: root bus resource [mem 0xffffffffc0000000-0xffffffffdfffffff] (bus address [0xc0000000-0xdfffffff])
[    6.764021] pci_bus 0000:80: root bus resource [bus 80-87]
[    6.916809] iosapic: no IRTE for 0000:80:00.1 (IRQ not connected?)
<Cpu0> 0300108200e00000  0000000000000000  CC_PROCS_ENTRY_IN
<Cpu0> 0300030700e00000  0000000000000000  CC_SYSTEM_STATE_RUNNING_OK
[    7.072024] powersw: Soft power switch at 0xfffffff0f042e278 enabled.
[    7.583433] HugeTLB registered 2 MB page size, pre-allocated 100 pages
[    7.736022] raid6: int64x1  gen()   794 MB/s
[    7.860078] raid6: int64x1  xor()   387 MB/s
[    7.984019] raid6: int64x2  gen()   995 MB/s
[    8.108020] raid6: int64x2  xor()   507 MB/s
[    8.232060] raid6: int64x4  gen()  1064 MB/s
[    8.356051] raid6: int64x4  xor()   578 MB/s
[    8.480050] raid6: int64x8  gen()   847 MB/s
[    8.604067] raid6: int64x8  xor()   500 MB/s
[    8.608013] raid6: using algorithm int64x4 gen() 1064 MB/s
[    8.664013] raid6: .... xor() 578 MB/s, rmw enabled
[    8.736019] raid6: using intx1 recovery algorithm
[    8.800276] vgaarb: setting as boot device: PCI:0000:80:00.0
[    8.804000] vgaarb: device added: PCI:0000:80:00.0,decodes=io+mem,owns=io+mem,locks=none
[    8.860020] vgaarb: loaded
[    9.044021] vgaarb: bridge control possible 0000:80:00.0
[    9.080249] SCSI subsystem initialized
[    9.151535] usbcore: registered new interface driver usbfs
[    9.200100] usbcore: registered new interface driver hub
[    9.274369] usbcore: registered new device driver usb
[    9.341849] VFS: Disk quotas dquot_6.6.0
[    9.408118] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    9.557155] NET: Registered protocol family 2
[    9.560903] TCP established hash table entries: 65536 (order: 7, 524288 bytes)
[    9.616962] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[    9.713570] TCP: Hash tables configured (established 65536 bind 65536)
[    9.888046] UDP hash table entries: 4096 (order: 5, 131072 bytes)
[    9.892236] UDP-Lite hash table entries: 4096 (order: 5, 131072 bytes)
[    9.972665] NET: Registered protocol family 1
[   10.258610] Chassis warnings not supported.
[   10.264193] Performance monitoring counters enabled for Crestone Peak Slow
[   10.320423] futex hash table entries: 8192 (order: 6, 262144 bytes)
[   10.413326] workingset: timestamp_bits=58 max_order=21 bucket_order=0
[   10.590934] fuse init (API version 7.24)
[   10.648062] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 252)
[   10.648062] io scheduler noop registered
[   10.744211] io scheduler cfq registered (default)
[   10.796028] Running rhashtable test nelem=8, max_size=0, shrinking=0
[   10.860014] Test 00:
[   10.981084]   Adding 50000 keys
[   11.092793] Info: encountered resize
[   11.140488] Info: encountered resize
[   11.188775] Info: encountered resize
[   11.240676]   Traversal complete: counted=50203, nelems=50000, entries=50000, table-jumps=3
[   11.348023] Test failed: Total count mismatch ^^^
[   11.440190]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[   11.552025]   Deleting 50000 keys
[   11.615540]   Duration of test: 592000000 ns
[   11.672058] Test 01:
[   11.712580]   Adding 50000 keys
[   11.851248] Info: encountered resize
[   11.904127]   Traversal complete: counted=74577, nelems=50000, entries=50000, table-jumps=1
[   12.012014] Test failed: Total count mismatch ^^^
[   12.103710]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[   12.216024]   Deleting 50000 keys
[   12.279099]   Duration of test: 524000000 ns
[   12.336060] Test 02:
[   12.376097]   Adding 50000 keys
[   12.486214] Info: encountered resize
[   12.545793]   Traversal complete: counted=82769, nelems=50000, entries=50000, table-jumps=1
[   12.548102] Test failed: Total count mismatch ^^^
[   12.746026]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[   12.752035]   Deleting 50000 keys
[   12.921413]   Duration of test: 508000000 ns
[   12.924059] Test 03:
[   13.018407]   Adding 50000 keys
[   13.129482] Info: encountered resize
[   13.176495] Info: encountered resize
[   13.224956] Info: encountered resize
[   13.277490]   Traversal complete: counted=50997, nelems=50000, entries=50000, table-jumps=3
[   13.388024] Test failed: Total count mismatch ^^^
[   13.477015]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[   13.588026]   Deleting 50000 keys
[   13.652371]   Duration of test: 592000000 ns
[   13.708072] Average test time: 554000000
[   13.760017] Testing concurrent rhashtable access from 10 threads
[   14.154764]   thread[3]: rhashtable_insert_fast failed
[   14.158143] ------------[ cut here ]------------
[   14.158187] WARNING: CPU: 1 PID: 44 at /home/cvs/parisc/git-kernel/linus-linux-2.6/mm/page_alloc.c:3584 __alloc_pages_nodemask+0x28c/0x1188
[   14.158195] Modules linked in:
[   14.158207] CPU: 1 PID: 44 Comm: rhashtable_thra Not tainted 4.7.0-rc2-64bit+ #429
[   14.158215] task: 000000007f78cd00 ti: 000000007efc8000 task.ti: 000000007efc8000
[   14.158217] 
[   14.158220]      YZrvWESTHLNXBCVMcbcbcbcbOGFRQPDI
[   14.158223] PSW: 00001000000001101111111100001111 Not tainted
[   14.158229] r00-03  000000ff0806ff0f 0000000040c72e10 000000004030a608 000000007efc8780
[   14.158235] r04-07  0000000040c4f610 000000000208d020 000000000208d020 000000000000000b
[   14.158240] r08-11  0000000040e101e0 000000007efc8788 0000000010574328 0000000000000004
[   14.158246] r12-15  0000000000000000 0000000040cbee10 000000007e000000 0000000040f4f408
[   14.158251] r16-19  fffffffffffff000 0000000000000001 0000000040c95e10 0000000000000000
[   14.158257] r20-23  0000000040e0f0a8 00000000000bc9e7 0000000000000101 0000000000000004
[   14.158262] r24-27  0000000000000000 0000000000000000 0000000040e10fe0 0000000040c4f610
[   14.158268] r28-31  0000000040e972ad 000000007efc8aa0 000000007efc8960 0000000000000001
[   14.158273] sr00-03  0000000000000000 0000000000000000 0000000000000000 0000000000000000
[   14.158278] sr04-07  0000000000000000 0000000000000000 0000000000000000 0000000000000000
[   14.158281] 
[   14.158285] IASQ: 0000000000000000 0000000000000000 IAOQ: 000000004030a66c 000000004030a670
[   14.158290]  IIR: 03ffe01f    ISR: 0000000010040000  IOR: 00000003a5e972ad
[   14.158294]  CPU:        1   CR30: 000000007efc8000 CR31: dcf9aef3f81fe80f
[   14.158297]  ORIG_R28: 0000000000000001
[   14.158303]  IAOQ[0]: __alloc_pages_nodemask+0x28c/0x1188
[   14.158309]  IAOQ[1]: __alloc_pages_nodemask+0x290/0x1188
[   14.158314]  RP(r2): __alloc_pages_nodemask+0x228/0x1188
[   14.158318] Backtrace:
[   14.158341]  [<0000000040281380>] sched_clock_local+0x60/0x120
[   14.158356]  [<0000000040332ed0>] kmalloc_order+0x40/0xe8
[   14.158365]  [<000000004036fee4>] __kmalloc+0xfc/0x2c0
[   14.158377]  [<00000000406f72ec>] bucket_table_alloc+0x84/0x308
[   14.158387]  [<00000000406f84b8>] rhashtable_insert_rehash+0x90/0x1a0
[   14.158396]  [<00000000406fbf34>] insert_retry.isra.9.constprop.13+0x2a4/0x478
[   14.158403]  [<00000000406fc260>] threadfunc+0x158/0x600
[   14.158411]  [<000000004026e958>] kthread+0x1d0/0x1f8
[   14.158421]  [<0000000040205020>] end_fault_vector+0x20/0xc0
[   14.158456]  [<00000000406e77a4>] memcpy+0x3c/0x58
[   14.158464]  [<00000000406e75c4>] pa_memcpy+0x44/0xb8
[   14.158471]  [<00000000406e77a4>] memcpy+0x3c/0x58
[   14.158479]  [<00000000402c1860>] update_wall_time+0x9e0/0xa60
[   14.158486]  [<00000000402c1eb8>] xtime_update+0xa8/0xc8
[   14.158494]  [<000000004021888c>] timer_interrupt+0x23c/0x278
[   14.158503]  [<00000000402a0c18>] handle_irq_event_percpu+0x238/0x288
[   14.158505] 
[   14.158529] ---[ end trace b1d2d69d40940990 ]---
[   14.158537]   thread[2]: rhashtable_insert_fast failed
[   14.158563]   thread[0]: rhashtable_insert_fast failed
[   14.158674] Test failed: thread 0 returned: -12
[   14.158695]   thread[8]: rhashtable_insert_fast failed
[   14.158705]   thread[4]: rhashtable_insert_fast failed
[   14.158715]   thread[6]: rhashtable_insert_fast failed
[   15.489784] Test failed: thread 2 returned: -12
[   18.181317] Test failed: thread 3 returned: -12
[   18.300098] Test failed: thread 4 returned: -12
[   18.360078] Test failed: thread 6 returned: -12
[   18.420264] Test failed: thread 8 returned: -12
[   18.480071] Started 10 threads, 6 failed
