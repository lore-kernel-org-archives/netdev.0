From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: PROBLEM: in_atomic() misuse all over the place
Date: Fri, 30 Jan 2009 21:49:33 -0800
Message-ID: <20090130214933.1b91ea3e.akpm@linux-foundation.org>
References: <200901280010.37633.roger.larsson@e-gatan.se>
	<87pri7k4id.fsf@basil.nowhere.org>
	<20090130160316.7e53ef99.akpm@linux-foundation.org>
	<20090131055508.GD18453@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: roger.larsson@e-gatan.se, linux-kernel@vger.kernel.org,
	mingo@elte.hu, rml@tech9.net, pavel@ucw.cz, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:53740 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751142AbZAaFuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2009 00:50:39 -0500
In-Reply-To: <20090131055508.GD18453@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 31 Jan 2009 06:55:08 +0100 Andi Kleen <andi@firstfloor.org> wrote:

> > There's a bit of a problem here.  If someone accidentally uses
> > gfp_any() inside a spinlock, it will do a sleeping allocation on
> > non-preempt kernels and will do an atomic allocation on preemptible
> > kernels, so we won't get to see the warning which would allow us to fix
> > the bug.
> 
> Yes exporting the function to drivers is dangerous I agree because
> it's easy to abuse.
> 
> > Would using irq_count() work?  If so, that would fix this up.
> 
> There's nothing that works reliably to detect spinlocks on non
> preempt kernels.

Hang on.  You said

  That's typically for softirq vs non softirq, which is important for
  the network stack.

that's what in_softirq() does.

Now, if networking is indeed using in_atomic() to detect
are-we-inside-a-spinlock then networking is buggy.

If networking is _not_ doing that then we can safely switch it to
in_sortirq() or in_interrupt().  And this would reenable the bug
detection which networking's use of in_atomic() accidentally
suppressed.


