From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/2] phy: marvell: Add support for temperature
 sensor
Date: Wed, 11 Jan 2017 16:09:31 +0100
Message-ID: <20170111150931.GV22820@lunn.ch>
References: <1484096604-25033-1-git-send-email-andrew@lunn.ch>
 <1484096604-25033-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55136 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1764841AbdAKPJe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 11 Jan 2017 10:09:34 -0500
Content-Disposition: inline
In-Reply-To: <1484096604-25033-2-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static int marvell_hwmon_probe(struct phy_device *phydev,
> +			       const struct hwmon_chip_info *chip)
> +{
> +	struct marvell_priv *priv = phydev->priv;
> +	struct device *dev = &phydev->mdio.dev;
> +	int err;
> +
> +	err = marvell_hwmon_name(phydev);
> +	if (err)
> +		return err;
> +
> +	priv->hwmon_dev = devm_hwmon_device_register_with_info(
> +		dev, priv->hwmon_name, phydev, chip, NULL);
> +
> +	if (IS_ERR(priv->hwmon_dev))
> +		return PTR_ERR(priv->hwmon_dev);
> +
> +	return 0;
> +}

0-day has pointed out this can be simplified to just

        return PTR_ERR(priv->hwmon_dev);

I will submit a v2 in a couple of days, when others have had chance to
comment.

	Andrew
