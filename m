From: "Dave, Tushar N" <tushar.n.dave@intel.com>
Subject: RE: [E1000-devel] [e100] Page allocation failure warning(?) in
 2.6.36.3
Date: Mon, 10 Jan 2011 15:11:36 -0800
Message-ID: <F675EE07F28A0A4E933E5F9DD28672FB01197E08E2@orsmsx508.amr.corp.intel.com>
References: <913138.52057.qm@web121710.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Chris Rankin <rankincj@yahoo.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:41068 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751469Ab1AJXLi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 18:11:38 -0500
In-Reply-To: <913138.52057.qm@web121710.mail.ne1.yahoo.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris,
Sorry to hear that you have the issue. 
Does the issue appears only when you add a bridge?

Thanks.

-Tushar

-----Original Message-----
From: Chris Rankin [mailto:rankincj@yahoo.com] 
Sent: Saturday, January 08, 2011 4:54 AM
To: e1000-devel@lists.sourceforge.net
Cc: netdev@vger.kernel.org
Subject: [E1000-devel] [e100] Page allocation failure warning(?) in 2.6.36.3

Hi,

I've just booted 2.6.36.3 on my old router box (which contains one single e100 card, and one dual-port e100 card), and have discovered this rather scary message in the dmesg log:

e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
e100: Copyright(c) 1999-2006 Intel Corporation
e100 0000:00:0f.0: PME# disabled
e100 0000:00:0f.0: eth0: addr 0xffbeb000, irq 10, MAC addr 00:90:27:76:d0:ec
e100 0000:01:04.0: PME# disabled
e100 0000:01:04.0: eth1: addr 0xff0fe000, irq 11, MAC addr 00:03:47:3b:29:5c
e100 0000:01:05.0: PME# disabled
e100 0000:01:05.0: eth2: addr 0xff0ff000, irq 10, MAC addr 00:03:47:3b:29:5d
...
device eth1 entered promiscuous mode
ADDRCONF(NETDEV_UP): eth1: link is not ready
e100 0000:01:04.0: eth1: NIC Link is Up 100 Mbps Full Duplex
ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
device eth2 entered promiscuous mode
ADDRCONF(NETDEV_UP): eth2: link is not ready
br0: port 1(eth1) entering learning state
br0: port 1(eth1) entering learning state
ifconfig: page allocation failure. order:6, mode:0x8020
Pid: 3716, comm: ifconfig Not tainted 2.6.36.3 #1
Call Trace:
 [<c104b2a9>] ? __alloc_pages_nodemask+0x477/0x4a6
 [<c106177d>] ? __slab_alloc+0x1eb/0x396
 [<c1004ca6>] ? dma_generic_alloc_coherent+0x4e/0xac
 [<c105fb5c>] ? dma_pool_alloc+0xe5/0x1d9
 [<c1004c58>] ? dma_generic_alloc_coherent+0x0/0xac
 [<c58f97f3>] ? e100_rx_alloc_skb+0x87/0x122 [e100]
 [<c58f9883>] ? e100_rx_alloc_skb+0x117/0x122 [e100]
 [<c58f98dc>] ? e100_alloc_cbs+0x4e/0xfa [e100]
 [<c58fb370>] ? e100_up+0x1b/0xf1 [e100]
 [<c58fb45d>] ? e100_open+0x17/0x3b [e100]
 [<c1121630>] ? __dev_open+0x7c/0xa0
 [<c11217ed>] ? __dev_change_flags+0x8b/0x100
 [<c11218c3>] ? dev_change_flags+0x10/0x3b
 [<c1159880>] ? devinet_ioctl+0x25a/0x532
 [<c11146d2>] ? sock_ioctl+0x1a8/0x1ca
 [<c111452a>] ? sock_ioctl+0x0/0x1ca
 [<c106e061>] ? do_vfs_ioctl+0x464/0x4a2
 [<c1014ce0>] ? do_page_fault+0x2d2/0x2ea
 [<c1014cc8>] ? do_page_fault+0x2ba/0x2ea
 [<c10636f6>] ? sys_faccessat+0x144/0x151
 [<c106e0cc>] ? sys_ioctl+0x2d/0x49
 [<c1177dd5>] ? syscall_call+0x7/0xb
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
Normal per-cpu:
CPU    0: hi:    6, btch:   1 usd:   0
active_anon:280 inactive_anon:808 isolated_anon:0
 active_file:1384 inactive_file:9672 isolated_file:0
 unevictable:0 dirty:77 writeback:0 unstable:0
 free:753 slab_reclaimable:499 slab_unreclaimable:1393
 mapped:375 shmem:643 pagetables:59 bounce:0
