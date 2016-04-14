From: Weidong Wang <wangweidong1@huawei.com>
Subject: Re: [RESEND PATCH net-next] phy: keep the BCMR_LOOPBACK bit while
 setup forced mode
Date: Thu, 14 Apr 2016 10:18:29 +0800
Message-ID: <570EFDF5.7090106@huawei.com>
References: <570E3488.9060403@huawei.com> <570E558C.9010304@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <f.fainelli@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:58906 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751937AbcDNCSm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 22:18:42 -0400
In-Reply-To: <570E558C.9010304@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016/4/13 22:19, Sergei Shtylyov wrote:
> Hello.
> 
> On 4/13/2016 2:59 PM, Weidong Wang wrote:
> 
>> When tested the PHY SGMII Loopback,:
>> 1.set the LOOPBACK bit,
>> 2.set the autoneg to AUTONEG_DISABLE, it calls the
>> genphy_setup_forced which will clear the bit.
>>
>> So just keep the LOOPBACK bit while setup forced mode.
>>
>> Signed-off-by: Weidong Wang <wangweidong1@huawei.com>
>> ---
>>   drivers/net/phy/phy_device.c | 2 ++
>>   1 file changed, 2 insertions(+)
>>
>> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
>> index e551f3a..8da4b80 100644
>> --- a/drivers/net/phy/phy_device.c
>> +++ b/drivers/net/phy/phy_device.c
>> @@ -1124,7 +1124,9 @@ static int genphy_config_advert(struct phy_device *phydev)
>>   int genphy_setup_forced(struct phy_device *phydev)
>>   {
>>       int ctl = 0;
>> +    int val = phy_read(phydev, MII_BMCR);
> 
>    Please place this declaration first, DaveM prefers declarations to be sorted from longest to shortest.
> 
>>
>> +    ctl |= val & BMCR_LOOPBACK;
> 
>    Just =, removing the 'ctl' initializer, please.
> 
> [...]
> 
> MBR, Sergei
> 
Got it.

Regards,
Weidong
> 
> 
