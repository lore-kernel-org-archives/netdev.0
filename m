From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [PATCH net-next 1/6] ethernet: wiznet: remove unnecessary check
Date: Wed, 22 Oct 2014 17:53:46 +0530
Message-ID: <5447A1D2.8050107@gmail.com>
References: <N> <1413951386-29645-1-git-send-email-varkab@cdac.in> <1413951386-29645-2-git-send-email-varkab@cdac.in> <54479876.5050202@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Varka Bhadram <varkab@cdac.in>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:50098 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932865AbaJVM0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 08:26:39 -0400
Received: by mail-pa0-f52.google.com with SMTP id fb1so3606714pad.11
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2014 05:26:39 -0700 (PDT)
In-Reply-To: <54479876.5050202@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/22/2014 05:13 PM, Sergei Shtylyov wrote:
> Hello.
>
> On 10/22/2014 8:16 AM, Varka Bhadram wrote:
>
>> devm_ioremap_resource checks platform_get_resource() return value.
>> We can remove the duplicate check here.
>
>> Signed-off-by: Varka Bhadram <varkab@cdac.in>
>> ---
>>   drivers/net/ethernet/wiznet/w5100.c |    3 +--
>>   1 file changed, 1 insertion(+), 2 deletions(-)
>
>> diff --git a/drivers/net/ethernet/wiznet/w5100.c 
>> b/drivers/net/ethernet/wiznet/w5100.c
>> index 0f56b1c..bf195e3 100644
>> --- a/drivers/net/ethernet/wiznet/w5100.c
>> +++ b/drivers/net/ethernet/wiznet/w5100.c
>> @@ -638,8 +638,7 @@ static int w5100_hw_probe(struct platform_device 
>> *pdev)
>>       }
>>
>>       mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
>> -    if (!mem)
>> -        return -ENXIO;
>> +
>>       mem_size = resource_size(mem);
>
>    This would cause a NULL dereference on resource_size() call if 
> 'mem' is NULL. You can't remove the NULL check because of that.
>
Ok i will fix it . Thankx for the review.

>>
>>       priv->base = devm_ioremap_resource(&pdev->dev, mem);
>>
>
> WBR, Sergei
>


-- 
Regards,
Varka Bhadram.
