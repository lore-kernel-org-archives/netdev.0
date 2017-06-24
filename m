From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH NET v3 2/2] net: hns: Use phy_driver to setup Phy loopback
Date: Sat, 24 Jun 2017 05:18:56 +0200
Message-ID: <20170624031856.GH4875@lunn.ch>
References: <1498211042-240816-1-git-send-email-linyunsheng@huawei.com>
 <1498211042-240816-3-git-send-email-linyunsheng@huawei.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:33680 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754612AbdFXDTA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Jun 2017 23:19:00 -0400
Content-Disposition: inline
In-Reply-To: <1498211042-240816-3-git-send-email-linyunsheng@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>  static int hns_nic_config_phy_loopback(struct phy_device *phy_dev, u8 en)
>  {
> -#define COPPER_CONTROL_REG 0
> -#define PHY_POWER_DOWN BIT(11)
> -#define PHY_LOOP_BACK BIT(14)
> -	u16 val = 0;
> +	int err;
>  
>  	if (phy_dev->is_c45) /* c45 branch adding for XGE PHY */
>  		return -ENOTSUPP;

You should take this out as well. You want the core to tell you if
loopback is supported or not. At some point, a c45 PHY could support
loopback.

> +	case MAC_LOOP_PHY_NONE:
>  		if ((phy_dev) && (!phy_dev->is_c45))
>  			ret |= hns_nic_config_phy_loopback(phy_dev, 0x0);

same here.

     Andrew
