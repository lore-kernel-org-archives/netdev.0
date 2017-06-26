From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH NET V5 1/2] net: phy: Add phy loopback support in net phy
 framework
Date: Mon, 26 Jun 2017 09:45:29 -0700
Message-ID: <c517e8a1-4f4f-897e-1ae5-9f60c6f19185@gmail.com>
References: <1498443039-134503-1-git-send-email-linyunsheng@huawei.com>
 <1498443039-134503-2-git-send-email-linyunsheng@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: huangdaode@hisilicon.com, xuwei5@hisilicon.com,
        liguozhu@hisilicon.com, Yisen.Zhuang@huawei.com,
        gabriele.paoloni@huawei.com, john.garry@huawei.com,
        linuxarm@huawei.com, salil.mehta@huawei.com, lipeng321@huawei.com,
        tremyfr@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Lin Yun Sheng <linyunsheng@huawei.com>, davem@davemloft.net,
        andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:35656 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751739AbdFZQpo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2017 12:45:44 -0400
In-Reply-To: <1498443039-134503-2-git-send-email-linyunsheng@huawei.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/25/2017 07:10 PM, Lin Yun Sheng wrote:
> This patch add set_loopback in phy_driver, which is used by Mac
> driver to enable or disable a phy. it also add a generic
> genphy_loopback function, which use BMCR loopback bit to enable
> or disable a phy.
> 
> Signed-off-by: Lin Yun Sheng <linyunsheng@huawei.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

[snip]

> +int phy_loopback(struct phy_device *phydev, bool enable)
> +{
> +	struct phy_driver *phydrv = to_phy_driver(phydev->mdio.dev.driver);
> +	int ret = 0;
> +
> +	mutex_lock(&phydev->lock);
> +
> +	if (enable && phydev->loopback_enabled) {
> +		ret = -EBUSY;
> +		goto out;
> +	}
> +
> +	if (!enable && !phydev->loopback_enabled) {
> +		ret = -EINVAL;
> +		goto out;
> +	}

I am not sure if it is necessary to treat that condition as an error,
but I guess why not.
-- 
Florian
