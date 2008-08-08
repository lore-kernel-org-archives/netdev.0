From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [BUG] NULL pointer dereference in skb_dequeue
Date: Fri, 8 Aug 2008 13:38:32 -0600
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365F1FDE30F1@rrsmsx501.amr.corp.intel.com>
References: <20080802.122251.94384264.davem@davemloft.net>
	<EA929A9653AAE14F841771FB1DE5A1365F1FBE8B37@rrsmsx501.amr.corp.intel.com>
	<EA929A9653AAE14F841771FB1DE5A1365F1FBE8B45@rrsmsx501.amr.corp.intel.com>
 <20080802.192639.02765648.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "jarkao2@gmail.com" <jarkao2@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:11529 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751677AbYHHTih convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2008 15:38:37 -0400
In-Reply-To: <20080802.192639.02765648.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
> Date: Sat, 2 Aug 2008 15:46:13 -0600
>
>> Disregard my previous emails. This patch seems to fix the panic. I
>> will leave a longer term stress test running to make sure it'stable.
>
> Thanks for testing, I'll commit the final patch and get it to
> Linus.
>
> Thanks again.

I ran into similar panic again. This time on driver reload while passing traffic.

igb: probe of 0000:0c:00.0 failed with error -2
BUG: unable to handle kernel NULL pointer dereference at 0000000000000000
IP: [<ffffffff8047bab8>] __skb_dequeue+0x2a/0x35
PGD 0
Oops: 0002 [1] SMP
CPU 1
Modules linked in: igb(-) nfsd lockd exportfs sunrpc pci_slot inet_lro [last unloaded: igb]
Pid: 0, comm: swapper Not tainted 2.6.27-rc2-igb #2
RIP: 0010:[<ffffffff8047bab8>]  [<ffffffff8047bab8>] __skb_dequeue+0x2a/0x35
RSP: 0018:ffff8801af89beb8  EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffff88019a5bf6f8 RCX: ffff88018bb01180
RDX: ffff88019a5bf6f8 RSI: ffff88019a5bf6a4 RDI: ffff88019a5bf6f8
RBP: ffff88019a5bf600 R08: ffff880028042140 R09: ffff8801af88f110
R10: ffff880028043d40 R11: ffffffff8021aea9 R12: ffffffff80686c00
R13: 0000000000000008 R14: 0000000000000000 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff8801af868c40(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 0000000000000000 CR3: 0000000000201000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 0, threadinfo ffff8801af896000, task ffff8801af88f110)
Stack:  ffffffff8047bc9c 0000000000000008 ffff88019a5bf600 ffff88019a5bf6b0
 ffffffff8047c6a6 ffff880028043d40 ffff88019ac294b0 0000000000000002
 ffffffff80259b78 0000000000000001 ffffffff8067d0c0 000000000000000a
Call Trace:
 <IRQ>  [<ffffffff8047bc9c>] ? pfifo_fast_reset+0x1f/0x4c
 [<ffffffff8047c6a6>] ? __qdisc_destroy+0x43/0x8b
 [<ffffffff80259b78>] ? __rcu_process_callbacks+0x107/0x16a
 [<ffffffff80259bfe>] ? rcu_process_callbacks+0x23/0x43
 [<ffffffff80234f94>] ? __do_softirq+0x53/0xa0
 [<ffffffff8020c58c>] ? call_softirq+0x1c/0x28
 [<ffffffff8020dd91>] ? do_softirq+0x2c/0x6b
 [<ffffffff80234e98>] ? irq_exit+0x3f/0x90
 [<ffffffff8021b222>] ? smp_apic_timer_interrupt+0x76/0x81
 [<ffffffff8020bfd6>] ? apic_timer_interrupt+0x66/0x70
 <EOI>  [<ffffffff80211668>] ? mwait_idle+0x35/0x38
 [<ffffffff80209e0a>] ? cpu_idle+0x69/0x9b


Code: c3 48 8b 0f 48 39 f9 75 04 31 c9 eb 25 48 85 c9 74 20 ff 4f 10 48 8b 11 48 8b 41 08 48 c7 01 00 00 00 00 48 c7 41 08 00 00 00 00 <48> 89 10 48 89 42 08 48 89 c8 c3 41 55 49 89 f5 41 54 49 89 d4
RIP  [<ffffffff8047bab8>] __skb_dequeue+0x2a/0x35
 RSP <ffff8801af89beb8>
CR2: 0000000000000000
---[ end trace ccfa2c2f2295fda5 ]---
Kernel panic - not syncing: Aiee, killing interrupt handler

And another one (incomplete):

BUG: unable to handle kernel NULL pointer dereference at 0000000000000098
IP: [<ffffffff804ebd9b>] _spin_lock+0x5/0x15

Thanks,
Emil
