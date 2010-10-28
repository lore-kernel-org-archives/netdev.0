From: Doug Hughes <doug@will.to>
Subject: multi-machine simultaneous kernel panic in tcp_transmit_kcb
Date: Wed, 27 Oct 2010 21:04:10 -0400
Message-ID: <4CC8CC0A.5000705@will.to>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailman.will.to ([68.164.136.125]:56390 "EHLO will.to"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932267Ab0J1BPN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Oct 2010 21:15:13 -0400
Received: from [192.168.1.65] (h-68-164-136-126.nycmny83.static.covad.net [68.164.136.126])
	(authenticated bits=0)
	by will.to (8.14.3/8.14.3/Debian-5+lenny1) with ESMTP id o9S14BUu025323
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 21:04:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

3 machines within 1 minute of each other (odd, by itself, but not the 
root of the question).

2 of this:
2.6.18-164.15.1.el5 #1 SMP Wed Mar 17 11:30:06 EDT 2010 x86_64 x86_64 
x86_64 GNU/Linux
(I have a screen shot on the kvm)
all Cent 5.4

1 Xen instances with 2.6.18-128.1.14.el5xen #1 SMP Wed Jun 17 07:10:16 
EDT 2009 x86_64 x86_64 x86_64 GNU/Linux

a slightly older kernel but crashed within one minute of the other two. 
Since it's a xen, I have a text traceback:

  Pid: 0, comm: swapper Not tainted 2.6.18-128.1.14.el5xen #1
RIP: e030:[<ffffffff8040e077>]  [<ffffffff8040e077>] pskb_copy+0x133/0x1b1
RSP: e02b:ffffffff8066ade0  EFLAGS: 00010282
RAX: ffff8800325fa120 RBX: ffff8800434f5780 RCX: ffff88006d311930
RDX: 656363612f647074 RSI: ffff8800325fa130 RDI: 0000000000000002
RBP: ffff8800549aa680 R08: 7ffffffffffffffe R09: 0000000000000000
R10: ffff8800434f5780 R11: 00000000000000c8 R12: 0000000000000220
R13: ffff8800549aa680 R14: 0000000000000000 R15: ffffffffff578000
FS:  00002b84514af260(0000) GS:ffffffff805ba000(0000) knlGS:0000000000000000
CS:  e033 DS: 0000 ES: 0000
Process swapper (pid: 0, threadinfo ffffffff8062a000, task ffffffff804e0a80)
Stack:  ffffffff802886d9  ffff88006ad3d280  0000000000000001  ffffffff80222485
  ffff880025665380  000000017d0f80ab  0000000000000001  ffff88006ad3d280
  ffff8800549aa680  00000000ffffff8f
Call Trace:
<IRQ>  [<ffffffff802886d9>] rebalance_tick+0x18b/0x3d4
  [<ffffffff80222485>] tcp_transmit_skb+0x73/0x667
  [<ffffffff8043903a>] tcp_retransmit_skb+0x53d/0x638
  [<ffffffff8043a569>] tcp_write_timer+0x0/0x68e
  [<ffffffff8043a9d6>] tcp_write_timer+0x46d/0x68e
  [<ffffffff80291f8b>] run_timer_softirq+0x13f/0x1c6
  [<ffffffff802130d6>] __do_softirq+0x8d/0x13b
  [<ffffffff80260da4>] call_softirq+0x1c/0x278
  [<ffffffff8026e0be>] do_softirq+0x31/0x98
  [<ffffffff8026df39>] do_IRQ+0xec/0xf5
  [<ffffffff803a7b94>] evtchn_do_upcall+0x13b/0x1fb
  [<ffffffff802608d6>] do_hypervisor_callback+0x1e/0x2c
<EOI>  [<ffffffff802063aa>] hypercall_page+0x3aa/0x1000
  [<ffffffff802063aa>] hypercall_page+0x3aa/0x1000
  [<ffffffff8026f511>] raw_safe_halt+0x84/0xa8
  [<ffffffff8026ca52>] xen_idle+0x38/0x4a
  [<ffffffff8024b0d8>] cpu_idle+0x97/0xba
  [<ffffffff80634b09>] start_kernel+0x21f/0x224
  [<ffffffff806341e5>] _sinittext+0x1e5/0x1eb


Code: 48 8b 02 25 00 40 02 00 48 3d 00 40 02 00 75 04 48 8b 52 10
RIP  [<ffffffff8040e077>] pskb_copy+0x133/0x1b1
  RSP <ffffffff8066ade0>
<0>Kernel panic - not syncing: Fatal exception


---

The first 4 lines of the trace on the xen and the non-xen are the same 
except for the addresses.

In fact, they are the same up until the 9th line where they start to 
diverge a little bit.

The last thing in the kern log before the crash on one was an nfs server 
not responding, but those happen sporadically and often enough that I 
don't suspect it's related.

Given that its looks, seemed like an appropriate question for netdev 
(following a failed google search)





