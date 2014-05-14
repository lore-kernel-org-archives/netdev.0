From: Jingoo Han <jg1.han@samsung.com>
Subject: Re: [PATCH] net: systemport: Use devm_ioremap_resource()
Date: Wed, 14 May 2014 14:21:03 +0900
Message-ID: <002201cf6f34$4d1ecb40$e75c61c0$%han@samsung.com>
References: <001c01cf6f22$c9fe6f60$5dfb4e20$%han@samsung.com>
 <CAGVrzcb5M-jZgZJnLKA8gzdnEV52aKtmuj1O9r5EbbOp=xuBmQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "'David S. Miller'" <davem@davemloft.net>,
	'netdev' <netdev@vger.kernel.org>,
	'Jingoo Han' <jg1.han@samsung.com>
To: 'Florian Fainelli' <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:35024 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753507AbaENFVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 01:21:06 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0N5J0031JTJ4BA50@mailout4.samsung.com> for
 netdev@vger.kernel.org; Wed, 14 May 2014 14:21:04 +0900 (KST)
In-reply-to: <CAGVrzcb5M-jZgZJnLKA8gzdnEV52aKtmuj1O9r5EbbOp=xuBmQ@mail.gmail.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, May 14, 2014 1:05 PM, Florian Fainelli wrote:
> 2014-05-13 20:15 GMT-07:00 Jingoo Han <jg1.han@samsung.com>:
> > Use devm_ioremap_resource() because devm_request_and_ioremap() is
> > obsoleted by devm_ioremap_resource().
> 
> As of net-next of today, I see nothing that warns when using this
> function that it is obsolete, nor is it commented as such, how about
> it gets annotated with __deprecated so people stop using it even for
> new submissions?

I agree with your suggestion. I will send the patch to mark it as
deprecated. :-)


> 
> >
> > Signed-off-by: Jingoo Han <jg1.han@samsung.com>
> 
> Acked-by: Florian Fainelli <f.fainelli@gmail.com>

Thank your Acked-by.

Best regards,
Jingoo Han

> 
> > ---
> >  drivers/net/ethernet/broadcom/bcmsysport.c |    7 +++----
> >  1 file changed, 3 insertions(+), 4 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
> > index 4dc8d1e..1fa5205 100644
> > --- a/drivers/net/ethernet/broadcom/bcmsysport.c
> > +++ b/drivers/net/ethernet/broadcom/bcmsysport.c
> > @@ -1514,10 +1514,9 @@ static int bcm_sysport_probe(struct platform_device *pdev)
> >                 goto err;
> >         }
> >
> > -       priv->base = devm_request_and_ioremap(&pdev->dev, r);
> > -       if (!priv->base) {
> > -               dev_err(&pdev->dev, "register remap failed\n");
> > -               ret = -ENOMEM;
> > +       priv->base = devm_ioremap_resource(&pdev->dev, r);
> > +       if (IS_ERR(priv->base)) {
> > +               ret = PTR_ERR(priv->base);
> >                 goto err;
> >         }
> >
> > --
> > 1.7.10.4
