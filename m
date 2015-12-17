From: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>
Subject: Re: [PATCH] drivers: net: cpsw: fix RMII/RGMII mode when used with
 fixed-link PHY
Date: Thu, 17 Dec 2015 00:04:09 -0500
Message-ID: <20151217000409.27615e57.drivshin.allworx@gmail.com>
References: <20151209223115.6c5a400f.drivshin.allworx@gmail.com>
	<6416396.ZOturxhSar@localhost>
	<20151214130446.1e14fbb8.drivshin.allworx@gmail.com>
	<1741588.Ve76Z1ZI87@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-omap@vger.kernel.org, David Miller <davem@davemloft.net>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Pascal Speck <kernel@iktek.de>,
	Daniel Trautmann <dtrautmann@ibhsoftec-sps.de>
To: Markus Brunner <systemprogrammierung.brunner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:35485 "EHLO
	mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751302AbbLQFEM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 00:04:12 -0500
In-Reply-To: <1741588.Ve76Z1ZI87@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Dec 2015 07:39:16 +0100
Markus Brunner <systemprogrammierung.brunner@gmail.com> wrote:

> On Monday 14 December 2015 13:04:46 David Rivshin wrote:
> > On Sat, 12 Dec 2015 16:44:19 +0100
> ...
> > > Your patch works fine on my board, which uses MII and dual_emac
> > > with a fixed_phy and a real one.
> > 
> > Thanks for checking. The only dual_emac board I have available is
> > the EVMSK, which has two real PHYs. I'm not sure of the usual
> > etiquette (and Google was  unhelpful), should I add a Tested-by on
> > the next version?
> > 
> Yes you can. Documentation/SubmittingPatches has some notes about it.

Thanks, I didn't want to throw it on without permission. Although due 
to the non-trivial change I mention below, I figured that the previous 
testing wasn't totally valid anymore anyways, so I left it off the v2 
emails.

> > > I wanted to keep changes small and didn't spend too much thinking
> > > about already broken devicetrees. Since my patch is quite new, I
> > 
> > I'm honestly not sure it's an important consideration myself. Most
> > patches I've seen in this area for this or other drivers do not take
> > such behavior into account (e.g. the phy-handle parsing that went in
> > to cpsw in 4.3).
> > I would generally feel more comfortable with such a behavior tweak
> > (minor as it is) before 4.4 is released, to avoid ping-ponging the
> > behavior. But given how far along the cycle is, I'm not sure about
> > the chances of that.
> 
> Well I don't think compatibility for flawed DTs is such a high
> priority, especially if it is that unlikely that there are some
> affected. Keep the focus on the other _real_ problems you have
> encountered and fix those like you see fit. 

Since there's been no indication from anyone that being nice to such
broken DTs is desired, I decided to drop that aspect of the patch and 
leave the current 4.4-rc1..5 behavior. This also made it much more 
reasonable to chop up the patch into smaller pieces, which I think will 
be easier to review.

> > > don't see any problems with subtle changes like that. However you
> > > should update the documentation as well.
> > 
> > Your patch already updated .../bindings/net/cpsw.txt, which this
> > patch left alone. Are you referring to some other documentation,
> > or do you think I should update the binding documentation to state
> > that phy_id takes precedence over fixed-link? I figured that such
> > devicetrees were still officially malformed, so I thought the
> > existing text was appropriate.
> 
> "Either the properties phy_id and phy-mode, or the sub-node
> fixed-link can be specified" One flaw of my patch was to ignore the
> phy-mode for a fixed link. Do not mention the precedence of the
> phy_id, because it is an undefined behavior. Your patch should change
> it to: "Either the property phy_id, or the sub-node fixed-link can be
> specified"

Thanks for pointing that out. For some reason my brain skipped over the 
"and phy-mode" part. Fixed in v2.
