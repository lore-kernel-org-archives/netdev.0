From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] phylib: fix forced mode misbehaviour for aneg off case
Date: Thu, 3 Jul 2008 20:18:17 +0100
Message-ID: <20080703191815.GG17872@solarflare.com>
References: <20080703171614.GA21126@polina.dev.rtsoft.ru> <20080703104143.6620e99f@extreme> <20080703181118.GA30139@polina.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Jeff Garzik <jgarzik@pobox.com>,
	Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org
To: Anton Vorontsov <avorontsov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.mbr-roch.zen.net.uk ([212.23.3.140]:44896 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752395AbYGCTSZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 15:18:25 -0400
Content-Disposition: inline
In-Reply-To: <20080703181118.GA30139@polina.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anton Vorontsov wrote:
> On Thu, Jul 03, 2008 at 10:41:43AM -0700, Stephen Hemminger wrote:
> > On Thu, 3 Jul 2008 21:16:14 +0400
> > Anton Vorontsov <avorontsov@ru.mvista.com> wrote:
> > 
> > > With disabled autonegotiation and link absence, phylib will place phy
> > > into the forcing mode, thus will start calling phy_force_reduction().
> > > That means that for the drivers that are using phylib we can't actually
> > > set fixed speed for the link.
> > > 
> > > For example:
> > > 
> > > # ethtool -s eth0 autoneg off speed 1000
> > 
> > FYI autonegotiation is required in gigabit mode per 802 spec.
 
This is technically correct, but all "negotiated" settings can be manually
configured such that only a single possible configuration is advertised
during auto-negotiation.

> Thanks for the information. FWIW, that behaviour observed for
> speed 100 or speed 10, too.
> 
> As for gbit, this is interesting indeed. If we're not permitted to
> disable aneg, how could we force the PHY to use gigabit, so that it
> will not try to downgrade? I mean ethtool option.

You should be able to use
"ethtool -s eth0 autoneg on speed 1000 duplex full" (you have to specify
all three).  Not all drivers implement that correctly though.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
