From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: force dst_default_metrics to const section
Date: Tue, 7 Aug 2012 23:44:34 +0100
Message-ID: <1344379474.2688.89.camel@bwh-desktop.uk.solarflarecom.com>
References: <1344355878.28967.113.camel@edumazet-glaptop>
	 <1344370527.2688.61.camel@bwh-desktop.uk.solarflarecom.com>
	 <1344372945.28967.165.camel@edumazet-glaptop>
	 <1344377561.2688.66.camel@bwh-desktop.uk.solarflarecom.com>
	 <1344378854.28967.201.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:21368 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756714Ab2HGWoi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2012 18:44:38 -0400
In-Reply-To: <1344378854.28967.201.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-08-08 at 00:34 +0200, Eric Dumazet wrote:
> On Tue, 2012-08-07 at 23:12 +0100, Ben Hutchings wrote:
> > On Tue, 2012-08-07 at 22:55 +0200, Eric Dumazet wrote:
> > > From: Eric Dumazet <edumazet@google.com>
> > > 
> > > 
> > > > Some day the compiler may be smart enough to ignore the different
> > > > between explicit and implicit zero-initialisation, and put it back in
> > > > BSS.  Declaring this __cache_aligned_in_smp might be a better option.
> > > 
> > > __cache_aligned_in_smp aligns start of the structure, but can be
> > > followed by another var in same cache line. Yes, this is bad.
> > 
> > Oh, that's unexpected.
> > 
> > > By the way we dont care of cache alignment on this structure, only it
> > > should be const. Its a soft requirement, machine wont crash if it is not
> > > the case.
> > 
> > Right.
> > 
> > > If compiler is smart one day as you say (it should first be non buggy
> > > IMHO), then we can add a non zero field like this :
> > [...]
> > 
> > That would work, but it's ugly!  How about defining and using a
> > meaningfully-named macro that expands to __section(.rodata)?
> 
> You are kidding. I prefer plain C and not having to mess with all
> arches.

Any consideration of implementation details like BSS and cache line
sharing is already outside of 'plain C'.  And you don't have to 'mess
with all arches'; just look at what <linux/init.h> and <linux/module.h>
do.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
