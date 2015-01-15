From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next v13 0/3] add hisilicon hip04 ethernet driver
Date: Thu, 15 Jan 2015 16:37:23 +0800
Message-ID: <54B77C43.6010200@huawei.com>
References: <1421217254-12008-1-git-send-email-dingtianhong@huawei.com> <54B642B4.8010807@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <sergei.shtylyov@cogentembedded.com>,
	<linux-arm-kernel@lists.infradead.org>, <eric.dumazet@gmail.com>,
	<xuwei5@hisilicon.com>, <zhangfei.gao@linaro.org>,
	<netdev@vger.kernel.org>, <devicetree@vger.kernel.org>,
	<linux@arm.linux.org.uk>
To: Alexander Graf <agraf@suse.de>, <arnd@arndb.de>,
	<robh+dt@kernel.org>, <davem@davemloft.net>,
	<grant.likely@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:39984 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751433AbbAOIhn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 03:37:43 -0500
In-Reply-To: <54B642B4.8010807@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015/1/14 18:19, Alexander Graf wrote:
> 
> 
> On 14.01.15 07:34, Ding Tianhong wrote:
>> v13:
>> - Fix the problem of alignment parameters for function and checkpatch warming.
>>
>> v12:
>> - According Alex's suggestion, modify the changelog and add MODULE_DEVICE_TABLE
>>   for hip04 ethernet.
>>
>> v11:
>> - Add ethtool support for tx coalecse getting and setting, the xmit_more
>>   is not supported for this patch, but I think it could work for hip04,
>>   will support it later after some tests for performance better.
>>
>>   Here are some performance test results by ping and iperf(add tx_coalesce_frames/users),
>>   it looks that the performance and latency is more better by tx_coalesce_frames/usecs.
>>
>>   - Before:
>>     $ ping 192.168.1.1 ...
>>     === 192.168.1.1 ping statistics ===
>>     24 packets transmitted, 24 received, 0% packet loss, time 22999ms
>>     rtt min/avg/max/mdev = 0.180/0.202/0.403/0.043 ms
>>
>>     $ iperf -c 192.168.1.1 ...
>>     [ ID] Interval       Transfer     Bandwidth
>>     [  3]  0.0- 1.0 sec   115 MBytes   945 Mbits/sec
>>
>>   - After:
>>     $ ping 192.168.1.1 ...
>>     === 192.168.1.1 ping statistics ===
>>     24 packets transmitted, 24 received, 0% packet loss, time 22999ms
>>     rtt min/avg/max/mdev = 0.178/0.190/0.380/0.041 ms
>>
>>     $ iperf -c 192.168.1.1 ...
>>     [ ID] Interval       Transfer     Bandwidth
>>     [  3]  0.0- 1.0 sec   115 MBytes   965 Mbits/sec
> 
> Using v11 on top of 3.18 and after generating some traffic on the
> network as well as compiling code on ahci in parallel I ran into the
> following OOPS. Any idea what exactly is going on?
> 
>>From a 10000 feet perspective it looks like two problems to me
> 
>   1) Allocation failure doesn't get handled properly somewhere
>   2) We fail to allocate with order=0 - I don't see why
> 
is it easy to repetition this bug? how big is your memory on your board, is it happened in your previous hip04 driver?

ding

