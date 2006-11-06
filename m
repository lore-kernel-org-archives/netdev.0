From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] s2io ppc64 fix for readq/writeq
Date: Mon, 06 Nov 2006 19:04:08 +1100
Message-ID: <1162800248.28571.296.camel@localhost.localdomain>
References: <1162780109.28571.273.camel@localhost.localdomain>
	 <454EE943.6000603@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:10908 "EHLO gate.crashing.org")
	by vger.kernel.org with ESMTP id S1423568AbWKFIJa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Nov 2006 03:09:30 -0500
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <454EE943.6000603@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> This seems a bit ugly.  Could you add
> 
> 	#define readq readq
> 
> to your platform instead?

That's ugly too imho but I suppose I can do it :-)

> I generally think it's a bug in the kernel-wide API, if use of said API 
> requires arch-specific ifdefs.

Yes. I agree. In that specific case, I suppose what you propose is the
least ugly of the solutions. HAVE_ARCH_* is pretty much out of fascion
(and I tend to agree with Linus that it's not pretty anyway).

Actually, I tend to think in that specific case that the driver defining
something called readq and writeq based on a pair of readl's and
writel's is fairly bogus though.

> Or maybe the problem could be solved another way, by guaranteeing that a 
> "good enough for drivers" readq() and writeq() exist on all platforms, 
> even 32-bit platforms where the operation isn't inherently atomic.

I'd rather not provide readq/writeq if they aren't atomic.

Ben.


