From: Jingoo Han <jg1.han@samsung.com>
Subject: Re: [PATCH] moxa: drop free_irq of devm_request_irq allocated irq
Date: Thu, 26 Sep 2013 09:47:26 +0900
Message-ID: <000001ceba51$f8b45c10$ea1d1430$%han@samsung.com>
References: <CAPgLHd8YRP7kL_jNHi3J9jFn86f=Fv-AWWUY_aRGZQOgVTNPgg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, grant.likely@linaro.org,
	rob.herring@calxeda.com, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Sachin Kamat' <sachin.kamat@linaro.org>
To: 'Wei Yongjun' <weiyj.lk@gmail.com>,
	'Jonas Jensen' <jonas.jensen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:25350 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751833Ab3IZAr2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 20:47:28 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MTP00IKYJIOGBE0@mailout2.samsung.com> for
 netdev@vger.kernel.org; Thu, 26 Sep 2013 09:47:27 +0900 (KST)
In-reply-to: <CAPgLHd8YRP7kL_jNHi3J9jFn86f=Fv-AWWUY_aRGZQOgVTNPgg@mail.gmail.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, September 25, 2013 4:33 PM, Wei Yongjun wrote:
> 
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> irq allocated with devm_request_irq should not be freed using
> free_irq, because doing so causes a dangling pointer, and a
> subsequent double free.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> ---
>  drivers/net/ethernet/moxa/moxart_ether.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
> index 83c2091..9a7fcb5 100644
> --- a/drivers/net/ethernet/moxa/moxart_ether.c
> +++ b/drivers/net/ethernet/moxa/moxart_ether.c
> @@ -531,7 +531,6 @@ static int moxart_remove(struct platform_device *pdev)
>  	struct net_device *ndev = platform_get_drvdata(pdev);
> 
>  	unregister_netdev(ndev);
> -	free_irq(ndev->irq, ndev);
>  	moxart_mac_free_memory(ndev);
>  	free_netdev(ndev);

CC'ed Sachin Kamat,

In this case, the free_irq() will be called, after calling
free_netdev(). 'ndev' is freed by free_netdev(). Then, 'ndev->irq'
is used by free_irq(). Is it right?

In my humble opinion, it seems to make the problem.

Best regards,
Jingoo Han