> 
> Alex
> 
> 
> [44085.652301] ld: page allocation failure: order:0, mode:0x120
> [44085.671314] CPU: 0 PID: 5121 Comm: ld Not tainted 3.18.0-5-lpae #1
> [44085.692110] [<c0335814>] (unwind_backtrace) from [<c032fcc8>]
> (show_stack+0x18/0x1c)
> [44085.718109] [<c032fcc8>] (show_stack) from [<c0a50afc>]
> (dump_stack+0x88/0x98)
> [44085.742360] [<c0a50afc>] (dump_stack) from [<c0443f98>]
> (warn_alloc_failed+0xdc/0x124)
> [44085.768938] [<c0443f98>] (warn_alloc_failed) from [<c04469ec>]
> (__alloc_pages_nodemask+0x7ac/0xa8c)
> [44085.799305] [<c04469ec>] (__alloc_pages_nodemask) from [<c0959a88>]
> (__netdev_alloc_frag+0xac/0x17c)
> [44085.829994] [<c0959a88>] (__netdev_alloc_frag) from [<bf00051c>]
> (hip04_rx_poll+0x168/0x3cc [hip04_eth])
> [44085.861830] [<bf00051c>] (hip04_rx_poll [hip04_eth]) from
> [<c096c0fc>] (net_rx_action+0x15c/0x258)
> [44085.891897] [<c096c0fc>] (net_rx_action) from [<c0369508>]
> (__do_softirq+0x138/0x2dc)
> [44085.918171] [<c0369508>] (__do_softirq) from [<c0369920>]
> (irq_exit+0x80/0xb8)
> [44085.942408] [<c0369920>] (irq_exit) from [<c03b3ee0>]
> (__handle_domain_irq+0x68/0xa8)
> [44085.968685] [<c03b3ee0>] (__handle_domain_irq) from [<c03086ac>]
> (hip04_handle_irq+0x38/0x68)
> [44085.997296] [<c03086ac>] (hip04_handle_irq) from [<c0a56d48>]
> (__irq_usr+0x48/0x60)
> [44086.022977] Exception stack(0xd3fbbfb0 to 0xd3fbbff8)
> [44086.039925] bfa0:                                     03fa94f8
> 01fc2598 01fc2598 00000000
> [44086.067357] bfc0: 03fa9458 40482000 00000000 400878b0 004e46e8
> 00000040 01f61f80 00000013
> [44086.094785] bfe0: fbad2488 bed4c270 403aeb5c 403bbe84 200e0010 ffffffff
> [44086.116970] Mem-info:
> [44086.124597] DMA per-cpu:
> [44086.133098] CPU    0: hi:  186, btch:  31 usd: 191
> [44086.149167] HighMem per-cpu:
> [44086.158829] CPU    0: hi:  186, btch:  31 usd:  10
> [44086.174919] active_anon:78994 inactive_anon:57435 isolated_anon:0
> [44086.174919]  active_file:721847 inactive_file:559931 isolated_file:0
> [44086.174919]  unevictable:20 dirty:567 writeback:0 unstable:0
> [44086.174919]  free:2674014 slab_reclaimable:41072 slab_unreclaimable:5704
> [44086.174919]  mapped:13107 shmem:42709 pagetables:933 bounce:0
> [44086.174919]  free_cma:16216
> [44086.286552] DMA free:1088kB min:3012kB low:3764kB high:4516kB
> active_anon:584kB inactive_anon:2948kB active_file:183224kB
> inactive_file:183268kB unevictable:16kB isolated(anon):0kB
> isolated(file):0kB present:778240kB managed:569024kB mlocked:16kB
> dirty:28kB writeback:0kB mapped:864kB shmem:2948kB
> slab_reclaimable:164288kB slab_unreclaimable:22816kB kernel_stack:776kB
> pagetables:3732kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB
> pages_scanned:0 all_unreclaimable? no
> [44086.427835] lowmem_reserve[]: 0 0 15624 15624
> [44086.442687] HighMem free:10694968kB min:512kB low:21708kB
> high:42908kB active_anon:315392kB inactive_anon:226792kB
> active_file:2704164kB inactive_file:2056456kB unevictable:64kB
> isolated(anon):0kB isolated(file):0kB present:15998976kB
> managed:15998976kB mlocked:64kB dirty:2240kB writeback:0kB
> mapped:51564kB shmem:167888kB slab_reclaimable:0kB
> slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB
> bounce:59318392kB free_cma:64864kB writeback_tmp:0kB pages_scanned:0
> all_unreclaimable? no
> [44086.590672] lowmem_reserve[]: 0 0 0 0
> [44086.603158] DMA: 0*4kB 0*8kB 0*16kB 0*32kB 1*64kB (R) 0*128kB 0*256kB
> 0*512kB 1*1024kB (R) 0*2048kB 0*4096kB = 1088kB
> [44086.639330] HighMem: 6*4kB (UMC) 2*8kB (U) 3*16kB (UMC) 5*32kB (UC)
> 3*64kB (UMC) 1*128kB (C) 1*256kB (M) 57*512kB (UM) 25*1024kB (UMC)
> 7*2048kB (UMC) 2594*4096kB (MRC) = 10694968kB
> [44086.694225] Node 0 hugepages_total=0 hugepages_free=0
> hugepages_surp=0 hugepages_size=2048kB
> [44086.722524] 1324446 total pagecache pages
> [44086.735973] 33 pages in swap cache
> [44086.747384] Swap cache stats: add 741, delete 708, find 0/0
> [44086.766072] Free swap  = 497068kB
> [44086.777185] Total swap = 500032kB
> [44087.151253] 4194304 pages of RAM
> [44087.162085] 2674498 free pages
> [44087.172327] 52304 reserved pages
> [44087.183150] 46573 slab pages
> [44087.192810] 1004058 pages shared
> [44087.203632] 33 pages swap cached
> [44087.217489] Unable to handle kernel paging request at virtual address
> b0000000
> [44087.241776] pgd = c0303000
> [44087.250887] [b0000000] *pgd=80000010306003, *pmd=00000000
> [44087.269133] Internal error: Oops: 2a06 [#1] SMP ARM
> [44087.285499] Modules linked in: fuse dm_mod uio_pdrv_genirq uio
> nls_iso8859_1 nls_cp437 vfat fat sg st sr_mod cdrom af_packet squashfs
> loop virtio_blk virtio_ring virtio brd marvell ahci_platform
> libahci_platform libahci hip04_mdio gpio_dwapb hip04_eth [last unloaded:
> dm_mod]
> [44087.368299] CPU: 0 PID: 9 Comm: rcuos/0 Not tainted 3.18.0-5-lpae #1
> [44087.389614] task: e88a46c0 ti: e88ac000 task.ti: e88ac000
> [44087.407749] PC is at v7_dma_inv_range+0x34/0x4c
> [44087.422951] LR is at dma_cache_maint_page+0x9c/0x118
> [44087.439609] pc : [<c0340b94>]    lr : [<c033a67c>]    psr: 400e0013
> [44087.439609] sp : e88addc0  ip : c0340c2c  fp : 00000002
> [44087.478104] r10: 00000000  r9 : c0e73580  r8 : c0e778c4
> [44087.495630] r7 : c0fdfb80  r6 : c0f20780  r5 : 00000000  r4 : 00000640
> [44087.517524] r3 : 0000003f  r2 : 00000040  r1 : b0000640  r0 : b0000000
> [44087.539424] Flags: nZcv  IRQs on  FIQs on  Mode SVC_32  ISA ARM
> Segment kernel
> [44087.563939] Control: 30c5387d  Table: 21305b40  DAC: fffffffd
> [44087.583213] Process rcuos/0 (pid: 9, stack limit = 0xe88ac238)
> [44087.602777] Stack: (0xe88addc0 to 0xe88ae000)
> [44087.617398] ddc0: 00000000 00000000 e88a4708 e8ae059c e8ae0000
> c0e778c4 c0fdfb80 00000640
> [44087.644829] dde0: 00000000 df7f9000 00000002 c033a91c c0340c2c
> 00000700 df9da740 e8ae059c
> [44087.672259] de00: e8ae0000 000012ac 00000038 db903700 e8ae02d8
> c0fdfb80 00000001 bf000498
> [44087.699689] de20: 00000640 00000002 00000000 c0e9c5b0 e88ac000
> 00000101 c0e7ab04 00000000
> [44087.727119] de40: 00000040 bf001e28 c0f77800 e8ae059c 00000000
> 00000040 0000012c df9da740
> [44087.754549] de60: c0e6d100 00000101 e88ac000 c096c0fc c0f245e4
> df9da748 007aae3c e88ac000
> [44087.781978] de80: c0f26038 c0f2410d e88a5850 00000003 c0e6d08c
> 00000002 e88ac000 00000002
> [44087.809407] dea0: c0f24314 00000101 e1f4d4c0 c0369508 00000000
> c0e94fd4 0000000c c0e6d080
> [44087.836837] dec0: c0e65448 0000000a c0f34000 c0e6d100 007aae3b
> e88ac030 c0a62b84 00208040
> [44087.864266] dee0: a00e0013 600e0013 df9d7680 000001ff 00000001
> df9d7744 00000000 c0e73630
> [44087.891696] df00: e1f4d4c0 c036976c e88ac010 c0369830 db903700
> df9d7680 e88ac000 c03bc8cc
> [44087.919125] df20: 00000000 d3fedb80 000b7df0 00000000 e88a46c0
> c039db48 e88adf38 e88adf38
> [44087.946554] df40: 00000000 e8838940 00000000 df9d7680 c03bc74c
> 00000000 00000000 00000000
> [44087.973984] df60: 00000000 c0380398 00000000 00000000 00000001
> df9d7680 00000000 00000000
> [44088.001413] df80: e88adf80 e88adf80 00000000 00000000 e88adf90
> e88adf90 e88adfac e8838940
> [44088.028843] dfa0: c03802b8 00000000 00000000 c032bbc8 00000000
> 00000000 00000000 00000000
> [44088.056272] dfc0: 00000000 00000000 00000000 00000000 00000000
> 00000000 00000000 00000000
> [44088.083701] dfe0: 00000000 00000000 00000000 00000000 00000013
> 00000000 e88adff4 00000000
> [44088.111150] [<c0340b94>] (v7_dma_inv_range) from [<c033a67c>]
> (dma_cache_maint_page+0x9c/0x118)
> [44088.140339] [<c033a67c>] (dma_cache_maint_page) from [<c033a91c>]
> (__dma_page_dev_to_cpu+0x90/0x110)
> [44088.170996] [<c033a91c>] (__dma_page_dev_to_cpu) from [<bf000498>]
> (hip04_rx_poll+0xe4/0x3cc [hip04_eth])
> [44088.203119] [<bf000498>] (hip04_rx_poll [hip04_eth]) from
> [<c096c0fc>] (net_rx_action+0x15c/0x258)
> [44088.233185] [<c096c0fc>] (net_rx_action) from [<c0369508>]
> (__do_softirq+0x138/0x2dc)
> [44088.259457] [<c0369508>] (__do_softirq) from [<c036976c>]
> (do_softirq+0x5c/0x64)
> [44088.284270] [<c036976c>] (do_softirq) from [<c0369830>]
> (__local_bh_enable_ip+0xbc/0xc0)
> [44088.311428] [<c0369830>] (__local_bh_enable_ip) from [<c03bc8cc>]
> (rcu_nocb_kthread+0x180/0x5bc)
> [44088.340910] [<c03bc8cc>] (rcu_nocb_kthread) from [<c0380398>]
> (kthread+0xe0/0xf8)
> [44088.366026] [<c0380398>] (kthread) from [<c032bbc8>]
> (ret_from_fork+0x14/0x20)
> [44088.390260] Code: 1e070f3e e1110003 e1c11003 1e071f3e (ee070f36)
> [44088.410808] ---[ end trace ccf8b617d193d373 ]---
> [44088.426324] Kernel panic - not syncing: Fatal exception in interrupt
> [44088.447652] Rebooting in 100 seconds..Reboot failed -- System halted
> 
> .
> 
