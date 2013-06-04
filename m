From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next PATCH 1/8] drivers: net: phy: at803x code cleanup on
 register and unregister driver
Date: Tue, 04 Jun 2013 17:43:20 +0400
Message-ID: <51ADEEF8.6040503@cogentembedded.com>
References: <1370326212-17580-1-git-send-email-mugunthanvnm@ti.com> <1370326212-17580-2-git-send-email-mugunthanvnm@ti.com> <51ADD73E.40405@cogentembedded.com> <51ADE0EA.7060008@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	devicetree-discuss@lists.ozlabs.org, linux-omap@vger.kernel.org,
	benoit.cousson@linaro.org, paul@pwsan.com,
	Matus Ujhelyi <ujhelyi.m@gmail.com>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <51ADE0EA.7060008@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/04/2013 04:43 PM, Mugunthan V N wrote:

>
>>
>>> Make use of phy_drivers_register/phy_drivers_unregister to 
>>> register/unregister
>>> multiple phy drivers in a single module.
>>
>>> Cc: Matus Ujhelyi <ujhelyi.m@gmail.com>
>>> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
>>> ---
>>>   drivers/net/phy/at803x.c |   35 ++++++++++-------------------------
>>>   1 file changed, 10 insertions(+), 25 deletions(-)
>>
>>> diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
>>> index 45cbc10..a1063e1 100644
>>> --- a/drivers/net/phy/at803x.c
>>> +++ b/drivers/net/phy/at803x.c
>>> @@ -108,8 +108,9 @@ static int at803x_config_init(struct phy_device 
>>> *phydev)
>>>       return 0;
>>>   }
>>>
>>> -/* ATHEROS 8035 */
>>> -static struct phy_driver at8035_driver = {
>>> +static struct phy_driver at803x_driver[] = {
>>> +{
>>> +    /* ATHEROS 8035 */
>>>       .phy_id        = 0x004dd072,
>>>       .name        = "Atheros 8035 ethernet",
>>>       .phy_id_mask    = 0xffffffef,
>>
>>     That's improper indentation. Needs to be shifted by one tab.
> This indentation is as per the coding style followed in all ethernet
> phy drivers. If this need so to be changed, it must be a separate patch
> for all the ethernet phy drivers.
>>
>>> @@ -136,32 +135,18 @@ static struct phy_driver at8030_driver = {
>>>       .driver        = {
>>>           .owner = THIS_MODULE,
>>>       },
>>> -};
>>> +} };
>>
>>    Looks ugly...
> This is also the same as per the style followed in ethernet phy drivers
> Please refer the below grep output
>
> $ grep -rnaI "} };" drivers/net/phy/*
> drivers/net/phy/at803x.c:201:} };
> drivers/net/phy/bcm63xx.c:101:} };
> drivers/net/phy/bcm87xx.c:217:} };
> drivers/net/phy/broadcom.c:829:} };
> drivers/net/phy/cicada.c:130:} };
> drivers/net/phy/davicom.c:183:} };
> drivers/net/phy/icplus.c:254:} };
> drivers/net/phy/lxt.c:313:} };
> drivers/net/phy/micrel.c:323:} };
> drivers/net/phy/smsc.c:242:} };
> drivers/net/phy/ste10Xp.c:113:} };
> drivers/net/phy/vitesse.c:192:} };

    Sorry for the noise, coldn't imagine they're all that bad. :-)

> Regards
> Mugunthan V N

WBR, Sergei

