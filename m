From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: Re: [PATCH NET 1/2] net: phy: Add phy loopback support in net phy
 framework
Date: Fri, 23 Jun 2017 11:57:56 +0800
Message-ID: <436ddf50-93d6-f15a-e9f6-bf8e43b63fec@huawei.com>
References: <1498121602-64322-1-git-send-email-linyunsheng@huawei.com>
 <20170623031627.GA5432@lunn.ch>
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
In-Reply-To: <20170623031627.GA5432@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Andrew

On 2017/6/23 11:16, Andrew Lunn wrote:
>> +int genphy_loopback(struct phy_device *phydev, bool enable)
>> +{
>> +	int value;
>> +
>> +	if (enable) {
>> +		value = phy_read(phydev, MII_BMCR);
>> +		phy_write(phydev, MII_BMCR, value | BMCR_LOOPBACK);
>> +	} else {
>> +		value = phy_read(phydev, MII_BMCR);
>> +		phy_write(phydev, MII_BMCR, value & ~BMCR_LOOPBACK);
>> +	}
> 
> You should add error checking here. Both phy_read and phy_write can
> return an error. Also, do the read and write once.
Thanks for pointing out, will do that next vesion.

> 
>> +
>> +	return 0;
>> +}
>> +EXPORT_SYMBOL(genphy_loopback);
>> +
>> +static int gen10g_loopback(struct phy_device *phydev, bool enable)
>> +{
>> +	return 0;
>> +}
> 
> This is pointless. The core code in phy.c should first check if the
> function exists before calling it. So not having a 10g method is fine.
> 
will remove it next vesion.

Best Regards
Yunsheng Lin
