From: Andi Kleen <andi@firstfloor.org>
Subject: Re: PROBLEM: in_atomic() misuse all over the place
Date: Sat, 31 Jan 2009 06:55:08 +0100
Message-ID: <20090131055508.GD18453@one.firstfloor.org>
References: <200901280010.37633.roger.larsson@e-gatan.se> <87pri7k4id.fsf@basil.nowhere.org> <20090130160316.7e53ef99.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, roger.larsson@e-gatan.se,
	linux-kernel@vger.kernel.org, mingo@elte.hu, rml@tech9.net,
	pavel@ucw.cz, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:52271 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751016AbZAaFjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2009 00:39:08 -0500
Content-Disposition: inline
In-Reply-To: <20090130160316.7e53ef99.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> There's a bit of a problem here.  If someone accidentally uses
> gfp_any() inside a spinlock, it will do a sleeping allocation on
> non-preempt kernels and will do an atomic allocation on preemptible
> kernels, so we won't get to see the warning which would allow us to fix
> the bug.

Yes exporting the function to drivers is dangerous I agree because
it's easy to abuse.

> Would using irq_count() work?  If so, that would fix this up.

There's nothing that works reliably to detect spinlocks on non
preempt kernels.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
