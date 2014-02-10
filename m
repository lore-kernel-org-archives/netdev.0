From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: irda: BUG: looking up invalid subclass: 4294967295
Date: Mon, 10 Feb 2014 22:39:59 +0100
Message-ID: <20140210213959.GY2936@laptop.programming.kicks-ass.net>
References: <20140210213126.GA26078@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:36866 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751594AbaBJVkC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 16:40:02 -0500
Content-Disposition: inline
In-Reply-To: <20140210213126.GA26078@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 10, 2014 at 04:31:26PM -0500, Dave Jones wrote:
> Is this irda being crap, or some weird lockdep corner case ?
> 
> (no idea what the W taint was, some unrelated spew pushed it out
>  of the dmesg buffer before it got chance to hit the log)
> 
> 	Dave
> 
> BUG: looking up invalid subclass: 4294967295

That's -1 if I'm not mistaken, that's indeed an invalid subclass.

> turning off the locking correctness validator.
> CPU: 0 PID: 1965 Comm: trinity-main Tainted: G        W    3.14.0-rc1+ #108
>  00000000ffffffff 00000000a8765326 ffff880205ee7c40 ffffffff9872ae0a
>  00000000ffffffff ffff880205ee7c58 ffffffff9872732c ffff880084069730
>  ffff880205ee7cd0 ffffffff980c10e2 000000010016000f 00000000ffffffff
> Call Trace:
>  [<ffffffff9872ae0a>] dump_stack+0x4e/0x7a
>  [<ffffffff9872732c>] look_up_lock_class.part.18+0x2f/0x34
>  [<ffffffff980c10e2>] __lock_acquire.isra.28+0x722/0xa50
>  [<ffffffff9873a01b>] ? preempt_count_sub+0x6b/0xf0
>  [<ffffffff980c1b6d>] lock_acquire+0x8d/0x120
>  [<ffffffffc05438f2>] ? hashbin_delete+0xf2/0x100 [irda]
>  [<ffffffffc0545e30>] ? irias_delete_value+0x30/0x30 [irda]
>  [<ffffffff987357fc>] _raw_spin_lock_irqsave_nested+0x4c/0x70
>  [<ffffffffc05438f2>] ? hashbin_delete+0xf2/0x100 [irda]
>  [<ffffffffc05438f2>] hashbin_delete+0xf2/0x100 [irda]

I tried looking at that code but gave up real quick.. That code is
'creative'.
