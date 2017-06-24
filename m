From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: Re: [PATCH NET v3 1/2] net: phy: Add phy loopback support in net phy
 framework
Date: Sat, 24 Jun 2017 11:40:52 +0800
Message-ID: <0fa5d2df-741e-06ba-96f3-567f47f82e3e@huawei.com>
References: <1498211042-240816-1-git-send-email-linyunsheng@huawei.com>
 <1498211042-240816-2-git-send-email-linyunsheng@huawei.com>
 <20170624031231.GG4875@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <f.fainelli@gmail.com>,
        <huangdaode@hisilicon.com>, <xuwei5@hisilicon.com>,
        <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
        <gabriele.paoloni@huawei.com>, <john.garry@huawei.com>,
        <linuxarm@huawei.com>, <salil.mehta@huawei.com>,
        <lipeng321@huawei.com>, <tremyfr@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170624031231.GG4875@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Andrew

On 2017/6/24 11:12, Andrew Lunn wrote:
>> +int phy_loopback(struct phy_device *phydev, bool enable)
>> +{
>> +	struct phy_driver *phydrv = to_phy_driver(phydev->mdio.dev.driver);
>> +	int ret = 0;
>> +
>> +	if (enable && phydev->loopback_enabled)
>> +		return -EBUSY;
>> +
>> +	if (!enable && !phydev->loopback_enabled)
>> +		return -EINVAL;
>> +
>> +	if (phydev->drv && phydrv->set_loopback)
>> +		ret = phydrv->set_loopback(phydev, enable);
> 
>    	else
> 		ret = -EOPNOTSUPP;
> 
>> +
>> +	if (ret)
>> +		return ret;
>> +
>> +	phydev->loopback_enabled = enable;
>> +
>> +	return 0;
>> +}
>> +EXPORT_SYMBOL(phy_loopback);
> 
> One of the comments we made of the PHY code in the hns driver is that
> its locking is completely broken. You have made the same error
> here. The core needs to hold the mutex while calling into the PHY
> driver.
Do you mean hns_nic_config_phy_loopback need to hold the mutex while
calling phy_loopback? and other place that calling phy_* function?

Best Regards
Yunsheng Lin
