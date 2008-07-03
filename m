From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH] phylib: fix forced mode misbehaviour for aneg off case
Date: Thu, 3 Jul 2008 22:11:18 +0400
Message-ID: <20080703181118.GA30139@polina.dev.rtsoft.ru>
References: <20080703171614.GA21126@polina.dev.rtsoft.ru> <20080703104143.6620e99f@extreme>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:21955 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753227AbYGCSLU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 14:11:20 -0400
Content-Disposition: inline
In-Reply-To: <20080703104143.6620e99f@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 03, 2008 at 10:41:43AM -0700, Stephen Hemminger wrote:
> On Thu, 3 Jul 2008 21:16:14 +0400
> Anton Vorontsov <avorontsov@ru.mvista.com> wrote:
> 
> > With disabled autonegotiation and link absence, phylib will place phy
> > into the forcing mode, thus will start calling phy_force_reduction().
> > That means that for the drivers that are using phylib we can't actually
> > set fixed speed for the link.
> > 
> > For example:
> > 
> > # ethtool -s eth0 autoneg off speed 1000
> 
> FYI autonegotiation is required in gigabit mode per 802 spec.

Thanks for the information. FWIW, that behaviour observed for
speed 100 or speed 10, too.

As for gbit, this is interesting indeed. If we're not permitted to
disable aneg, how could we force the PHY to use gigabit, so that it
will not try to downgrade? I mean ethtool option.

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
