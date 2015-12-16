From: Markus Brunner <systemprogrammierung.brunner@gmail.com>
Subject: Re: [PATCH] drivers: net: cpsw: fix RMII/RGMII mode when used with fixed-link PHY
Date: Wed, 16 Dec 2015 07:39:16 +0100
Message-ID: <1741588.Ve76Z1ZI87@localhost>
References: <20151209223115.6c5a400f.drivshin.allworx@gmail.com> <6416396.ZOturxhSar@localhost> <20151214130446.1e14fbb8.drivshin.allworx@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-omap@vger.kernel.org, David Miller <davem@davemloft.net>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Pascal Speck <kernel@iktek.de>,
	Daniel Trautmann <dtrautmann@ibhsoftec-sps.de>
To: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:34277 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932197AbbLPGlO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 01:41:14 -0500
In-Reply-To: <20151214130446.1e14fbb8.drivshin.allworx@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 14 December 2015 13:04:46 David Rivshin wrote:
> On Sat, 12 Dec 2015 16:44:19 +0100
...
> > Your patch works fine on my board, which uses MII and dual_emac with
> > a fixed_phy and a real one.
> 
> Thanks for checking. The only dual_emac board I have available is the
> EVMSK, which has two real PHYs. I'm not sure of the usual etiquette
> (and Google was  unhelpful), should I add a Tested-by on the next
> version?
> 
Yes you can. Documentation/SubmittingPatches has some notes about it.

> > > Besides fixing the bug mentioned in the commit log, there are a few
> > > 
> > > other differences to note:
> > >  * If both "phy_id" and a "fixed-link" subnode are present this
> > > 
> > > patch will use the "phy_id" property. This should preserve current
> > > behavior with existing devicetrees that might incorrectly have
> > > both. This motivates the biggest difference in code organization
> > > from 1f71e8c96fc6.
> > > 
> > >  * Some error messages have been tweaked to reflect the slightly
> > > 
> > > changed meanings of the checks.
> > 
> > I wanted to keep changes small and didn't spend too much thinking
> > about already broken devicetrees. Since my patch is quite new, I
> 
> I'm honestly not sure it's an important consideration myself. Most
> patches I've seen in this area for this or other drivers do not take
> such behavior into account (e.g. the phy-handle parsing that went in
> to cpsw in 4.3).
> I would generally feel more comfortable with such a behavior tweak
> (minor as it is) before 4.4 is released, to avoid ping-ponging the
> behavior. But given how far along the cycle is, I'm not sure about
> the chances of that.
> 

Well I don't think compatibility for flawed DTs is such a high priority, especially if it is that unlikely that there are some affected.
Keep the focus on the other _real_ problems you have encountered and fix those like you see fit. 

> > don't see any problems with subtle changes like that. However you
> > should update the documentation as well.
> 
> Your patch already updated .../bindings/net/cpsw.txt, which this
> patch left alone. Are you referring to some other documentation,
> or do you think I should update the binding documentation to state
> that phy_id takes precedence over fixed-link? I figured that such
> devicetrees were still officially malformed, so I thought the
> existing text was appropriate.

"Either the properties phy_id and phy-mode, or the sub-node fixed-link can be specified"
One flaw of my patch was to ignore the phy-mode for a fixed link. Do not mention the precedence of the phy_id, because it is an undefined behavior.
Your patch should change it to:
"Either the property phy_id, or the sub-node fixed-link can be specified"
