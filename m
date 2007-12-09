From: Andrew Morton <akpm@linux-foundation.org>
Subject: tcp assertion failures in 2.6.24-rc4-mm1
Date: Sun, 9 Dec 2007 00:23:57 -0800
Message-ID: <20071209002357.e6d081e8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ilpo =?ISO-8859-1?B?SuRydmluZW4=?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:57008 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750773AbXLIIYj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Dec 2007 03:24:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is a mac g5.  It is being used as a distcc server across the LAN
when...

windfarm: CPUs control loops started.
EXT3-fs: INFO: recovery required on readonly filesystem.
EXT3-fs: write access will be enabled during recovery.
kjournald starting.  Commit interval 5 seconds
EXT3-fs: recovery complete.
EXT3-fs: mounted filesystem with ordered data mode.
audit(1197190525.100:2): audit_pid=1989 old=0 by auid=4294967295
KERNEL: assertion (packets <= tp->packets_out) failed at net/ipv4/tcp_input.c (2136)
KERNEL: assertion (packets <= tp->packets_out) failed at net/ipv4/tcp_input.c (2136)
------------[ cut here ]------------
Badness at net/ipv4/tcp_input.c:2518
NIP: c0000000003d46a4 LR: c0000000003d4d84 CTR: c000000000408914
REGS: c000000177b770e0 TRAP: 0700   Not tainted  (2.6.24-rc4-mm1)
MSR: 9000000000029032 <EE,ME,IR,DR>  CR: 24002488  XER: 00000000
TASK = c000000178868540[8316] 'cc1' THREAD: c000000177b74000 CPU: 1
NIP [c0000000003d46a4] .tcp_ack+0xd5c/0x1ce8
LR [c0000000003d4d84] .tcp_ack+0x143c/0x1ce8
Call Trace:
[c000000177b77360] [c0000000003d4d84] .tcp_ack+0x143c/0x1ce8 (unreliable)
[c000000177b77530] [c0000000003d81ac] .tcp_rcv_established+0x2fc/0x8d4
[c000000177b775e0] [c0000000003e2818] .tcp_v4_do_rcv+0x1fc/0x580
[c000000177b776d0] [c0000000003e37e0] .tcp_v4_rcv+0xc44/0xd28
[c000000177b777e0] [c0000000003bd398] .ip_local_deliver+0xb4/0x2cc
[c000000177b77870] [c0000000003bd87c] .ip_rcv+0x2cc/0x6f0
[c000000177b77930] [c000000000396444] .netif_receive_skb+0x440/0x4bc
[c000000177b779f0] [c00000000028255c] .tg3_poll+0x71c/0xb78
[c000000177b77b30] [c000000000396888] .net_rx_action+0x1e4/0x26c
[c000000177b77be0] [c000000000069584] .__do_softirq+0xd8/0x190
[c000000177b77ca0] [c00000000000b95c] .do_softirq+0x94/0x9c
[c000000177b77d30] [c0000000000696f0] .irq_exit+0x70/0x88
[c000000177b77db0] [c00000000000b83c] .do_IRQ+0xa0/0x12c
[c000000177b77e30] [c000000000004790] hardware_interrupt_entry+0x18/0x1c
Instruction dump:
7d7a5b78 3b200000 409e0008 933b0584 811b0584 39200000 2fa80000 409e0018 
801b0588 2f800000 419e000c 39200001 <0fe00000> 2fa90000 409e0d60 72b40040 
KERNEL: assertion (packets <= tp->packets_out) failed at net/ipv4/tcp_input.c (2136)
------------[ cut here ]------------

It's done that three times so far.
