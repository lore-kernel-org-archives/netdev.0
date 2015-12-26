From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 6/7] drivers: net: cpsw: fix error return code
Date: Sat, 26 Dec 2015 20:50:34 +0300
Message-ID: <567ED36A.9000701@cogentembedded.com>
References: <1451143726-28195-1-git-send-email-Julia.Lawall@lip6.fr>
 <1451143726-28195-7-git-send-email-Julia.Lawall@lip6.fr>
 <567ED019.3000407@cogentembedded.com>
 <alpine.DEB.2.02.1512261838330.2064@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1512261838330.2064@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/26/2015 8:40 PM, Julia Lawall wrote:

>>> diff --git a/drivers/net/ethernet/ti/cpsw.c
>>> b/drivers/net/ethernet/ti/cpsw.c
>>> index 3409e80..6a76992 100644
>>> --- a/drivers/net/ethernet/ti/cpsw.c
>>> +++ b/drivers/net/ethernet/ti/cpsw.c
>>> @@ -2448,8 +2448,10 @@ static int cpsw_probe(struct platform_device *pdev)
>>>
>>>    	/* RX IRQ */
>>>    	irq = platform_get_irq(pdev, 1);
>>> -	if (irq < 0)
>>> +	if (irq < 0) {
>>> +		ret = -ENOENT;
>>
>>     Why not just propagate an error returned by that function?
>
> OK, I did what was done a few lines before in the same function:
>
>          ndev->irq = platform_get_irq(pdev, 1);
>          if (ndev->irq < 0) {
> 		dev_err(priv->dev, "error getting irq resource\n");
>                  ret = -ENOENT;
>                  goto clean_ale_ret;
>          }
>
> Maybe they should all be changed?

    Yeah, I'd vote for it. I'm seeing no sense in overriding an actual error.

[...]

> julia

MBR, Sergei
