From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 9/9] phy: fixed_phy: Set phy capabilities even
 when link is down
Date: Mon, 24 Aug 2015 18:32:30 +0200
Message-ID: <20150824163230.GB6781@lunn.ch>
References: <1440323220-20438-1-git-send-email-andrew@lunn.ch>
 <1440323220-20438-10-git-send-email-andrew@lunn.ch>
 <55DA1387.9020009@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38707 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751150AbbHXQj5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Aug 2015 12:39:57 -0400
Content-Disposition: inline
In-Reply-To: <55DA1387.9020009@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 23, 2015 at 11:40:07AM -0700, Florian Fainelli wrote:
> Le 08/23/15 02:47, Andrew Lunn a =E9crit :
> > What features a phy supports is masked in genphy_config_init() by
> > looking at the PHYs BMSR register.
> >=20
> > If the link is down, fixed_phy_update_regs() will only set the auto=
-
> > negotiation capable bit in BMSR. Thus genphy_config_init() comes to
> > the conclusion the PHY can only perform 10/Half, and masks out the
> > higher speed features. If however the link it up, BMSR is set to
> > indicate the speed the PHY is capable of auto-negotiating, and
> > genphy_config_init() does not mask out the high speed features.
> >=20
> > To fix this, when the link is down, have fixed_phy_update_regs() le=
ave
> > the link status and auto-negotiation complete bit unset, but set al=
l
> > the other bits depending on the fixed phy speed.
>=20
> This kinds of revert what Staas did in commit
> 868a4215be9a6d80548ccb74763b883dc99d32a2 ("net: phy: fixed_phy: handl=
e
> link-down case"). When the link is down, it does not seem to me like =
we
> can rely on the previous speed and duplex parameters to be considered=
 valid.
>=20
> Your change does fix a valid use case though... humm.

Hi Florian

I took at look at Staas fix, and read a bit about what the different
bits mean. I've reworked the patch. I now always set the local phy
capabilities in BMSR, but only set the negotiated speed and link
partner capabilities if the link it up. I also don't error out on
speed=3D0, unless the link is up.

This works for my use case, and hopefully also Staas.

I will post the new version when we have come to a conclusion about
other open issues.

      Andrew
