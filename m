From: Jeff Wu <cpwu@tnsoft.com.cn>
Subject: [OOPS]e1000e .ko 1.0.2-k2
Date: Wed, 15 Dec 2010 16:43:03 +0800
Message-ID: <1292402583.2484.25.camel@cephhost>
Reply-To: <cpwu@tnsoft.com.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [210.22.136.227] ([210.22.136.227]:64390 "EHLO
	MAIL.TNSOFT.COM.CN" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750871Ab0LOIl0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 03:41:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi ,

iozone test for our distributed file system ,
we detect a oops(see below ,logs).
1. OS ubuntu 10.04 server x86_64
2. test tool iozone
3. ethernet card driver : e1000e



[181174.958159] 24188 total pagecache pages
[181174.958161] 21082 pages in swap cache
[181174.958162] Swap cache stats: add 118851, delete 97769, find
5970/11916
[181174.958164] Free swap  = 3649128kB
[181174.958165] Total swap = 3905528kB
[181174.967050] 1032192 pages RAM
[181174.967052] 43435 pages reserved
[181174.967053] 7509 pages shared
[181174.967054] 978870 pages non-shared
[181174.967056] SLUB: Unable to allocate memory on node -1 (gfp=0x20)
[181174.967058]   cache: kmalloc-4096, object size: 4096, buffer size:
4096, default order: 3, min order: 0
[181174.967060]   node 0: slabs: 670, objs: 1685, free: 0
[181174.967116] swapper: page allocation failure. order:0, mode:0x4020
[181174.967120] Pid: 0, comm: swapper Not tainted 2.6.32-21-server
#32-Ubuntu
[181174.967121] Call Trace:
[181174.967123]  <IRQ>  [<ffffffff810f97de>] __alloc_pages_slowpath
+0x56e/0x580
[181174.967131]  [<ffffffff810f9961>] __alloc_pages_nodemask+0x171/0x180
[181174.967134]  [<ffffffff8112c597>] alloc_pages_current+0x87/0xd0
[181174.967137]  [<ffffffff81132547>] new_slab+0x2f7/0x310
[181174.967140]  [<ffffffff81134dc1>] __slab_alloc+0x201/0x2d0
[181174.967143]  [<ffffffff814668d6>] ? __netdev_alloc_skb+0x36/0x60
[181174.967146]  [<ffffffff81135d9f>] __kmalloc_node_track_caller
+0xaf/0x160
[181174.967148]  [<ffffffff814668d6>] ? __netdev_alloc_skb+0x36/0x60
[181174.967150]  [<ffffffff81466590>] __alloc_skb+0x80/0x190
[181174.967153]  [<ffffffff814668d6>] __netdev_alloc_skb+0x36/0x60
[181174.967162]  [<ffffffffa00136e1>] e1000_alloc_rx_buffers+0x2b1/0x320
[e1000e]
[181174.967165]  [<ffffffff814708a9>] ? napi_gro_receive+0x39/0x50
[181174.967170]  [<ffffffffa001394f>] e1000_clean_rx_irq+0x1ff/0x460
[e1000e]
[181174.967175]  [<ffffffffa000ff34>] ? e1000_clean_tx_irq+0x104/0x3a0
[e1000e]
[181174.967180]  [<ffffffffa001256e>] e1000_clean+0x7e/0x280 [e1000e]
[181174.967182]  [<ffffffff81470a7f>] net_rx_action+0x10f/0x250
[181174.967186]  [<ffffffff8106e257>] __do_softirq+0xb7/0x1e0
[181174.967188]  [<ffffffff810c4880>] ? handle_IRQ_event+0x60/0x170
[181174.967192]  [<ffffffff810142ec>] call_softirq+0x1c/0x30
[181174.967194]  [<ffffffff81015cb5>] do_softirq+0x65/0xa0
[181174.967196]  [<ffffffff8106e0f5>] irq_exit+0x85/0x90
[181174.967199]  [<ffffffff8155c615>] do_IRQ+0x75/0xf0
[181174.967202]  [<ffffffff81013b13>] ret_from_intr+0x0/0x11
[181174.967203]  <EOI>  [<ffffffff8101b551>] ? mwait_idle+0x71/0xd0
[181174.967208]  [<ffffffff8155a2ea>] ? atomic_notifier_call_chain
+0x1a/0x20
[181174.967211]  [<ffffffff81011e63>] ? cpu_idle+0xb3/0x110
[181174.967214]  [<ffffffff8154f580>] ? start_secondary+0xa8/0xaa
[181174.967216] Mem-Info:
[181174.967217] Node 0 DMA per-cpu:
[181174.967219] CPU    0: hi:    0, btch:   1 usd:   0
[181174.967221] CPU    1: hi:    0, btch:   1 usd:   0
[181174.967223] CPU    2: hi:    0, btch:   1 usd:   0
[181174.967224] CPU    3: hi:    0, btch:   1 usd:   0
[181174.967225] Node 0 DMA32 per-cpu:
[181174.967227] CPU    0: hi:  186, btch:  31 usd:  91
[181174.967229] CPU    1: hi:  186, btch:  31 usd:  30
[181174.967231] CPU    2: hi:  186, btch:  31 usd: 100
[181174.967232] CPU    3: hi:  186, btch:  31 usd:   0
[181174.967233] Node 0 Normal per-cpu:
[181174.967235] CPU    0: hi:  186, btch:  31 usd:  31
[181174.967237] CPU    1: hi:  186, btch:  31 usd:  30
[181174.967238] CPU    2: hi:  186, btch:  31 usd:  44
[181174.967240] CPU    3: hi:  186, btch:  31 usd:   5



Jeff .C.P.Wu


