From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2] net: phy: smsc: Fix disabling energy detect mode
Date: Tue, 19 Jan 2016 16:25:03 +0100
Message-ID: <20160119152503.GK6554@lunn.ch>
References: <1453190199-22269-1-git-send-email-t.remmet@phytec.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Teresa Remmet <t.remmet@phytec.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59604 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753920AbcASPZG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jan 2016 10:25:06 -0500
Content-Disposition: inline
In-Reply-To: <1453190199-22269-1-git-send-email-t.remmet@phytec.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +struct smsc_phy_priv {
> +	bool energy_enable:1;
> +};

Time to show my ignorance of bitfields. Since this is a bool, does the
:1 actually do anything?

> +static int smsc_phy_probe(struct phy_device *phydev)
> +{
> +	struct device *dev = &phydev->mdio.dev;
> +	struct device_node *of_node __maybe_unused = dev->of_node;
> +	struct smsc_phy_priv *priv;
> +	int __maybe_unused len;
> +
> +	priv = devm_kzalloc(dev, sizeof(*priv), GFP_KERNEL);
> +	if (!priv)
> +		return -ENOMEM;
> +
> +	if (of_find_property(of_node, "smsc,disable-energy-detect", &len))
> +		priv->energy_enable = false;

Here you set it to false. Where does it get set to true?

Also, of_property_read_bool() would be a better call than of_find_property.

     Andrew
