From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 9/9] phy: fixed_phy: Set phy capabilities even
 when link is down
Date: Sun, 23 Aug 2015 23:02:14 +0200
Message-ID: <20150823210214.GB20710@lunn.ch>
References: <1440323220-20438-1-git-send-email-andrew@lunn.ch>
 <1440323220-20438-10-git-send-email-andrew@lunn.ch>
 <55DA1387.9020009@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38233 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753235AbbHWVJk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Aug 2015 17:09:40 -0400
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

I must admit to not spending the time needed to understand what all
these bits mean. Are they what we are advertising we are capable off,
or what we have negotiated.

We definitely should not be configuring the phy layer on what we have
negotiated in the past. But what we are advertising should be a good
indication of what we are capable of. Maybe this function needs to set
the advertised features separate from negotiated features? If the link
is down, leave the negotiated at 10/Half, but set the advertised
features based on the fixed-link settings?

	 Andrew
