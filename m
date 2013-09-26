From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: Re: [PATCH] moxa: drop free_irq of devm_request_irq allocated irq
Date: Thu, 26 Sep 2013 10:12:53 +0800
Message-ID: <CAPgLHd9VXaPx18ujDKbUik6XjOsnARcK-C-orCOynyJaWFREjw@mail.gmail.com>
References: <CAPgLHd8YRP7kL_jNHi3J9jFn86f=Fv-AWWUY_aRGZQOgVTNPgg@mail.gmail.com>
	<000001ceba51$f8b45c10$ea1d1430$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: jonas.jensen@gmail.com, davem@davemloft.net,
	grant.likely@linaro.org, rob.herring@calxeda.com,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org,
	sachin.kamat@linaro.org
To: jg1.han@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f42.google.com ([209.85.214.42]:51075 "EHLO
	mail-bk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752853Ab3IZCMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 22:12:55 -0400
Received: by mail-bk0-f42.google.com with SMTP id my10so172849bkb.15
        for <netdev@vger.kernel.org>; Wed, 25 Sep 2013 19:12:53 -0700 (PDT)
In-Reply-To: <000001ceba51$f8b45c10$ea1d1430$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/26/2013 08:47 AM, Jingoo Han wrote:
> On Wednesday, September 25, 2013 4:33 PM, Wei Yongjun wrote:
>> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>>
>> irq allocated with devm_request_irq should not be freed using
>> free_irq, because doing so causes a dangling pointer, and a
>> subsequent double free.
>>
>> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>> ---
>>  drivers/net/ethernet/moxa/moxart_ether.c | 1 -
>>  1 file changed, 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
>> index 83c2091..9a7fcb5 100644
>> --- a/drivers/net/ethernet/moxa/moxart_ether.c
>> +++ b/drivers/net/ethernet/moxa/moxart_ether.c
>> @@ -531,7 +531,6 @@ static int moxart_remove(struct platform_device *pdev)
>>  	struct net_device *ndev = platform_get_drvdata(pdev);
>>
>>  	unregister_netdev(ndev);
>> -	free_irq(ndev->irq, ndev);
>>  	moxart_mac_free_memory(ndev);
>>  	free_netdev(ndev);
> CC'ed Sachin Kamat,
>
> In this case, the free_irq() will be called, after calling
> free_netdev(). 'ndev' is freed by free_netdev(). Then, 'ndev->irq'
> is used by free_irq(). Is it right?
>
> In my humble opinion, it seems to make the problem.
>

devm_request_irq() has recorded the irq and dev_id, so free_irq() by devm_*
will not touch 'ndev' which has been freed by free_netdev().
So, if we not need to call free_irq() before free_netdev(), there will be
no problem.
