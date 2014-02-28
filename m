From: Jingoo Han <jg1.han@samsung.com>
Subject: Re: [PATCH 1/2] net: w5300: Use devm_ioremap_resource()
Date: Fri, 28 Feb 2014 14:40:42 +0900
Message-ID: <001401cf3447$9ecbc330$dc634990$%han@samsung.com>
References: <000001cf33a6$e0a57040$a1f050c0$%han@samsung.com>
 <20140227.170641.962779709265574310.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, msink@permonline.ru,
	'Jingoo Han' <jg1.han@samsung.com>
To: 'David Miller' <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:11276 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750719AbaB1Fkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 00:40:46 -0500
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0N1O00DOZYFVFY00@mailout3.samsung.com> for
 netdev@vger.kernel.org; Fri, 28 Feb 2014 14:40:43 +0900 (KST)
In-reply-to: <20140227.170641.962779709265574310.davem@davemloft.net>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, February 28, 2014 7:07 AM, David Miller wrote:
> From: Jingoo Han <jg1.han@samsung.com>
> Date: Thu, 27 Feb 2014 19:30:04 +0900
> 
> > Use devm_ioremap_resource() in order to make the code simpler,
> > and remove redundant return value check of platform_get_resource()
> > because the value is checked by devm_ioremap_resource().
> >
> > Signed-off-by: Jingoo Han <jg1.han@samsung.com>
> 
> I think the code with the NULL check removed is harder for semantic
> checkers to figure out, because of what will look like a blind
> dereference via resource_size(mem).
> 
> Unless all semantic checkers are going to learn the complete semantics
> of devm_ioremap_resource(), in particular that it will signal an error
> on a NULL second argument, and then the semantic checker will see
> the complete control flow in the call site, I think we should keep
> the NULL check.

OK, I see.
I agree with your opinion. I will send v2 patch, soon.
Thank you for your comment.

Best regards,
Jingoo Han

> 
> Maybe recode this as:
> 
> 	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> 	if (!mem)
> 		return -ENXIO;
> 	mem_size = resource_size(mem);
> 
> 	priv->base = devm_ioremap_resource(&pdev->dev, mem);
> 	if (IS_ERR(priv->base))
> 		return PTR_ERR(priv->base);
> 
> Same goes for your other patch.
