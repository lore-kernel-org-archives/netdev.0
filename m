From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH NET v3 1/2] net: phy: Add phy loopback support in net phy
 framework
Date: Sat, 24 Jun 2017 05:12:31 +0200
Message-ID: <20170624031231.GG4875@lunn.ch>
References: <1498211042-240816-1-git-send-email-linyunsheng@huawei.com>
 <1498211042-240816-2-git-send-email-linyunsheng@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, f.fainelli@gmail.com,
        huangdaode@hisilicon.com, xuwei5@hisilicon.com,
        liguozhu@hisilicon.com, Yisen.Zhuang@huawei.com,
        gabriele.paoloni@huawei.com, john.garry@huawei.com,
        linuxarm@huawei.com, salil.mehta@huawei.com, lipeng321@huawei.com,
        tremyfr@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Lin Yun Sheng <linyunsheng@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1498211042-240816-2-git-send-email-linyunsheng@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +int phy_loopback(struct phy_device *phydev, bool enable)
> +{
> +	struct phy_driver *phydrv = to_phy_driver(phydev->mdio.dev.driver);
> +	int ret = 0;
> +
> +	if (enable && phydev->loopback_enabled)
> +		return -EBUSY;
> +
> +	if (!enable && !phydev->loopback_enabled)
> +		return -EINVAL;
> +
> +	if (phydev->drv && phydrv->set_loopback)
> +		ret = phydrv->set_loopback(phydev, enable);

   	else
		ret = -EOPNOTSUPP;

> +
> +	if (ret)
> +		return ret;
> +
> +	phydev->loopback_enabled = enable;
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL(phy_loopback);

One of the comments we made of the PHY code in the hns driver is that
its locking is completely broken. You have made the same error
here. The core needs to hold the mutex while calling into the PHY
driver.

	Andrew
