From: John Crispin <blogic@openwrt.org>
Subject: Re: [PATCH] net: mediatek: fix checking for NULL instead of IS_ERR()
 in .probe
Date: Wed, 23 Mar 2016 10:07:28 +0100
Message-ID: <56F25CD0.5070806@openwrt.org>
References: <1458687964-9690-1-git-send-email-vz@mleia.com>
 <56F25B42.5030005@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Matthias Brugger <matthias.bgg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Felix Fietkau <nbd@openwrt.org>, netdev@vger.kernel.org,
	linux-mediatek@lists.infradead.org,
	linux-arm-kernel@lists.infradead.org
To: Vladimir Zapolskiy <vz@mleia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caladan.dune.hu ([78.24.191.180]:34948 "EHLO arrakis.dune.hu"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754537AbcCWJHd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Mar 2016 05:07:33 -0400
In-Reply-To: <56F25B42.5030005@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 23/03/2016 10:00, Matthias Brugger wrote:
> 
> 
> On 23/03/16 00:06, Vladimir Zapolskiy wrote:
>> devm_ioremap_resource() returns ERR_PTR() value on error, it never
>> returns NULL, fix it and propagate the returned error upwards.
>>
>> Fixes: 656e705243fd ("net-next: mediatek: add support for MT7623
>> ethernet")
>> Signed-off-by: Vladimir Zapolskiy <vz@mleia.com>
>> ---
> 
> Reviewed-by: Matthias Brugger <mbrugger@suse.com>
> 

Acked-by: John Crispin <blogic@openwrt.org>

Thanks for the fix !


>>   drivers/net/ethernet/mediatek/mtk_eth_soc.c | 4 ++--
>>   1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
>> b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
>> index 7f2126b..e0b68af 100644
>> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
>> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
>> @@ -1690,8 +1690,8 @@ static int mtk_probe(struct platform_device *pdev)
>>           return -ENOMEM;
>>
>>       eth->base = devm_ioremap_resource(&pdev->dev, res);
>> -    if (!eth->base)
>> -        return -EADDRNOTAVAIL;
>> +    if (IS_ERR(eth->base))
>> +        return PTR_ERR(eth->base);
>>
>>       spin_lock_init(&eth->page_lock);
>>
>>
