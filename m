From: Jingoo Han <jg1.han@samsung.com>
Subject: Re: [PATCH] moxa: drop free_irq of devm_request_irq allocated irq
Date: Thu, 26 Sep 2013 11:36:39 +0900
Message-ID: <001a01ceba61$3aaf3cc0$b00db640$%han@samsung.com>
References: <CAPgLHd8YRP7kL_jNHi3J9jFn86f=Fv-AWWUY_aRGZQOgVTNPgg@mail.gmail.com>
 <000001ceba51$f8b45c10$ea1d1430$%han@samsung.com>
 <CAPgLHd9VXaPx18ujDKbUik6XjOsnARcK-C-orCOynyJaWFREjw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'Jonas Jensen' <jonas.jensen@gmail.com>,
	"'David S. Miller'" <davem@davemloft.net>,
	'Grant Likely' <grant.likely@linaro.org>,
	rob.herring@calxeda.com, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org, 'Sachin Kamat' <sachin.kamat@linaro.org>,
	'Jingoo Han' <jg1.han@samsung.com>
To: 'Wei Yongjun' <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:50777 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751281Ab3IZCgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 22:36:42 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MTP00GL7OKVSE00@mailout2.samsung.com> for
 netdev@vger.kernel.org; Thu, 26 Sep 2013 11:36:40 +0900 (KST)
In-reply-to: <CAPgLHd9VXaPx18ujDKbUik6XjOsnARcK-C-orCOynyJaWFREjw@mail.gmail.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, September 26, 2013 11:13 AM, Wei Yongjun wrote:
> On 09/26/2013 08:47 AM, Jingoo Han wrote:
> > On Wednesday, September 25, 2013 4:33 PM, Wei Yongjun wrote:
> >> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> >>
> >> irq allocated with devm_request_irq should not be freed using
> >> free_irq, because doing so causes a dangling pointer, and a
> >> subsequent double free.
> >>
> >> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> >> ---
> >>  drivers/net/ethernet/moxa/moxart_ether.c | 1 -
> >>  1 file changed, 1 deletion(-)
> >>
> >> diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
> >> index 83c2091..9a7fcb5 100644
> >> --- a/drivers/net/ethernet/moxa/moxart_ether.c
> >> +++ b/drivers/net/ethernet/moxa/moxart_ether.c
> >> @@ -531,7 +531,6 @@ static int moxart_remove(struct platform_device *pdev)
> >>  	struct net_device *ndev = platform_get_drvdata(pdev);
> >>
> >>  	unregister_netdev(ndev);
> >> -	free_irq(ndev->irq, ndev);
> >>  	moxart_mac_free_memory(ndev);
> >>  	free_netdev(ndev);
> > CC'ed Sachin Kamat,
> >
> > In this case, the free_irq() will be called, after calling
> > free_netdev(). 'ndev' is freed by free_netdev(). Then, 'ndev->irq'
> > is used by free_irq(). Is it right?
> >
> > In my humble opinion, it seems to make the problem.
> >
> 
> devm_request_irq() has recorded the irq and dev_id, so free_irq() by devm_*
> will not touch 'ndev' which has been freed by free_netdev().
> So, if we not need to call free_irq() before free_netdev(), there will be
> no problem.

However, 'dev_id' is a pointer, not a value.
It seems to make the problem that references the invalid pointer.

Best regards,
Jingoo Han
