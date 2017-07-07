From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: Re: [PATCH] net: ethernet: mediatek: add NULL check on
 of_match_device() return value
Date: Fri, 07 Jul 2017 15:08:31 -0500
Message-ID: <20170707150831.Horde.MYtEbXeqxGS-hTg2bUv3DWt@gator4166.hostgator.com>
References: <20170707071135.GA29205@embeddedgus>
 <20170707145717.GG24237@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Cc: Felix Fietkau <nbd@openwrt.org>, John Crispin <blogic@openwrt.org>,
        Matthias Brugger <matthias.bgg@gmail.com>,
        netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
        linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170707145717.GG24237@lunn.ch>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Quoting Andrew Lunn <andrew@lunn.ch>:

> On Fri, Jul 07, 2017 at 02:11:35AM -0500, Gustavo A. R. Silva wrote:
>> Check return value from call to of_match_device()
>> in order to prevent a NULL pointer dereference.
>>
>> In case of NULL print error message and return -ENODEV
>>
>> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
>> ---
>>  drivers/net/ethernet/mediatek/mtk_eth_soc.c | 5 +++++
>>  1 file changed, 5 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c  
>> b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
>> index adaaafc..6a77dea 100644
>> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
>> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
>> @@ -2408,6 +2408,11 @@ static int mtk_probe(struct platform_device *pdev)
>>  	int i;
>>
>>  	match = of_match_device(of_mtk_match, &pdev->dev);
>> +	if (!match) {
>> +		dev_err(&pdev->dev, "failed to match device\n");
>> +		return -ENODEV;
>> +	}
>> +
>>  	soc = (struct mtk_soc_data *)match->data;
>
> Hi Gustavo
>
> I think you are fixing the wrong thing. The soc variable is unused. Also,
>
> const struct of_device_id of_mtk_match[] = {
>         { .compatible = "mediatek,mt2701-eth" },
>         {},
> };
>
> So match->data is NULL. This code is all pointless and should be
> removed, rather than try to avoid a NULL pointer dereference which can
> not actually happen.
>

You are right. Thank you for pointing it out. I'll remove that code  
and send a new patch shortly.

Thanks!
--
Gustavo A. R. Silva
