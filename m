From: khalasa@piap.pl (Krzysztof =?utf-8?Q?Ha=C5=82asa?=)
Subject: Re: [PATCH 01/15] net: phy: Add phy_ethtool_nway_reset
Date: Thu, 17 Nov 2016 11:06:36 +0100
Message-ID: <m3oa1e2zf7.fsf@t19.piap.pl>
References: <20161115180644.3941-1-f.fainelli@gmail.com>
        <20161115180644.3941-2-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Florian Fainelli <f.fainelli@gmail.com> writes:

> This function just calls into genphy_restart_aneg() to perform an
> autonegotation restart.
>
> +int phy_ethtool_nway_reset(struct net_device *ndev)
> +{
> +	struct phy_device *phydev = ndev->phydev;
> +
> +	if (!phydev)
> +		return -ENODEV;
> +
> +	return genphy_restart_aneg(phydev);
> +}

and then you're using this function as .nway_reset of all netdev drivers
in question.

genphy_restart_aneg() deals directly with MII BMCR register:

int genphy_restart_aneg(struct phy_device *phydev)
{
        int ctl = phy_read(phydev, MII_BMCR);

        if (ctl < 0)
                return ctl;

        ctl |= BMCR_ANENABLE | BMCR_ANRESTART;

        /* Don't isolate the PHY if we're negotiating */
        ctl &= ~BMCR_ISOLATE;

        return phy_write(phydev, MII_BMCR, ctl);
}

Will the above work if the PHY is something special, e.g. a "fixed"
connection, or some kind of fiber trx etc? Normally, the PHY driver
could provide its own config_aneg().
-- 
Krzysztof Halasa

Industrial Research Institute for Automation and Measurements PIAP
Al. Jerozolimskie 202, 02-486 Warsaw, Poland
