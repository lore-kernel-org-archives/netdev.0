From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: Re: [PATCH 1/2] atmel/macb: fix device name when SOFT/HARD_IRQ
 enabled
Date: Wed, 9 Feb 2011 15:44:11 +0100
Message-ID: <20110209144411.GB11255@game.jcrosoft.org>
References: <1297255416-6920-1-git-send-email-plagnioj@jcrosoft.com>
 <4D529992.7050502@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	Paul Chavent <paul.chavent@fnac.net>
To: Sergei Shtylyov <sshtylyov@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 26.mail-out.ovh.net ([91.121.27.225]:49456 "HELO
	26.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752123Ab1BIOrG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Feb 2011 09:47:06 -0500
Content-Disposition: inline
In-Reply-To: <4D529992.7050502@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16:41 Wed 09 Feb     , Sergei Shtylyov wrote:
> Hello.
> 
> On 09-02-2011 15:43, Jean-Christophe PLAGNIOL-VILLARD wrote:
> 
> >From: Paul Chavent<paul.chavent@fnac.net>
> 
> >When listing processes on a system with SOFT/HARD_IRQ enabled,
> >the name of the ethernet device is [irq/eth%d] (instead of [irq/eth0] for example).
> 
> >This patch call the request_irq function after having initialized the name of the device.
> 
> >Signed-off-by: Paul Chavent<paul.chavent@fnac.net>
> >Signed-off-by: Nicolas Ferre<nicolas.ferre@atmel.com>
> >Signed-off-by: Jean-Christophe PLAGNIOL-VILLARD<plagnioj@jcrosoft.com>
> [...]
> 
> >diff --git a/drivers/net/macb.c b/drivers/net/macb.c
> >index f69e73e..d642e08 100644
> >--- a/drivers/net/macb.c
> >+++ b/drivers/net/macb.c
> [...]
> >@@ -1219,13 +1209,23 @@ static int __init macb_probe(struct platform_device *pdev)
> >  	err = register_netdev(dev);
> >  	if (err) {
> >  		dev_err(&pdev->dev, "Cannot register net device, aborting.\n");
> >-		goto err_out_free_irq;
> >+		goto err_out_iounmap;
> >  	}
> >
> >-	if (macb_mii_init(bp) != 0) {
> >+	dev->irq = platform_get_irq(pdev, 0);
> 
>    platform_get_irq() can fail...
request_irq will fail too so do we really need to check it?
> 
> >+	err = request_irq(dev->irq, macb_interrupt, IRQF_SAMPLE_RANDOM,
> >+			  dev->name, dev);

Best Regards,
J.
