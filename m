From: Weidong Wang <wangweidong1@huawei.com>
Subject: Re: [RESEND PATCH net-next] phy: keep the BCMR_LOOPBACK bit while
 setup forced mode
Date: Thu, 14 Apr 2016 11:42:18 +0800
Message-ID: <570F119A.4020402@huawei.com>
References: <570E3488.9060403@huawei.com> <570E92ED.9020603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <570E92ED.9020603@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016/4/14 2:41, Florian Fainelli wrote:
> On 13/04/16 04:59, Weidong Wang wrote:
>> When tested the PHY SGMII Loopback,:
>> 1.set the LOOPBACK bit,
>> 2.set the autoneg to AUTONEG_DISABLE, it calls the
>> genphy_setup_forced which will clear the bit.
>>
>> So just keep the LOOPBACK bit while setup forced mode.
> 
> Humm, it makes sense why we want this one, but maybe we want other bits
> to be preserved too, like MII_ISOLATE for instance?
> 

I will add the  MII_ISOLATE as well.

> Or maybe we should have a separate way to put the PHY into loopback mode
> which is deterministic and takes care of forcing the link at the same time?
> 

I test with the loopback mode, and the link status is undeterminable.

>>
>> Signed-off-by: Weidong Wang <wangweidong1@huawei.com>
>> ---
>>  drivers/net/phy/phy_device.c | 2 ++
>>  1 file changed, 2 insertions(+)
>>
>> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
>> index e551f3a..8da4b80 100644
>> --- a/drivers/net/phy/phy_device.c
>> +++ b/drivers/net/phy/phy_device.c
>> @@ -1124,7 +1124,9 @@ static int genphy_config_advert(struct phy_device *phydev)
>>  int genphy_setup_forced(struct phy_device *phydev)
>>  {
>>  	int ctl = 0;
>> +	int val = phy_read(phydev, MII_BMCR);
>>
>> +	ctl |= val & BMCR_LOOPBACK;
>>  	phydev->pause = 0;
>>  	phydev->asym_pause = 0;
>>
>> -- 2.7.0
>>
> 
> 
