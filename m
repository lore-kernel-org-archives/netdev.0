From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: Re: [PATCH NET V4 1/2] net: phy: Add phy loopback support in net phy
 framework
Date: Mon, 26 Jun 2017 09:26:52 +0800
Message-ID: <9da50466-1a27-aeba-b0c5-b55fd7bb01ee@huawei.com>
References: <1498290554-237317-1-git-send-email-linyunsheng@huawei.com>
 <1498290554-237317-2-git-send-email-linyunsheng@huawei.com>
 <20170624134436.GJ4875@lunn.ch>
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
In-Reply-To: <20170624134436.GJ4875@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Andrew

On 2017/6/24 21:44, Andrew Lunn wrote:
>> @@ -1087,7 +1087,7 @@ int phy_suspend(struct phy_device *phydev)
>>  {
>>  	struct phy_driver *phydrv = to_phy_driver(phydev->mdio.dev.driver);
>>  	struct ethtool_wolinfo wol = { .cmd = ETHTOOL_GWOL };
>> -	int ret = 0;
>> +	int ret = -EOPNOTSUPP;
>>  
>>  	/* If the device has WOL enabled, we cannot suspend the PHY */
>>  	phy_ethtool_get_wol(phydev, &wol);
>> @@ -1109,7 +1109,7 @@ int phy_suspend(struct phy_device *phydev)
>>  int phy_resume(struct phy_device *phydev)
>>  {
>>  	struct phy_driver *phydrv = to_phy_driver(phydev->mdio.dev.driver);
>> -	int ret = 0;
>> +	int ret = -EOPNOTSUPP;
>>  
>>  	if (phydev->drv && phydrv->resume)
>>  		ret = phydrv->resume(phydev);
>> @@ -1123,6 +1123,39 @@ int phy_resume(struct phy_device *phydev)
>>  }
> 
> These changes should be in a separate patch, since they have nothing
> to do with loopback. You want lots of small patches, making them
> easier to both describe the why it is needed, and easier to review.
> 
Thanks for pointing out. Will remove it next version.
> What are the implications of this change? Are you sure the power core
> code does not understand EOPNOTSUPP as being a real error?
> I was thinking phy_suspend/resume was making the mistake not returing error when
function point is null, as I did in phy_loopback. I am not sure if power core
understand EOPNOTSUPP.
But I think we should fix it if it is fixable, if not, then add a comment. because
it is not consitent with other phy_* . For anyone who is not familiar with phy core,
it is confusing.
