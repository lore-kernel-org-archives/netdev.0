From: Toru UCHIYAMA <uchiyama.toru@jp.fujitsu.com>
Subject: Re: 2.6.31-rc9 breaks gianfar
Date: Mon, 07 Sep 2009 12:21:42 +0900
Message-ID: <4AA47C46.8070900@jp.fujitsu.com>
References: <20090906072707.GA5699@trillian.comsick.at> <20090906.014131.78926800.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mike@it-loops.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758841AbZIGDWl@vger.kernel.org>
In-Reply-To: <20090906.014131.78926800.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

I'm sorry.It was my mistake.
I will note that it is not never in the future.
Thank you for the correction.


> From: Michael Guntsche <mike@it-loops.com>
> Date: Sun, 6 Sep 2009 09:27:08 +0200
> 
> Please also report networking bugs to netdev@vger.kernel.org
> and CC: the person who commited the problematic commit.
> 
>> Commit 
>> 38bddf04bcfe661fbdab94888c3b72c32f6873b3 gianfar: gfar_remove needs to call unregister_netdev()
>>
>> breaks the build of the gianfar driver because "dev" is undefined in
>> this function. To quickly test rc9 I changed this to priv->ndev but I do
>> not know if this is the correct one.
> 
> Toru-chan, did you even compile test this again current kernels?
> 
> I'll commit the following fix and push it to Linus, thanks.
> 
>>From 5db8bfee2dbb3ff28c18868081398fa6e2155053 Mon Sep 17 00:00:00 2001
> From: David S. Miller <davem@davemloft.net>
> Date: Sun, 6 Sep 2009 01:41:02 -0700
> Subject: [PATCH] gianfar: Fix build.
> 
> Reported by Michael Guntsche <mike@it-loops.com>
> 
> --------------------
> Commit
> 38bddf04bcfe661fbdab94888c3b72c32f6873b3 gianfar: gfar_remove needs to call unregister_netdev()
> 
> breaks the build of the gianfar driver because "dev" is undefined in
> this function. To quickly test rc9 I changed this to priv->ndev but I do
> not know if this is the correct one.
> --------------------
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  drivers/net/gianfar.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
> index 24f7ca5..a00ec63 100644
> --- a/drivers/net/gianfar.c
> +++ b/drivers/net/gianfar.c
> @@ -491,7 +491,7 @@ static int gfar_remove(struct of_device *ofdev)
>  
>  	dev_set_drvdata(&ofdev->dev, NULL);
>  
> -	unregister_netdev(dev);
> +	unregister_netdev(priv->ndev);
>  	iounmap(priv->regs);
>  	free_netdev(priv->ndev);
>  


-- 
-----------------------------------------------
Toru UCHIYAMA      uchiyama.toru@jp.fujitsu.com
