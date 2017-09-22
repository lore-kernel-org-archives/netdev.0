From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 1/3] net: dsa: use slave device phydev
Date: Fri, 22 Sep 2017 22:03:04 +0200
Message-ID: <20170922200304.GI3470@lunn.ch>
References: <20170922194045.18814-1-vivien.didelot@savoirfairelinux.com>
 <20170922194045.18814-2-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170922194045.18814-2-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 22, 2017 at 03:40:43PM -0400, Vivien Didelot wrote:
> There is no need to store a phy_device in dsa_slave_priv since
> net_device already provides one. Simply s/p->phy/dev->phydev/.
> 
> While at it, return -ENODEV when it is NULL instead of -EOPNOTSUPP.

I just did a quick poll for calling phy_mii_ioctl(). ENODEV seems the
most popular, second to EINVAL. Marvell drivers all use EOPNOTSUPP.

>  static int dsa_slave_nway_reset(struct net_device *dev)
>  {
> -	struct dsa_slave_priv *p = netdev_priv(dev);
> +	if (!dev->phydev)
> +		return -ENODEV;
>  
> -	if (p->phy != NULL)
> -		return genphy_restart_aneg(p->phy);
> -
> -	return -EOPNOTSUPP;
> +	return genphy_restart_aneg(dev->phydev);
>  }

It looks like this can now be replaced with phy_ethtool_nway_reset().

It could be there are other phy_ethtool_ helpers which can be used,
now that we have phydev in ndev.

    Andrew
