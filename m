From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCHv3 net-next 2/3] phy: marvell: Add ethtool statistics
 counters
Date: Wed, 30 Dec 2015 16:12:57 +0100
Message-ID: <20151230151257.GA16560@lunn.ch>
References: <1451418684-9238-1-git-send-email-andrew@lunn.ch>
 <1451418684-9238-3-git-send-email-andrew@lunn.ch>
 <VI1PR04MB1664FF303D53D9472E36452BE8FD0@VI1PR04MB1664.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Shaohui Xie <shaohui.xie@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:52502 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751157AbbL3PNB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Dec 2015 10:13:01 -0500
Content-Disposition: inline
In-Reply-To: <VI1PR04MB1664FF303D53D9472E36452BE8FD0@VI1PR04MB1664.eurprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 30, 2015 at 04:24:40AM +0000, Shaohui Xie wrote:
> > Subject: [PATCHv3 net-next 2/3] phy: marvell: Add ethtool statistics counters
> > +static int marvell_probe(struct phy_device *phydev) {
> > +	struct marvell_priv *priv;
> > +
> > +	priv = devm_kzalloc(&phydev->dev, sizeof(*priv), GFP_KERNEL);
> > +	if (!priv)
> > +		return -ENOMEM;
> > +
> > +	phydev->priv = priv;
> > +
> > +	return 0;
> > +}
> > +
> [S.H] Is a remove() function needed to free the memory?

Hi Shaohui

No, since i use devm_kzalloc(). The memory will automatically be freed
when phydev->dev is destroyed. Take a look at all the devm_ API calls
which have this property. They are useful for avoiding memory leaks,
especially on error paths.

     Andrew
