From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: Re: [PATCH NET V6 1/2] net: phy: Add phy loopback support in net phy
 framework
Date: Wed, 28 Jun 2017 08:33:12 +0800
Message-ID: <de65ec64-3e1b-447f-2fad-3f8a3a207940@huawei.com>
References: <1498561245-93997-1-git-send-email-linyunsheng@huawei.com>
 <1498561245-93997-2-git-send-email-linyunsheng@huawei.com>
 <AM5PR0402MB269142CD14B8FDAB48F7A1ECECDC0@AM5PR0402MB2691.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "huangdaode@hisilicon.com" <huangdaode@hisilicon.com>,
        "xuwei5@hisilicon.com" <xuwei5@hisilicon.com>,
        "liguozhu@hisilicon.com" <liguozhu@hisilicon.com>,
        "Yisen.Zhuang@huawei.com" <Yisen.Zhuang@huawei.com>,
        "gabriele.paoloni@huawei.com" <gabriele.paoloni@huawei.com>,
        "john.garry@huawei.com" <john.garry@huawei.com>,
        "linuxarm@huawei.com" <linuxarm@huawei.com>,
        "salil.mehta@huawei.com" <salil.mehta@huawei.com>,
        "lipeng321@huawei.com" <lipeng321@huawei.com>,
        "tremyfr@gmail.com" <tremyfr@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Madalin-cristian Bucur <madalin.bucur@nxp.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "andrew@lunn.ch" <andrew@lunn.ch>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AM5PR0402MB269142CD14B8FDAB48F7A1ECECDC0@AM5PR0402MB2691.eurprd04.prod.outlook.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Madalin

On 2017/6/27 19:48, Madalin-cristian Bucur wrote:
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
>> On Behalf Of Lin Yun Sheng
>> Sent: Tuesday, June 27, 2017 2:01 PM
>> To: davem@davemloft.net; andrew@lunn.ch; f.fainelli@gmail.com
>> Cc: huangdaode@hisilicon.com; xuwei5@hisilicon.com;
>> liguozhu@hisilicon.com; Yisen.Zhuang@huawei.com;
>> gabriele.paoloni@huawei.com; john.garry@huawei.com; linuxarm@huawei.com;
>> yisen.zhuang@huawei.com; salil.mehta@huawei.com; lipeng321@huawei.com;
>> tremyfr@gmail.com; netdev@vger.kernel.org; linux-kernel@vger.kernel.org
>> Subject: [PATCH NET V6 1/2] net: phy: Add phy loopback support in net phy
>> framework
>>
>> This patch add set_loopback in phy_driver, which is used by Mac
>> driver to enable or disable a phy. it also add a generic
>> genphy_loopback function, which use BMCR loopback bit to enable
>> or disable a phy.
> 
> "disable a phy" or disable the PHY loopback function?
It should be disable the PHY loopback function, thanks for pointing out.

> 

>> @@ -1123,6 +1123,39 @@ int phy_resume(struct phy_device *phydev)
>>  }
>>  EXPORT_SYMBOL(phy_resume);
>>
>> +int phy_loopback(struct phy_device *phydev, bool enable)
>> +{
>> +	struct phy_driver *phydrv = to_phy_driver(phydev->mdio.dev.driver);
>> +	int ret = 0;
>> +
>> +	mutex_lock(&phydev->lock);
>> +
>> +	if (enable && phydev->loopback_enabled) {
>> +		ret = -EBUSY;
>> +		goto out;
>> +	}
>> +
>> +	if (!enable && !phydev->loopback_enabled) {
>> +		ret = -EINVAL;
>> +		goto out;
>> +	}
>> +
> 
> if (enable == phydev->loopback_enabled)
One if statement don't work here, it returns different error code.

> 
>> +	if (phydev->drv && phydrv->set_loopback)
>> +		ret = phydrv->set_loopback(phydev, enable);
>> +	else
>> +		ret = -EOPNOTSUPP;
>> +
>> +	if (ret)
>> +		goto out;
>> +
>> +	phydev->loopback_enabled = enable;
>> +
>> +out:
>> +	mutex_unlock(&phydev->lock);
>> +	return ret;
>> +}
>> +EXPORT_SYMBOL(phy_loopback);
>> +
>

Best Regards
Yunsheng
