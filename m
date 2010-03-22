From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 15582] New: BUG: unable to handle kernel NULL pointer
 dereference at 0000000000000028
Date: Mon, 22 Mar 2010 16:14:16 -0700
Message-ID: <20100322161416.c4b369f9.akpm@linux-foundation.org>
References: <bug-15582-27@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	stivi@kity.pl
To: Patrick McHardy <kaber@trash.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Alex Duyck <alexa
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:34236 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751696Ab0CVXP1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 19:15:27 -0400
In-Reply-To: <bug-15582-27@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 19 Mar 2010 12:01:10 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=15582
> 
>            Summary: BUG: unable to handle kernel NULL pointer dereference
>                     at 0000000000000028

A bug in igb or the vlan code, I guess.

>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 2.6.33.1
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: akpm@linux-foundation.org
>         ReportedBy: stivi@kity.pl
>         Regression: No
> 
> 
> Distribution:Debian Lenny
> 
> Hardware Environment:
> INTEL Server Board S5520HC
> Intel(R) Xeon(R) CPU X5560  @ 2.80GHz
> 2x RAID bus controller 3ware Inc 9690SA-8I
> 
> Software Environment: squid (multi instances)
> 
> Problem Description:
> 
> The following error occurs whenever i halt the machine:
> [  439.629361] BUG: unable to handle kernel NULL pointer dereference at
> 0000000000000028
> [  439.723410] IP: [<ffffffff812462aa>] vlan_gro_common+0xd7/0x190
> [  439.794374] PGD 0
> [  439.818655] Oops: 0000 [#1] SMP
> [  439.857638] last sysfs file:
> /sys/devices/pci0000:00/0000:00:09.0/0000:05:00.0/host1/target1:0:0/1:0:0:0/block/sdc/queue/nr_requests
> [  440.000143] CPU 7
> [  440.024385] Pid: 0, comm: swapper Not tainted 2.6.33.1-univ #1
> S5520HC/S5520HC
> [  440.110817] RIP: 0010:[<ffffffff812462aa>]  [<ffffffff812462aa>]
> vlan_gro_common+0xd7/0x190
> [  440.210919] RSP: 0018:ffff8800283c3d10  EFLAGS: 00010203
> [  440.274472] RAX: 0000000000000001 RBX: ffff88066d5fd818 RCX:
> ffff8806683aa680
> [  440.359798] RDX: 00000000000003e7 RSI: 0000000000000000 RDI:
> ffff88066d2b2000
> [  440.445124] RBP: 00000000000003e7 R08: ffff88066c5ea000 R09:
> ffff8806683aa680
> [  440.530488] R10: 00000000000003e7 R11: 000000000000040b R12:
> 0000000000000000
> [  440.615816] R13: ffff88066d5fd818 R14: 000000000000003e R15:
> 000000000000040c
> [  440.701169] FS:  0000000000000000(0000) GS:ffff8800283c0000(0000)
> knlGS:0000000000000000
> [  440.797986] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  440.866705] CR2: 0000000000000028 CR3: 0000000001361000 CR4:
> 00000000000006e0
> [  440.952036] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> 0000000000000000
> [  441.037364] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> 0000000000000400
> [  441.122690] Process swapper (pid: 0, threadinfo ffff88066fa82000, task
> ffff88066fa7acd0)
> [  441.219462] Stack:
> [  441.243535]  ffff8806683aa680 ffffffff812466c7 0000000000000246
> ffff8806683aa680
> [  441.330462] <0> 000000000000003e ffff88066d5fd680 0000000000000008
> ffffffffa00b1871
> [  441.422868] <0> 0000000000000000 0000000000000000 0000000000000000
> 0000000000000000
> [  441.517692] Call Trace:
> [  441.546959]  <IRQ>
> [  441.572233]  [<ffffffff812466c7>] ? vlan_gro_receive+0x6e/0x83
> [  441.641993]  [<ffffffffa00b1871>] ? igb_poll+0x741/0xe80 [igb]
> [  441.711790]  [<ffffffff811e07ee>] ? net_rx_action+0xa8/0x1a1
> [  441.779478]  [<ffffffff81039ffe>] ? __do_softirq+0xd7/0x195
> [  441.846122]  [<ffffffff8100370c>] ? call_softirq+0x1c/0x28
> [  441.911727]  [<ffffffff81005325>] ? do_softirq+0x31/0x63
> [  441.975300]  [<ffffffff81039df4>] ? irq_exit+0x36/0x78
> [  442.036746]  [<ffffffff81004a26>] ? do_IRQ+0xa7/0xbd
> [  442.096119]  [<ffffffff81258ed3>] ? ret_from_intr+0x0/0xa
> [  442.160685]  <EOI>
> [  442.185957]  [<ffffffff811cad43>] ? poll_idle+0x1b/0x55
> [  442.248444]  [<ffffffff811cad32>] ? poll_idle+0xa/0x55
> [  442.309890]  [<ffffffff811cb06a>] ? cpuidle_idle_call+0x8e/0xe8
> [  442.380683]  [<ffffffff81001cd4>] ? cpu_idle+0x53/0x8b
> [  442.442133] Code: 41 81 79 7e 88 09 0f 85 d1 00 00 00 44 89 d2 44 89 d0 66
> 81 e2 ff 0f 80 cc 10 66 41 89 81 b8 00 00 00 89 d0 66 c1 e8 09 0f b7 c0 <48> 8b
> 4c c6 20 31 c0 48 85 c9 74 0c 48 89 d0 25 ff$
> [  442.678920] RIP  [<ffffffff812462aa>] vlan_gro_common+0xd7/0x190
> [  442.750922]  RSP <ffff8800283c3d10>
> [  442.792645] CR2: 0000000000000028
> [  442.832293] ---[ end trace 9245d00ed2188cae ]---
> [  442.887516] Kernel panic - not syncing: Fatal exception in interrupt
> [  442.963506] Pid: 0, comm: swapper Tainted: G      D    2.6.33.1-univ #1
> [  443.042610] Call Trace:
> [  443.071875]  <IRQ>  [<ffffffff812568b7>] ? panic+0x86/0x145
> [  443.138593]  [<ffffffff81039e06>] ? irq_exit+0x48/0x78
> [  443.200050]  [<ffffffff81258ed3>] ? ret_from_intr+0x0/0xa
> [  443.264661]  [<ffffffff8103554c>] ? kmsg_dump+0x99/0x124
> [  443.328202]  [<ffffffff81006416>] ? oops_end+0x9f/0xac
> [  443.389656]  [<ffffffff8101e9af>] ? no_context+0x1f2/0x201
> [  443.455263]  [<ffffffffa014cd20>] ? bond_dev_queue_xmit+0x14c/0x169
> [bonding]
> [  443.540611]  [<ffffffff8101eb65>] ? __bad_area_nosemaphore+0x1a7/0x1cb
> [  443.618679]  [<ffffffff811e0d8f>] ? dev_hard_start_xmit+0x221/0x2dd
> [  443.693630]  [<ffffffff811e134d>] ? dev_queue_xmit+0x401/0x433
> [  443.763397]  [<ffffffff812590df>] ? page_fault+0x1f/0x30
> [  443.826927]  [<ffffffff812462aa>] ? vlan_gro_common+0xd7/0x190
> [  443.896686]  [<ffffffff812466c7>] ? vlan_gro_receive+0x6e/0x83
> [  443.966485]  [<ffffffffa00b1871>] ? igb_poll+0x741/0xe80 [igb]
> [  444.036246]  [<ffffffff811e07ee>] ? net_rx_action+0xa8/0x1a1
> [  444.103927]  [<ffffffff81039ffe>] ? __do_softirq+0xd7/0x195
> [  444.170569]  [<ffffffff8100370c>] ? call_softirq+0x1c/0x28
> [  444.236176]  [<ffffffff81005325>] ? do_softirq+0x31/0x63
> [  444.299704]  [<ffffffff81039df4>] ? irq_exit+0x36/0x78
> [  444.361157]  [<ffffffff81004a26>] ? do_IRQ+0xa7/0xbd
> [  444.420533]  [<ffffffff81258ed3>] ? ret_from_intr+0x0/0xa
> [  444.485101]  <EOI>  [<ffffffff811cad43>] ? poll_idle+0x1b/0x55
> [  444.555036]  [<ffffffff811cad32>] ? poll_idle+0xa/0x55
> [  444.616486]  [<ffffffff811cb06a>] ? cpuidle_idle_call+0x8e/0xe8
> [  444.687283]  [<ffffffff81001cd4>] ? cpu_idle+0x53/0x8b
> 
> Steps to reproduce: Whenever i halt the machine.
> 
> 
> Igb driver is replaced by:
> http://downloadcenter.intel.com/detail_desc.aspx?agr=Y&DwnldID=13663
> 
> This is the same machine from bugs:
> https://bugzilla.kernel.org/show_bug.cgi?id=15148,
> https://bugzilla.kernel.org/show_bug.cgi?id=15581.
> 

