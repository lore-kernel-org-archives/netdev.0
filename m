From: Florian Westphal <fw@strlen.de>
Subject: Re: Fw: [Bug 86851] New: Reproducible panic on heavy UDP traffic
Date: Sat, 25 Oct 2014 23:44:49 +0200
Message-ID: <20141025214448.GB28407@breakpoint.cc>
References: <20141025141038.26fa5ac2@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nikolay@redhat.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:53998 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751736AbaJYVow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Oct 2014 17:44:52 -0400
Content-Disposition: inline
In-Reply-To: <20141025141038.26fa5ac2@uryu.home.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <stephen@networkplumber.org> wrote:

[ CC Nik ]

> Date: Fri, 24 Oct 2014 11:34:08 -0700
> From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
> To: "stephen@networkplumber.org" <stephen@networkplumber.org>
> Subject: [Bug 86851] New: Reproducible panic on heavy UDP traffic
> 
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=86851
> 
>             Bug ID: 86851
>            Summary: Reproducible panic on heavy UDP traffic
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 3.18-rc1
>           Hardware: x86-64
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>           Assignee: shemminger@linux-foundation.org
>           Reporter: chutzpah@gentoo.org
>         Regression: No
> 
> Created attachment 154861
>   --> https://bugzilla.kernel.org/attachment.cgi?id=154861&action=edit
> Panic message captured over serial console

 general protection fault: 0000 [#1] SMP
 Modules linked in: nfs [..]
 CPU: 7 PID: 257 Comm: kworker/7:1 Tainted: G        W      3.18.0-rc1-base-7+ #2

asked reporter to check if there is a warning before the oops.

 Hardware name: Intel Corporation S2600GZ/S2600GZ, BIOS SE5C600.86B.02.03.0003.041920141333 04/19/2014
 Workqueue: events inet_frag_worker
 task: ffff882fd32e70e0 ti: ffff882fd0adc000 task.ti: ffff882fd0adc000
 RIP: 0010:[<ffffffff81592ab4>]  [<ffffffff81592ab4>] inet_evict_bucket+0xf4/0x180
 RSP: 0018:ffff882fd0adfd58  EFLAGS: 00010286
 RAX: ffff8817c7230701 RBX: dead000000100100 RCX: 0000000180300013

Hello LIST_POISON!

 RDX: 0000000180300014 RSI: 0000000000000001 RDI: dead0000001000c0
 RBP: 0000000000000002 R08: 0000000000000202 R09: ffff88303fc39ab0
 R10: ffffffff81592ac0 R11: ffffea005f1c8c00 R12: ffffffff81aa2820
 R13: ffff882fd0adfd70 R14: ffff8817c72307e0 R15: 0000000000000000
 FS:  0000000000000000(0000) GS:ffff88303fc20000(0000) knlGS:0000000000000000
 CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
 device rack0a left promiscuous mode
 CR2: 00007f054c7ba034 CR3: 0000002fc4986000 CR4: 00000000001407e0
 Stack:
  ffffffff81aa3298 ffffffff81aa3290 ffff8817d0820a08 0000000000000000
  0000000000000000 00000000000000a8 0000000000000008 ffff88303fc32780
  ffffffff81aa6820 0000000000000059[ 2415.026338] device rack1a left promiscuous mode

  0000000000000000 ffffffff81592ba2
 Call Trace:
  [<ffffffff81592ba2>] ? inet_frag_worker+0x62/0x210
  [<ffffffff8112c312>] ? process_one_work+0x132/0x360
[..]
crash is in hlist_for_each_entry_safe() at the end of inet_evict_bucket(), looks like
we encounter an already-list_del'd element while iterating.

Will look at this tomorrow.
