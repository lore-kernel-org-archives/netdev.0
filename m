From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] s2io ppc64 fix for readq/writeq
Date: Mon, 06 Nov 2006 03:21:15 -0500
Message-ID: <454EF07B.4010503@pobox.com>
References: <1162780109.28571.273.camel@localhost.localdomain>	 <454EE943.6000603@pobox.com> <1162800248.28571.296.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33667 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1423602AbWKFIVS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Nov 2006 03:21:18 -0500
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1162800248.28571.296.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Benjamin Herrenschmidt wrote:
>> This seems a bit ugly.  Could you add
>>
>> 	#define readq readq
>>
>> to your platform instead?
> 
> That's ugly too imho but I suppose I can do it :-)
> 
>> I generally think it's a bug in the kernel-wide API, if use of said API 
>> requires arch-specific ifdefs.
> 
> Yes. I agree. In that specific case, I suppose what you propose is the
> least ugly of the solutions. HAVE_ARCH_* is pretty much out of fascion
> (and I tend to agree with Linus that it's not pretty anyway).
> 
> Actually, I tend to think in that specific case that the driver defining
> something called readq and writeq based on a pair of readl's and
> writel's is fairly bogus though.
> 
>> Or maybe the problem could be solved another way, by guaranteeing that a 
>> "good enough for drivers" readq() and writeq() exist on all platforms, 
>> even 32-bit platforms where the operation isn't inherently atomic.
> 
> I'd rather not provide readq/writeq if they aren't atomic.

This is why I said "good enough for drivers".  This is _key_.

I have run into several [PCI] devices with 64-bit registers, and 
__none__ of them had requirements such that the Linux platform code 
-must- provide an atomic readq/writeq.  Probably because everybody wants 
to support 32-bit platforms with their devices.

What you call "fairly bogus" is precisely what drivers need.  These 
devices with 64-bit registers just don't need the atomicity that arch 
developers harp about :)

	Jeff


