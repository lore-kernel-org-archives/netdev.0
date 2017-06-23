From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH NET 1/2] net: phy: Add phy loopback support in net phy
 framework
Date: Fri, 23 Jun 2017 05:16:27 +0200
Message-ID: <20170623031627.GA5432@lunn.ch>
References: <1498121602-64322-1-git-send-email-linyunsheng@huawei.com>
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
In-Reply-To: <1498121602-64322-1-git-send-email-linyunsheng@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +int genphy_loopback(struct phy_device *phydev, bool enable)
> +{
> +	int value;
> +
> +	if (enable) {
> +		value = phy_read(phydev, MII_BMCR);
> +		phy_write(phydev, MII_BMCR, value | BMCR_LOOPBACK);
> +	} else {
> +		value = phy_read(phydev, MII_BMCR);
> +		phy_write(phydev, MII_BMCR, value & ~BMCR_LOOPBACK);
> +	}

You should add error checking here. Both phy_read and phy_write can
return an error. Also, do the read and write once.

> +
> +	return 0;
> +}
> +EXPORT_SYMBOL(genphy_loopback);
> +
> +static int gen10g_loopback(struct phy_device *phydev, bool enable)
> +{
> +	return 0;
> +}

This is pointless. The core code in phy.c should first check if the
function exists before calling it. So not having a 10g method is fine.

	 Andrew
