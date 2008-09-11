From: Kandukuru_Suresh@emc.com
Subject: ifconfig: page allocation failure. order:2, mode:0x20 while enabling Jumbo frame
Date: Thu, 11 Sep 2008 16:42:22 -0400
Message-ID: <473F5AEA857EA644A9AD7693EBA8D9A203449248@CORPUSMX20B.corp.emc.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:49018 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754687AbYIKUmd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 16:42:33 -0400
Received: from hop04-l1d11-si02.isus.emc.com (HOP04-L1D11-SI02.isus.emc.com [10.254.111.55])
	by mexforward.lss.emc.com (Switch-3.2.5/Switch-3.1.7) with ESMTP id m8BKgVj2001910
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 16:42:31 -0400 (EDT)
Received: from mailhub.lss.emc.com (nirah.lss.emc.com [10.254.144.13]) by hop04-l1d11-si02.isus.emc.com (Tablus Interceptor) for <netdev@vger.kernel.org>; Mon, 11 Aug 2008 16:44:28 -0400
Received: from corpussmtp4.corp.emc.com (corpussmtp4.corp.emc.com [10.254.64.54])
	by mailhub.lss.emc.com (Switch-3.2.5/Switch-3.1.7) with ESMTP id m8BKg6Kh024783
	for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 16:42:24 -0400 (EDT)
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi
 On my Nas device (Linux kernel 2.6.22.7)  when I try enable to jumbo
frame the following error is coming. I  did not find enough information
from the net. So I  am mailing this. Please guide me  what is happening
here and How to resolve this error?

eth0: change mtu 1500 (buffer-size 1520) to 9004 (buffer-size 9024)
ifconfig: page allocation failure. order:2, mode:0x20
[<c00cd864>] (dump_stack+0x0/0x14) from [<c0025420>]
(__alloc_pages+0x2ac/0x2c0)
[<c0025174>] (__alloc_pages+0x0/0x2c0) from [<c0137c20>]
(cache_alloc_refill+0x294/0x550)
[<c013798c>] (cache_alloc_refill+0x0/0x550) from [<c00257e0>]
(__kmalloc+0x70/0x8c)
[<c0025770>] (__kmalloc+0x0/0x8c) from [<c028de90>]
(__alloc_skb+0x4c/0xf4)
 r4:c261baa0
[<c028de44>] (__alloc_skb+0x0/0xf4) from [<c0215234>]
(eth_rx_fill+0x64/0x1fc)
 r8:00000000 r7:00000018 r6:c046f380 r5:c046f380 r4:c261bb40
[<c02151d0>] (eth_rx_fill+0x0/0x1fc) from [<c0216090>]
(eth_start+0xb0/0x294)
[<c0215fe0>] (eth_start+0x0/0x294) from [<c021647c>]
(eth_open+0x3c/0x68)
 r8:c260bed8 r7:00000000 r6:00001002 r5:00000000 r4:c046f000
[<c0216440>] (eth_open+0x0/0x68) from [<c02939ac>] (dev_open+0x64/0xc8)
 r4:c046f000
[<c0293948>] (dev_open+0x0/0xc8) from [<c0294db4>]
(dev_change_flags+0x60/0x128)
 r5:00001043 r4:c046f000
[<c0294d54>] (dev_change_flags+0x0/0x128) from [<c02c7cbc>]
(devinet_ioctl+0x2dc/0x6cc)
 r7:bec44e6c r6:c1368380 r5:00000000 r4:ffffff9d
[<c02c79e0>] (devinet_ioctl+0x0/0x6cc) from [<c02c9bac>]
(inet_ioctl+0xcc/0x100)
[<c02c9ae0>] (inet_ioctl+0x0/0x100) from [<c0289be8>]
(sock_ioctl+0x1d4/0x22c)
[<c0289a14>] (sock_ioctl+0x0/0x22c) from [<c0145f54>]
(do_ioctl+0x3c/0x88)
 r7:00000000 r6:bec44e6c r5:ffffffe7 r4:c1208f20
[<c0145f18>] (do_ioctl+0x0/0x88) from [<c0146224>]
(vfs_ioctl+0x284/0x2a4)
 r6:00000003 r5:bec44e6c r4:c1208f20
[<c0145fa0>] (vfs_ioctl+0x0/0x2a4) from [<c0146284>]
(sys_ioctl+0x40/0x5c)
 r7:00000036 r6:00008914 r5:fffffff7 r4:c1208f20
[<c0146244>] (sys_ioctl+0x0/0x5c) from [<c003efa0>]
(ret_fast_syscall+0x0/0x2c)
 r6:00000000 r5:bec44efc r4:0006887c
Mem-info:
DMA per-cpu:
CPU    0: Hot: hi:   42, btch:   7 usd:   5   Cold: hi:   14, btch:   3
usd: 
11
Active:1697 inactive:27943 dirty:1130 writeback:0 unstable:0
 free:135 slab:1316 mapped:228 pagetables:50 bounce:0
DMA free:540kB min:1440kB low:1800kB high:2160kB active:6788kB
inactive:111772kB present:130048kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0
DMA: 1*4kB 1*8kB 1*16kB 0*32kB 0*64kB 0*128kB 0*256kB 1*512kB 0*1024kB
0*2048kB
0*4096kB = 540kB
Swap cache: add 0, delete 0, find 0/0, race 0+0
Free swap  = 0kB
Total swap = 0kB
Free swap:            0kB
32768 pages of RAM
231 free pages
1113 reserved pages
1316 slab pages
13082 pages shared
0 pages swap cached

Thank you very much
Suresh

 

