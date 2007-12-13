From: Andrew Morton <akpm@linux-foundation.org>
Subject: net-2.6.235 warning
Date: Wed, 12 Dec 2007 21:55:07 -0800
Message-ID: <20071212215507.46e9d72c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ilpo =?ISO-8859-1?B?SuRydmluZW4=?= <ilpo.jarvinen@helsinki.fi>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:38949 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750724AbXLMFzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 00:55:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is net-2.6.25 pulled ten hours ago.  Top of tree was
dc2d76df54c8211df766819749beb802f69733fc.  Herbert's two ipsec patches are
applied.

Mac g5 acting as a distcc server had been running an hour or so.

------------[ cut here ]------------
Badness at net/ipv4/tcp_input.c:1280
NIP: c0000000003d1fb0 LR: c0000000003d27d8 CTR: c0000000003d68dc
REGS: c00000012d506ee0 TRAP: 0700   Not tainted  (2.6.24-rc5-mm1)
MSR: 9000000000029032 <EE,ME,IR,DR>  CR: 28028428  XER: 20000000
TASK = c0000001783f1280[10480] 'as' THREAD: c00000012d504000 CPU: 3
GPR00: 0000000000000028 c00000012d507160 c0000000006d4518 0000000000000001 
GPR04: c00000012d1e3870 0000000007be5279 0000000007be57fe c0000001772f4d88 
GPR08: 000000000000002a 0000000000000000 0000000007be5279 0000000000000025 
GPR12: 0000000088048428 c00000000061b280 0000000000000000 0000000000000000 
GPR16: 0000000000000003 0000000007bd75e1 00000000e8510e30 c00000012d5072d0 
GPR20: c00000012d1e3d30 0000000000000000 c00000012d5072d0 c00000012d5072d4 
GPR24: c00000012d1e3938 0000000007be5279 0000000007be57fe c00000012d1e3938 
GPR28: c00000012d1e3870 0000000000000000 c000000000699b58 c000000177d3a818 
NIP [c0000000003d1fb0] .tcp_sacktag_walk+0x3e0/0x7e8
LR [c0000000003d27d8] .tcp_sacktag_write_queue+0x388/0xc84
Call Trace:
[c00000012d507160] [c00000012d5071f0] 0xc00000012d5071f0 (unreliable)
[c00000012d507240] [c0000000003d27d8] .tcp_sacktag_write_queue+0x388/0xc84
[c00000012d507350] [c0000000003d5308] .tcp_ack+0x950/0x1d98
[c00000012d507520] [c0000000003d99dc] .tcp_rcv_state_process+0x138/0xe90
[c00000012d5075e0] [c0000000003e3818] .tcp_v4_do_rcv+0xb0/0x580
[c00000012d5076d0] [c0000000003e492c] .tcp_v4_rcv+0xc44/0xd28
[c00000012d5077e0] [c0000000003be3e4] .ip_local_deliver+0xb4/0x2cc
[c00000012d507870] [c0000000003be8c8] .ip_rcv+0x2cc/0x6f0
[c00000012d507930] [c0000000003974d0] .netif_receive_skb+0x440/0x4bc
[c00000012d5079f0] [c0000000002830a8] .tg3_poll+0x71c/0xb78
[c00000012d507b30] [c000000000397914] .net_rx_action+0x1e4/0x26c
[c00000012d507be0] [c00000000006a33c] .__do_softirq+0xd8/0x190
[c00000012d507ca0] [c00000000000b95c] .do_softirq+0x94/0x9c
[c00000012d507d30] [c00000000006a4a8] .irq_exit+0x70/0x88
[c00000012d507db0] [c00000000000b83c] .do_IRQ+0xa0/0x12c
[c00000012d507e30] [c000000000004790] hardware_interrupt_entry+0x18/0x1c
Instruction dump:
7c0807b4 409efee4 801c03f8 7c005050 78090fe3 4082fef0 801c0588 7f804040 
409c0010 801c046c 7f804040 409c0008 <0fe00000> 881f0079 540007be 2f800001 

Here:


			WARN_ON((fack_count <= tp->fackets_out) ||
				(fack_count > tp->packets_out));


It isn't a good idea to put two conditions in a single assert like
this, btw.  When it fires you don't know which one caused it..
