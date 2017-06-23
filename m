From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: Re: [PATCH NET 2/2] net: hns: Use phy_driver to setup Phy loopback
Date: Fri, 23 Jun 2017 11:48:29 +0800
Message-ID: <d4130f27-6373-b909-e23f-4c26520a9093@huawei.com>
References: <1498121613-64572-1-git-send-email-linyunsheng@huawei.com>
 <20170623032011.GB5432@lunn.ch>
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
In-Reply-To: <20170623032011.GB5432@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hi, Andrew

On 2017/6/23 11:20, Andrew Lunn wrote:
> On Thu, Jun 22, 2017 at 04:53:33PM +0800, Lin Yun Sheng wrote:
>> Use function set_loopback in phy_driver to setup phy loopback
>> when doing ethtool self test.
>>
>> Signed-off-by: Lin Yun Sheng <linyunsheng@huawei.com>
>> ---
>>  drivers/net/ethernet/hisilicon/hns/hns_ethtool.c | 64 ++++--------------------
>>  1 file changed, 10 insertions(+), 54 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
>> index e95795b..660b51e 100644
>> --- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
>> +++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
>> @@ -259,66 +259,22 @@ static int hns_nic_set_link_ksettings(struct net_device *net_dev,
>>  
>>  static int hns_nic_config_phy_loopback(struct phy_device *phy_dev, u8 en)
>>  {
>> -#define COPPER_CONTROL_REG 0
>> -#define PHY_POWER_DOWN BIT(11)
>> -#define PHY_LOOP_BACK BIT(14)
>> -	u16 val = 0;
>>  
>> -	if (phy_dev->is_c45) /* c45 branch adding for XGE PHY */
>> +	if (phy_dev->is_c45 || !phy_dev->drv)
>> +		return -ENOTSUPP;
>> +
>> +	if (!phy_dev->drv->resume || !phy_dev->drv->suspend ||
>> +	    !phy_dev->drv->set_loopback)
>>  		return -ENOTSUPP;
> 
> No, i said to have a function is phy.c which does this check. The phy
> core needs to keep track of if loopback is already enabled, and return
> an error if it is attempted to turn it on twice, or disable it when it
> is not enabled.
what should the Mac driver do when it receive the error? I assume that it
will return it to userspace. because the rtnl_lock ensure only one ethtool
is executing, if the function return error, it means some bug in the mac
driver, am I right?
will add the function in phy.c next version.


Best Regards
Yunsheng Lin
