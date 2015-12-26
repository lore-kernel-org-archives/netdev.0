From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 6/7] drivers: net: cpsw: fix error return code
Date: Sat, 26 Dec 2015 22:51:30 +0300
Message-ID: <567EEFC2.4080800@cogentembedded.com>
References: <1451143726-28195-1-git-send-email-Julia.Lawall@lip6.fr>
 <1451143726-28195-7-git-send-email-Julia.Lawall@lip6.fr>
 <567ED019.3000407@cogentembedded.com>
 <alpine.DEB.2.02.1512261838330.2064@localhost6.localdomain6>
 <567ED36A.9000701@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:33934 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751646AbbLZTve (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Dec 2015 14:51:34 -0500
Received: by mail-lb0-f170.google.com with SMTP id pv2so92609471lbb.1
        for <netdev@vger.kernel.org>; Sat, 26 Dec 2015 11:51:34 -0800 (PST)
In-Reply-To: <567ED36A.9000701@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/26/2015 08:50 PM, Sergei Shtylyov wrote:

>>>> diff --git a/drivers/net/ethernet/ti/cpsw.c
>>>> b/drivers/net/ethernet/ti/cpsw.c
>>>> index 3409e80..6a76992 100644
>>>> --- a/drivers/net/ethernet/ti/cpsw.c
>>>> +++ b/drivers/net/ethernet/ti/cpsw.c
>>>> @@ -2448,8 +2448,10 @@ static int cpsw_probe(struct platform_device *pdev)
>>>>
>>>>        /* RX IRQ */
>>>>        irq = platform_get_irq(pdev, 1);
>>>> -    if (irq < 0)
>>>> +    if (irq < 0) {
>>>> +        ret = -ENOENT;
>>>
>>>     Why not just propagate an error returned by that function?
>>
>> OK, I did what was done a few lines before in the same function:
>>
>>          ndev->irq = platform_get_irq(pdev, 1);
>>          if (ndev->irq < 0) {
>>         dev_err(priv->dev, "error getting irq resource\n");
>>                  ret = -ENOENT;
>>                  goto clean_ale_ret;
>>          }
>>
>> Maybe they should all be changed?
>
>     Yeah, I'd vote for it. I'm seeing no sense in overriding an actual error.

    Hm, I decided to check drivers/base/dd.c and I think I maybe know the 
reason now: -ENXIO, usually returned by platform_get_irq(), is silently 
"swallowed" by really_probe(); to be precise, -ENODEV and -ENXIO are only 
reported with pr_debug(), while -ENOENT causes printk(KERN_WARNING, ...)...

> [...]
>
>> julia

MBR, Sergei
