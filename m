From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH] PHYLIB: Add 1000Base-X support for Broadcom bcm5482
Date: Thu, 15 May 2008 00:15:12 +0100 (BST)
Message-ID: <Pine.LNX.4.55.0805142354530.15223@cliff.in.clinika.pl>
References: <1210695378.13845.362.camel@localhost.localdomain>
 <Pine.LNX.4.55.0805140018340.7267@cliff.in.clinika.pl>
 <1210804791.13845.423.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@vger.kernel.org>
To: Nate Case <ncase@xes-inc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirk.serum.com.pl ([213.77.9.205]:62617 "EHLO serum.com.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752868AbYENXPX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2008 19:15:23 -0400
In-Reply-To: <1210804791.13845.423.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 May 2008, Nate Case wrote:

> I didn't mention this before, but I did test these myself at least on a
> board with a BCM5482S in both SGMII->Copper and 1000Base-X modes.

 I have assumed it, but wanted to point out to the others the only
additional testing I can do is to check whether it breaks support or not
for one of the other PHY chips handled by the driver.

> I went ahead and revised my patch to include these.  I certainly don't
> disagree with your reasoning in general.  Laziness is a big factor and
> it felt faster/easier to get things merged if the change had a smaller
> footprint :)

 Laziness is a virtue -- the main incentive for the humankind to make
progress after all -- but only if it does not make you work harder later
on. :-)

> FYI: My guess for the 5481 magic bits is that they are accessing shadow
> values at 0x18 similar to the way my 5481 patch uses the 0x1c shadow
> registers.  It looks the same as the 5482's "Misc Control
> Register" (shadow value "111", which is where the 0x7 comes from).

 Thanks for the hint -- it looks like your newly introduced
MII_BCM54XX_AUX_CTL macro could be used here.  Designers tend to reuse
building blocks in hardware, so chances are it is indeed the same.

> The register map has 0x15 as "reserved", but 0x15 is used for accessing
> expansion registers.  I agree with your interpretation of how it's used
> so I renamed it as you did in v2 of my patch.

 OK.  One note on this occasion: please keep the registers sorted by the
index.  I missed it with the original review, but the additional registers
at 0x15, 0x17 and 0x18 (and the values within) should be placed between
MII_BCM54XX_ESR at 0x11 and MII_BCM54XX_ISR at 0x1a.

> I did test with 'ethtool' and link detection worked fine.  The only
> catch is that it will show 1000 mbit/s even when there is no link (many
> drivers report 10 mbit/s with no link present), but I wouldn't think we
> should ever trust 'speed' without a link present.

 I was a bit worried how it plays with actually trying to force different,
perhaps incompatible, link parameters.

  Maciej
