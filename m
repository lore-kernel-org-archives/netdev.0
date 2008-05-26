From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10799] New: general protection fault: 0000 [1]
 SMP DEBUG_PAGEALLOC
Date: Mon, 26 May 2008 12:08:34 -0700
Message-ID: <20080526120834.af990412.akpm@linux-foundation.org>
References: <bug-10799-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, Nicolas.Mailhot@LaPoste.net,
	Jeff Garzik <jeff@garzik.org>
To: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:40916 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754720AbYEZTIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2008 15:08:51 -0400
In-Reply-To: <bug-10799-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 26 May 2008 11:05:09 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=10799
> 
>            Summary: general protection fault: 0000 [1] SMP DEBUG_PAGEALLOC
>            Product: Alternate Trees
>            Version: 2.5
>      KernelVersion: 2.6.26-0.17.rc3.fc10.x86_64 (2.6.26-rc3)
>           Platform: All
>         OS/Version: Linux
>               Tree: Fedora
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: ac
>         AssignedTo: alan@lxorguk.ukuu.org.uk
>         ReportedBy: Nicolas.Mailhot@LaPoste.net
> 
> 
> Latest working kernel version: 2.6.25.3-18.fc9.x86_64
> Earliest failing kernel version: 2.6.26-0.17.rc3.fc10.x86_64 (one-time)
> Distribution: Fedora devel
> Hardware Environment: AMD X2 on CK804
> Software Environment: Idle, background tasks with a few Internet-exposed ports
> Problem Description: general protection fault: 0000 [1] SMP DEBUG_PAGEALLOC

sky2 crashed in a 2.6.23-rc3-based Fedora kernel.  Apparently it's a regression.

15:19:09 sky2 eth0: hung mac 5:61 fifo 0 (181:181)
15:19:09 sky2 eth0: receiver hang detected
15:19:09 sky2 eth0: disabling interface
15:19:09 general protection fault: 0000 [1] SMP DEBUG_PAGEALLOC
15:19:09 CPU 1 
15:19:09 Pid: 10, comm: events/1 Not tainted 2.6.26-0.17.rc3.fc10.x86_64 #1
15:19:09 RIP: 0010:[<ffffffffa02083a9>]  [<ffffffffa02083a9>] :sky2:sky2_rx_unmap_skb+0x9e/0xb2
15:19:09 RSP: 0018:ffff81007f04fd60  EFLAGS: 00010212
15:19:09 RAX: 0000000000000000 RBX: 0000000000000000 RCX: 6b6b6b6bd6d6d6d6
15:19:09 RDX: 00000000000005f0 RSI: 000000007a46a978 RDI: ffff81007f3563e0
15:19:09 RBP: ffff81007f04fd90 R08: ffff81007f094000 R09: 000000000000005a
15:19:09 R10: ffff81007f04fcd0 R11: ffff8100010f9000 R12: ffff81007ad50438
15:19:09 R13: ffff81007f356360 R14: ffff81007f3563e0 R15: ffff81005a926b40
15:19:09 FS:  00007fccf0b99780(0000) GS:ffff81007f821640(0000) knlGS:0000000000000000
15:19:09 CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
15:19:09 CR2: 00007f2b6385b000 CR3: 000000005e664000 CR4: 00000000000006e0
15:19:09 DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
15:19:09 DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
15:19:09 Process events/1 (pid: 10, threadinfo ffff81007f04e000, task ffff81007f058000)
15:19:09 Stack:  ffff81007f04fd80 ffff81007ad50438 000000000000001b ffff81007e00b9e0
15:19:09 ffff81007e00b9e0 ffff81007e00b0e0 ffff81007f04fdc0 ffffffffa0209e18
15:19:09 ffff81007f04fdc0 0000000000000000 ffff81007e00b460 ffff81007b0016d0
15:19:09 ffff81007f04fe10 ffffffffa020b3ef ffffffff8104731d ffff81007b0017e8
15:19:09 0000000000000280 ffff81007b0017e8 0000000000000000 ffff81007b0016d0
15:19:09 ffff81007b0016d0 ffff81007b0016d0 ffff81007f04fe50 ffffffffa020c433
15:19:09 0000000000000010 ffff81007b0017f0 ffff81007fb6ee18 ffff81007b0017e8
15:19:09 ffff81007f04fe70 0000000000000008 ffff81007f04fec0 ffffffff81047368
15:19:09 Call Trace:
15:19:09 [<ffffffffa0209e18>] :sky2:sky2_rx_clean+0x49/0x71
15:19:09 [<ffffffffa020b3ef>] :sky2:sky2_down+0x232/0x2d2
15:19:09 [<ffffffff8104731d>] ? run_workqueue+0xb1/0x203
15:19:09 [<ffffffffa020c433>] :sky2:sky2_restart+0x3d/0x119
15:19:09 [<ffffffff81047368>] run_workqueue+0xfc/0x203
15:19:09 [<ffffffffa020c3f6>] ? :sky2:sky2_restart+0x0/0x119
15:19:09 [<ffffffff8104754f>] worker_thread+0xe0/0xf1
15:19:09 [<ffffffff8104aee0>] ? autoremove_wake_function+0x0/0x38
15:19:09 [<ffffffff8104746f>] ? worker_thread+0x0/0xf1
15:19:09 [<ffffffff8104abbf>] kthread+0x49/0x76
15:19:09 [<ffffffff8100cec8>] child_rip+0xa/0x12
15:19:09 [<ffffffff8100c5df>] ? restore_args+0x0/0x30
15:19:09 [<ffffffff8104ab76>] ? kthread+0x0/0x76
15:19:09 [<ffffffff8100cebe>] ? child_rip+0x0/0x12
15:19:09 
15:19:09 
15:19:09 Code: ed 48 8b 40 28 49 0f 45 fe 8b 54 11 14 48 85 c0 74 09 89 d2 b9 02 00 00 00 ff d0 ff c3 41 8b 8f c8 00 00 00 49 03 8f d0 00 00 00 <0f> b7 41 04 39 c3 7c af 58 5b 41 5c 41 5d 41 5e 41 5f c9 c3 48 
15:19:09 RIP  [<ffffffffa02083a9>] :sky2:sky2_rx_unmap_skb+0x9e/0xb2
15:19:09 RSP <ffff81007f04fd60>
15:19:09 ---[ end trace 7b796dfc30f625c9 ]---
