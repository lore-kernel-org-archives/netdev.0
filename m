From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: phy: smsc: Fix disabling energy detect mode
Date: Sat, 16 Jan 2016 18:11:49 +0100
Message-ID: <20160116171149.GA9880@lunn.ch>
References: <1452849633-26877-1-git-send-email-t.remmet@phytec.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Teresa Remmet <t.remmet@phytec.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1452849633-26877-1-git-send-email-t.remmet@phytec.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +static void smsc_phy_remove(struct phy_device *phydev)
> +{
> +	struct device *dev = &phydev->mdio.dev;
> +	bool *priv = phydev->priv;
> +
> +	if (priv)
> +		devm_kfree(dev, priv);
> +}

Not needed, since this is the devm_ API.

>From a stylistic point of view, it might be better to define a
structure with a single member. It is what people expect a priv to be.
It keeps the maintenance burden lower if you do things in the normal
way.

    Andrew
