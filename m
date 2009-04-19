From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH] irda: convert pxaficp device to net_device_ops
Date: Sun, 19 Apr 2009 12:25:41 +0200
Message-ID: <20090419102540.GA3373@psychotron.englab.brq.redhat.com>
References: <1240062266-4339-1-git-send-email-dbaryshkov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:39205 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753240AbZDSKcF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Apr 2009 06:32:05 -0400
Content-Disposition: inline
In-Reply-To: <1240062266-4339-1-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Apr 18, 2009 at 03:44:26PM CEST, dbaryshkov@gmail.com wrote:
>Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
>---
> drivers/net/irda/pxaficp_ir.c |   13 +++++++++----
> 1 files changed, 9 insertions(+), 4 deletions(-)
>
>diff --git a/drivers/net/irda/pxaficp_ir.c b/drivers/net/irda/pxaficp_ir.c
>index e775338..743952d 100644
>--- a/drivers/net/irda/pxaficp_ir.c
>+++ b/drivers/net/irda/pxaficp_ir.c
>@@ -797,6 +797,14 @@ static int pxa_irda_init_iobuf(iobuff_t *io, int size)
> 	return io->head ? 0 : -ENOMEM;
> }
> 
>+static const struct net_device_ops pxa_irda_ops = {
>+	.ndo_start_xmit = pxa_irda_hard_xmit,
>+	.ndo_open	= pxa_irda_start,
>+	.ndo_stop	= pxa_irda_stop,
>+	.ndo_do_ioctl	= pxa_irda_ioctl,
>+};
>+
>+

Patch looks, only little nitpick - why two blank lines here ^ ?

> static int pxa_irda_probe(struct platform_device *pdev)
> {
> 	struct net_device *dev;
>@@ -845,10 +853,7 @@ static int pxa_irda_probe(struct platform_device *pdev)
> 	if (err)
> 		goto err_startup;
> 
>-	dev->hard_start_xmit	= pxa_irda_hard_xmit;
>-	dev->open		= pxa_irda_start;
>-	dev->stop		= pxa_irda_stop;
>-	dev->do_ioctl		= pxa_irda_ioctl;
>+	dev->netdev_ops = &pxa_irda_ops;
> 
> 	irda_init_max_qos_capabilies(&si->qos);
> 
>-- 
>1.6.2.1
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
