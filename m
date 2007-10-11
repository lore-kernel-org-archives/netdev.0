From: Andreas Henriksson <andreas@fatal.se>
Subject: Re: iproute2: resend of patches from Debian.
Date: Thu, 11 Oct 2007 23:22:12 +0200
Message-ID: <1192137732.4733.34.camel@localhost.localdomain>
References: <1192127132.4732.9.camel@localhost.localdomain>
	 <470E87EA.4030200@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	Alexander Wirt <formorer@debian.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:35267 "EHLO
	scream.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755373AbXJKVXH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 17:23:07 -0400
In-Reply-To: <470E87EA.4030200@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On tor, 2007-10-11 at 22:30 +0200, Patrick McHardy wrote:
> Andreas Henriksson wrote:
> > Abort flush after 10 seconds.
> 
> This should be optional IMO.

Copying Alexander Wirt here again, as I think this is his patch.
I'll skip this patch in my next resend...

> 
> > Add references to lartc, also drop bogus reference to tc-filters
> 
> There's a bad habit of reporting bugs on lartc that belong to netdev,
> please also make it perfectly clear that lartc is not for bug-reports.

I'll update the patch to mention this.

> 
> > Fix overflow in time2tick / tick2time.
> > 
> > The helper functions gets passed an unsigned int, which gets cast to long
> > and overflows.
> > 
> > See Debian bug #175462 - http://bugs.debian.org/175462
> > 
> > Signed-off-by: Andreas Henriksson <andreas@fatal.se>
> > 
> > diff -uri iproute-20070313.orig/tc/tc_core.c iproute-20070313/tc/tc_core.c
> > --- iproute-20070313.orig/tc/tc_core.c	2007-03-13 22:50:56.000000000 +0100
> > +++ iproute-20070313/tc/tc_core.c	2007-08-15 00:41:30.000000000 +0200
> > @@ -35,12 +35,12 @@
> >  }
> >  
> >  
> > -long tc_core_time2tick(long time)
> > +unsigned tc_core_time2tick(unsigned time)
> >  {
> >  	return time*tick_in_usec;
> >  }
> >  
> > -long tc_core_tick2time(long tick)
> > +unsigned tc_core_tick2time(unsigned tick)
> >  {
> >  	return tick/tick_in_usec;
> >  }
> 
> What about the other functions returning long? I think all of these
> should be unsigned.

Since I'm no superhacker, I was afraid to touch anything else then the
things I could test and this change is what's needed to fix the reported
bug. (Actually only one of them was needed IIRC, but it would be stupid
to only change one.)
I'll have a look at the other helper functions as well, probably adding
a separate patch so that it can be easily dropped if I screw something
up there.. :)

I'll also drop the mpath stuff you mentioned in the other mail...

Thanks for reviewing the patches!


-- 
Regards,
Andreas Henriksson

