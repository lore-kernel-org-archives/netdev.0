From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: Linux 4.2-rc6 regression: RIP: e030:[<ffffffff8110fb18>]
 [<ffffffff8110fb18>] =?UTF-8?Q?detach=5Fif=5Fpending+=30x=31=38/=30x=38?=
 =?UTF-8?Q?=30?=
Date: Sat, 15 Aug 2015 00:16:58 +0200
Message-ID: <ac796067998c18f547aeba1c185a4cb6@eikelenboom.it>
References: <7c39e6332aae572372108d5fd68c503b@eikelenboom.it>
 <1439412094.29802.21.camel@edumazet-glaptop2.roam.corp.google.com>
 <0de9f30086ee2e662bdafee61d24b3c1@eikelenboom.it>
 <20150812.144040.1151964094247340464.davem@davemloft.net>
 <b5e9ffc27531e98bc2ac1e28d6a3d0f0@eikelenboom.it>
 <1439419279.29802.25.camel@edumazet-glaptop2.roam.corp.google.com>
 <3b284689aaa1573610c0e388e66e756a@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, xen-devel@lists.xen.org,
	david.vrabel@citrix.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vserver.eikelenboom.it ([84.200.39.61]:52198 "EHLO
	smtp.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751550AbbHNWWX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 18:22:23 -0400
In-Reply-To: <3b284689aaa1573610c0e388e66e756a@eikelenboom.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-08-15 00:09, Sander Eikelenboom wrote:
> On 2015-08-13 00:41, Eric Dumazet wrote:
>> On Wed, 2015-08-12 at 23:46 +0200, Sander Eikelenboom wrote:
>> 
>>> Thanks for the reminder, but luckily i was aware of that,
>>> seen enough of your replies asking for patches to be resubmitted
>>> against "the other tree" ;)
>>> Kernel with patch is currently running so fingers crossed.
>> 
>> Thanks for testing. I am definitely interested knowing your results.
> 
> Hmm it seems now commit 83fccfc3940c4a2db90fd7e7079f5b465cd8c6af is
> breaking things
> (have to test if a revert helps) i get this in some guests:

Should have done that before, because it wasn't in yet .. and likely to 
fix the issue,
also pulled and compiling now.

--
Sander



