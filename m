From: Cedric Le Goater <clg@fr.ibm.com>
Subject: Re: 2.6.24-rc4-mm1 - BUG in tcp_fragment
Date: Thu, 13 Dec 2007 18:45:10 +0100
Message-ID: <47616FA6.1010607@fr.ibm.com>
References: <20071204211701.994dfce6.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:56367 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754152AbXLMRpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 12:45:15 -0500
In-Reply-To: <20071204211701.994dfce6.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> Temporarily at
> 
>   http://userweb.kernel.org/~akpm/2.6.24-rc4-mm1/
> 
> Will appear later at
> 
>   ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.24-rc4/2.6.24-rc4-mm1/

I got this one while compiling on NFS.

C.

kernel BUG at /home/legoater/linux/2.6.24-rc4-mm1/include/net/tcp.h:1480!
invalid opcode: 0000 [1] SMP 
last sysfs file: /sys/devices/pci0000:00/0000:00:1e.0/0000:01:01.0/local_cpus
CPU 1 
Modules linked in: autofs4 nfs lockd sunrpc tg3 sg joydev ext3 jbd ehci_hcd ohci_hcd uhci_hcd
Pid: 0, comm: swapper Not tainted 2.6.24-rc4-mm1 #3
RIP: 0010:[<ffffffff80418d93>]  [<ffffffff80418d93>] tcp_fragment+0x5ee/0x6f7
RSP: 0018:ffff810147c9f9e0  EFLAGS: 00010217
RAX: 000000001526c311 RBX: ffff8100c2ce1d00 RCX: ffff810143cc6aa0
RDX: 0000000000000001 RSI: ffff810102b37b00 RDI: ffff810102b37b50
RBP: ffff810147c9fa50 R08: 000000000000004a R09: 0000000000000001
R10: 0000000000000b50 R11: 0000000000000001 R12: ffff81013a575700
R13: 0000000000000000 R14: ffff810143cc6400 R15: ffff81013a575750
FS:  0000000000000000(0000) GS:ffff810147c57140(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 00002ad5d294b000 CR3: 00000000bd11b000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 0, threadinfo ffff810147c98000, task ffff810147c89040)
Stack:  ffff810147c9fa00 ffffffff00000000 000005a843cc6400 ffff810143cc6400
 ffff810147c9fa70 ffff8100c2ce1d50 ffff810143cc6590 ffff810143cc6aa0
 1526542100000000 ffff810143cc6400 ffff810143cc6400 ffff81013a575700
Call Trace:
 <IRQ>  [<ffffffff804190c7>] tcp_retransmit_skb+0xd6/0x713
 [<ffffffff804197d4>] tcp_xmit_retransmit_queue+0xd0/0x330
 [<ffffffff8041209b>] tcp_fastretrans_alert+0xb92/0xbf2
 [<ffffffff80413f30>] tcp_ack+0xdf3/0xfbe
 [<ffffffff80417295>] tcp_rcv_established+0x66a/0x76d
 [<ffffffff8041d285>] tcp_v4_do_rcv+0x37/0x3aa
 [<ffffffff8041fb73>] tcp_v4_rcv+0x9a9/0xa76
 [<ffffffff80402e4e>] ip_local_deliver_finish+0x161/0x23c
 [<ffffffff80403363>] ip_local_deliver+0x72/0x77
 [<ffffffff80402ca9>] ip_rcv_finish+0x371/0x3b5
 [<ffffffff804032bd>] ip_rcv+0x292/0x2c6
 [<ffffffff803e3dcc>] netif_receive_skb+0x267/0x340
 [<ffffffff8806eff4>] :tg3:tg3_poll+0x5d2/0x89e
 [<ffffffff803e639d>] net_rx_action+0xd5/0x1ad
 [<ffffffff8023b605>] __do_softirq+0x5f/0xe3
 [<ffffffff8020c86c>] call_softirq+0x1c/0x28
 [<ffffffff8020e739>] do_softirq+0x39/0x9f
 [<ffffffff8023b5a4>] irq_exit+0x4e/0x50
 [<ffffffff8020e880>] do_IRQ+0xb7/0xd7
 [<ffffffff8020a803>] mwait_idle+0x0/0x55
 [<ffffffff8020bb66>] ret_from_intr+0x0/0xf
 <EOI>  [<ffffffff8024d623>] __atomic_notifier_call_chain+0x20/0x83
 [<ffffffff8020a84b>] mwait_idle+0x48/0x55
 [<ffffffff80209e79>] enter_idle+0x22/0x24
 [<ffffffff8020a793>] cpu_idle+0xa1/0xc5
 [<ffffffff8021dfd5>] start_secondary+0x3b9/0x3c5


Code: 0f 0b eb fe 48 85 f6 74 08 8b 46 6c 3b 41 68 75 55 48 8d 41 
RIP  [<ffffffff80418d93>] tcp_fragment+0x5ee/0x6f7
 RSP <ffff810147c9f9e0>
Kernel panic - not syncing: Aiee, killing interrupt handler!