DMA free:1492kB min:248kB low:308kB high:372kB active_anon:0kB inactive_anon:12kB active_file:288kB inactive_file:12548kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15864kB mlocked:0kB dirty:48kB writeback:0kB mapped:28kB shmem:0kB slab_reclaimable:312kB slab_unreclaimable:884kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 47 47
Normal free:1520kB min:764kB low:952kB high:1144kB active_anon:1120kB inactive_anon:3220kB active_file:5248kB inactive_file:26140kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:48768kB mlocked:0kB dirty:260kB writeback:0kB mapped:1472kB shmem:2572kB slab_reclaimable:1684kB slab_unreclaimable:4688kB kernel_stack:176kB pagetables:236kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 51*4kB 23*8kB 3*16kB 3*32kB 7*64kB 4*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1492kB
Normal: 260*4kB 26*8kB 1*16kB 0*32kB 0*64kB 0*128kB 1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1520kB
11715 total pagecache pages
16 pages in swap cache
Swap cache stats: add 44, delete 28, find 72/72
Free swap  = 2179532kB
Total swap = 2179596kB
16383 pages RAM
826 pages reserved
10736 pages shared
5361 pages non-shared
ADDRCONF(NETDEV_UP): eth0: link is not ready
e100 0000:00:0f.0: eth0: NIC Link is Up 100 Mbps Full Duplex
ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
br0: port 1(eth1) entering forwarding state

Should I be concerned, please? All three e100 devices still appear to be working, but something nasty seems to have happened anyway.

The lspci output for these devices is:
00:0f.0 0200: 8086:1229 (rev 08)
	Subsystem: 8086:000c
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 72 (2000ns min, 14000ns max), Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 10
	Region 0: Memory at ffbeb000 (32-bit, non-prefetchable) [size=4K]
	Region 1: I/O ports at ef00 [size=64]
	Region 2: Memory at fef00000 (32-bit, non-prefetchable) [size=1M]
	[virtual] Expansion ROM at 04000000 [disabled] [size=1M]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI+ D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=2 PME-
	Kernel driver in use: e100
	Kernel modules: e100

01:04.0 0200: 8086:1229 (rev 05)
	Subsystem: 8086:10f0
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 72 (2000ns min, 14000ns max), Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 11
	Region 0: Memory at ff0fe000 (32-bit, prefetchable) [size=4K]
	Region 1: I/O ports at fcc0 [size=32]
	Region 2: Memory at ff700000 (32-bit, non-prefetchable) [size=1M]
	[virtual] Expansion ROM at ff100000 [disabled] [size=1M]
	Capabilities: [dc] Power Management version 1
		Flags: PMEClk- DSI+ D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Kernel driver in use: e100
	Kernel modules: e100

01:05.0 0200: 8086:1229 (rev 05)
	Subsystem: 8086:10f0
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 72 (2000ns min, 14000ns max), Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 10
	Region 0: Memory at ff0ff000 (32-bit, prefetchable) [size=4K]
	Region 1: I/O ports at fce0 [size=32]
	Region 2: Memory at ff900000 (32-bit, non-prefetchable) [size=1M]
	[virtual] Expansion ROM at ff200000 [disabled] [size=1M]
	Capabilities: [dc] Power Management version 1
		Flags: PMEClk- DSI+ D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Kernel driver in use: e100
	Kernel modules: e100

Thanks,
Chris


      

------------------------------------------------------------------------------
Gaining the trust of online customers is vital for the success of any company
that requires sensitive data to be transmitted over the Web.   Learn how to 
best implement a security strategy that keeps consumers' information secure 
and instills the confidence they need to proceed with transactions.
http://p.sf.net/sfu/oracle-sfdevnl 
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