> NMI watchdog: BUG: soft lockup - CPU#0 stuck for 506s! [swapper/0:0]
> [ 6620.282805] Modules linked in:
> [ 6620.282805] CPU: 0 PID: 0 Comm: swapper/0 Not tainted
> 4.2.0-rc6-20150814-linus-doflr-apicrevert+ #1
> [ 6620.282805] task: ffffffff8221a580 ti: ffffffff82200000 task.ti:
> ffffffff82200000
> [ 6620.282805] RIP: e030:[<ffffffff8100122a>]  [<ffffffff8100122a>]
> xen_hypercall_xen_version+0xa/0x20
> [ 6620.282805] RSP: e02b:ffff88000fc03d48  EFLAGS: 00000246
> [ 6620.282805] RAX: 0000000000040006 RBX: 0000000000000200 RCX: 
> ffffffff8100122a
> [ 6620.282805] RDX: 0000000000000001 RSI: 00000000deadbeef RDI: 
> 00000000deadbeef
> [ 6620.282805] RBP: ffff88000fc03d60 R08: ffff88000fc03ee0 R09: 
> 00000000000000ee
> [ 6620.282805] R10: ffffffff8220a0c0 R11: 0000000000000246 R12: 
> 00000000ffffffff
> [ 6620.282805] R13: 0000000000000001 R14: ffff880003b53054 R15: 
> 0000000000000005
> [ 6620.282805] FS:  00007fec747ad800(0000) GS:ffff88000fc00000(0000)
> knlGS:0000000000000000
> [ 6620.282805] CS:  e033 DS: 0000 ES: 0000 CR0: 000000008005003b
> [ 6620.282805] CR2: 00007ffcb7a7a6d8 CR3: 0000000003164000 CR4: 
> 0000000000000660
> [ 6620.282805] Stack:
> [ 6620.282805]  0000000000000068 0000000000000007 ffffffff81008dbd
> ffff88000fc03dd8
> [ 6620.282805]  ffffffff81009592 0000000000000068 ffffffff8220a0c0
> 00000000000000ee
> [ 6620.282805]  ffff88000fc03ee0 0000000000000200 0000000000000200
> 0000000000000001
> [ 6620.282805] Call Trace:
> [ 6620.282805]  <IRQ>
> [ 6620.282805]  [<ffffffff81008dbd>] ? 
> xen_force_evtchn_callback+0xd/0x10
> [ 6620.282805]  [<ffffffff81009592>] check_events+0x12/0x20
> [ 6620.282805]  [<ffffffff8100957f>] ? 
> xen_restore_fl_direct_reloc+0x4/0x4
> [ 6620.282805]  [<ffffffff81af79a5>] ? 
> _raw_spin_unlock_irqrestore+0x25/0x30
> [ 6620.282805]  [<ffffffff8110ed43>] try_to_del_timer_sync+0x43/0x60
> [ 6620.282805]  [<ffffffff8110eda7>] del_timer_sync+0x47/0x60
> [ 6620.282805]  [<ffffffff81a2b698>] 
> inet_csk_reqsk_queue_drop+0x118/0x1f0
> [ 6620.282805]  [<ffffffff81a2b8c6>] reqsk_timer_handler+0x156/0x260
> [ 6620.282805]  [<ffffffff81a2b770>] ? 
> inet_csk_reqsk_queue_drop+0x1f0/0x1f0
> [ 6620.282805]  [<ffffffff8110f3c7>] call_timer_fn.isra.27+0x17/0x80
> [ 6620.282805]  [<ffffffff81a2b770>] ? 
> inet_csk_reqsk_queue_drop+0x1f0/0x1f0
> [ 6620.282805]  [<ffffffff8110f55d>] run_timer_softirq+0x12d/0x200
> [ 6620.282805]  [<ffffffff810ca6c3>] __do_softirq+0x103/0x210
> [ 6620.282805]  [<ffffffff810ca9cb>] irq_exit+0x4b/0xa0
> [ 6620.282805]  [<ffffffff814f05d4>] xen_evtchn_do_upcall+0x34/0x50
> [ 6620.282805]  [<ffffffff81af932e>] 
> xen_do_hypervisor_callback+0x1e/0x40
> [ 6620.282805]  <EOI>
> [ 6620.282805]  [<ffffffff810013aa>] ? xen_hypercall_sched_op+0xa/0x20
> [ 6620.282805]  [<ffffffff810013aa>] ? xen_hypercall_sched_op+0xa/0x20
> [ 6620.282805]  [<ffffffff81008d60>] ? xen_safe_halt+0x10/0x20
> [ 6620.282805]  [<ffffffff810188d3>] ? default_idle+0x13/0x20
> [ 6620.282805]  [<ffffffff81018e1a>] ? arch_cpu_idle+0xa/0x10
> [ 6620.282805]  [<ffffffff810f8e7e>] ? default_idle_call+0x2e/0x50
> [ 6620.282805]  [<ffffffff810f9112>] ? cpu_startup_entry+0x272/0x2e0
> [ 6620.282805]  [<ffffffff81ae7967>] ? rest_init+0x77/0x80
> [ 6620.282805]  [<ffffffff82312f58>] ? start_kernel+0x43b/0x448
> [ 6620.282805]  [<ffffffff823124ef>] ? 
> x86_64_start_reservations+0x2a/0x2c
> [ 6620.282805]  [<ffffffff82316008>] ? xen_start_kernel+0x550/0x55c
> [ 6620.282805] Code: cc 51 41 53 b8 10 00 00 00 0f 05 41 5b 59 c3 cc
> cc cc cc cc cc cc cc cc cc cc cc cc cc cc cc cc cc 51 41 53 b8 11 00
> 00 00 0f 05 <41> 5b 59 c3 cc cc cc cc cc cc cc cc cc cc cc cc cc cc cc
> cc cc
