From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [Bug 42754] New: BUG: sleeping function called from invalid
 context at mm/memory.c:3924
Date: Fri, 10 Feb 2012 16:38:02 +0100
Message-ID: <1328888282.25989.5.camel@laptop>
References: <bug-42754-27@https.bugzilla.kernel.org/>
	 <20120209191317.2fbad57b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, baryluk@smp.if.uj.edu.pl,
	bugzilla-daemon@bugzilla.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:59859 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757203Ab2BJPiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 10:38:18 -0500
Received: from 178-85-86-190.dynamic.upc.nl ([178.85.86.190] helo=dyad.programming.kicks-ass.net)
	by casper.infradead.org with esmtpsa (Exim 4.76 #1 (Red Hat Linux))
	id 1RvsYC-0006VU-Nr
	for netdev@vger.kernel.org; Fri, 10 Feb 2012 15:38:16 +0000
In-Reply-To: <20120209191317.2fbad57b.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-02-09 at 19:13 -0800, Andrew Morton wrote:
> > [ 1203.050623] BUG: sleeping function called from invalid context at
> > mm/memory.c:3924
> > [ 1203.054259] in_atomic(): 1, irqs_disabled(): 0, pid: 4446, name:
> > NetworkManager
> > [ 1203.057932] INFO: lockdep is turned off.

This here should have been a listing of all held locks when this
happened, however due to an earlier error lockdep has already been
disabled (means it stops tracking state and printing anything would be
printing nonsense).

This suggests this isn't the first error hit.

> > [ 1203.061685] Pid: 4446, comm: NetworkManager Tainted: G        W  O
> > 3.3.0-rc2-t43-devel-smp-00172-g23783f8 #13
> > [ 1203.065606] Call Trace:
> > [ 1203.069502]  [<c107e182>] __might_sleep+0x122/0x1d0
> > [ 1203.073506]  [<c1140b4e>] might_fault+0x2e/0xb0
> > [ 1203.077501]  [<c131c67b>] copy_to_user+0x3b/0x60
> > [ 1203.081561]  [<c158a102>] put_cmsg+0x52/0xd0
> > [ 1203.085624]  [<c15bc7d7>] netlink_recvmsg+0x287/0x340
> > [ 1203.089740]  [<c1579b43>] sock_recvmsg+0xd3/0x110
> > [ 1203.093902]  [<c1140b74>] ? might_fault+0x54/0xb0
> > [ 1203.098093]  [<c158834c>] ? verify_iovec+0x4c/0xc0
> > [ 1203.102336]  [<c1579a70>] ? sock_sendmsg_nosec+0x100/0x100
> > [ 1203.106611]  [<c157a994>] __sys_recvmsg+0x114/0x1e0
> > [ 1203.110942]  [<c1081dc7>] ? finish_task_switch+0x77/0x200
> > [ 1203.115315]  [<c11784b5>] ? fget_light+0xc5/0x410
> > [ 1203.119722]  [<c1081dc7>] ? finish_task_switch+0x77/0x200
> > [ 1203.124167]  [<c11784c9>] ? fget_light+0xd9/0x410
> > [ 1203.128618]  [<c1178435>] ? fget_light+0x45/0x410
> > [ 1203.133102]  [<c157c659>] sys_recvmsg+0x39/0x60
> > [ 1203.137590]  [<c157cbb3>] sys_socketcall+0x2e3/0x330
> > [ 1203.142147]  [<c17cf58d>] ? sysenter_exit+0xf/0x1a
> > [ 1203.146707]  [<c131be78>] ? trace_hardirqs_on_thunk+0xc/0x10
> > [ 1203.151358]  [<c17cf558>] sysenter_do_call+0x12/0x38

> Peter, is there any way in which lockdep can help us find the culprit
> in the second case? 
