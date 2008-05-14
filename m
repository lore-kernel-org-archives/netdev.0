From: Nate Case <ncase@xes-inc.com>
Subject: Re: [PATCH] PHYLIB: Add 1000Base-X support for Broadcom bcm5482
Date: Wed, 14 May 2008 17:39:50 -0500
Message-ID: <1210804791.13845.423.camel@localhost.localdomain>
References: <1210695378.13845.362.camel@localhost.localdomain>
	 <Pine.LNX.4.55.0805140018340.7267@cliff.in.clinika.pl>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xes-mad.com ([216.165.139.214]:56185 "EHLO xes-mad.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751104AbYENWj5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2008 18:39:57 -0400
In-Reply-To: <Pine.LNX.4.55.0805140018340.7267@cliff.in.clinika.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-05-14 at 01:02 +0100, Maciej W. Rozycki wrote:
>  Thanks for your changes -- they do not seem to break my system, but I
> have no way to verify your additions at the run time as I only have
> BCM5421 PHYs to try with.  A few comments follow.

I didn't mention this before, but I did test these myself at least on a
board with a BCM5482S in both SGMII->Copper and 1000Base-X modes.

>  Please do provide these macros!  The size does not matter (duh, what a
> truism!).  What really matters is the meaning of the numbers.  What seems
> obvious now, may not be such a couple of changes into the future.  
> Besides, it is much more effective to grep, etc. for macros than for
> numbers.

I went ahead and revised my patch to include these.  I certainly don't
disagree with your reasoning in general.  Laziness is a big factor and
it felt faster/easier to get things merged if the change had a smaller
footprint :)

>  We have magic numbers elsewhere, true, but they are results of
> reverse-engineering, so the exact meaning is unknown.  Of course if you
> have a possibility to document them properly, you are welcome to do so.
> But for everything that's known, let's keep the code as it should be from
> the beginning.

FYI: My guess for the 5481 magic bits is that they are accessing shadow
values at 0x18 similar to the way my 5481 patch uses the 0x1c shadow
registers.  It looks the same as the 5482's "Misc Control
Register" (shadow value "111", which is where the 0x7 comes from).

> > +#define MII_BCM54XX_RSV0	0x15	/* Reserved / Expansion registers */
> 
>  Hmm, the name seems confusing -- is it the manufacturer's official name
> of the register?  Based on the semantics I would call it
> MII_BCM54XX_EXP_DATA or suchlike.

I'm not aware of any "official" manufacturer name for this register.
The register map has 0x15 as "reserved", but 0x15 is used for accessing
expansion registers.  I agree with your interpretation of how it's used
so I renamed it as you did in v2 of my patch.

> 
> > +#define MII_BCM54XX_EXP		0x17	/* Expansion register access */
> 
>  And then perhaps MII_BCM54XX_EXP_SEL for consistency.

Done

>  Formatting, please -- Linux wants operators at the end of the line and 
> indentation to mark where the continuation correlates to the line above.  
> In this case either:
[snip]

Done (this makes me wonder why Lindent doesn't pass "-nbbo" to indent
though).

>  Hmm, you have reached the 80th column -- that causes problems sometimes,
> I would wrap the arguments.

Done

>  Hmm, out of curiosity -- does such enforcement play well with tools like 
> ethtool or mii-tool?

I did test with 'ethtool' and link detection worked fine.  The only
catch is that it will show 1000 mbit/s even when there is no link (many
drivers report 10 mbit/s with no link present), but I wouldn't think we
should ever trust 'speed' without a link present.

v2 of the patch will follow shortly.

-- 
Nate Case <ncase@xes-inc.com>

