From: Kurt Van Dijck <kurt.van.dijck@eia.be>
Subject: Re: [PATCH 1/2] Add an alternative cs89x0 driver
Date: Mon, 7 Sep 2009 14:35:54 +0200
Message-ID: <20090907123554.GA2928@e-circ.dyndns.org>
References: <1240387172-21818-1-git-send-email-s.hauer@pengutronix.de> <1240387172-21818-2-git-send-email-s.hauer@pengutronix.de> <20090826104634.GA14425@e-circ.dyndns.org> <20090907102434.GC31592@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.eia.be ([194.78.71.18]:47529 "EHLO mail.eia.be"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750928AbZIGMfz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Sep 2009 08:35:55 -0400
Content-Disposition: inline
In-Reply-To: <20090907102434.GC31592@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 07, 2009 at 12:24:34PM +0200, Sascha Hauer wrote:
> Date: Mon, 7 Sep 2009 12:24:34 +0200
> Subject: Re: [PATCH 1/2] Add an alternative cs89x0 driver
> From: Sascha Hauer <s.hauer@pengutronix.de>
> To: Kurt Van Dijck <kurt.van.dijck@eia.be>
> Cc: netdev@vger.kernel.org
> List-ID: <netdev.vger.kernel.org>
> 
> Hi Kurt,
> 
> On Wed, Aug 26, 2009 at 12:46:34PM +0200, Kurt Van Dijck wrote:
> > Hi Sacha,
> > 
> > I'm using a 2.6.25.
> > Converting to your platform_device based driver,
> > I needed to configure the irq (see patch, irq flags).
> > Looking in the old cs89x0.c, it's done in the driver. Should I have
> > configured the irq level elsewhere? Or is this patch valid to do?
> 
> This is the way to go. I don't know if the cs89x0 has configurable
> interrupt levels though.
I haven't read any spec about cs89x0, but by looking in the existing
code:
1) IRQF_TRIGGER_HIGH seems like the default
2) the old driver didn't do any irq config in the chip either.
May I assume you were lucky testing the driver on a platform that had
IRQF_TRIGGER_HIGH per default?
I have it running (with patch) on a iMX31 (arm)

Kurt
> 
> Sascha
> 
> > 
> > Kurt
> > 
> > Signed-off-by: Kurt Van Dijck <kurt.van.dijck@eia.be>
> > ---
> > Index: drivers/net/cirrus-cs89x0.c
> > ===================================================================
> > --- drivers/net/cirrus-cs89x0.c	(revision 7107)
> > +++ drivers/net/cirrus-cs89x0.c	(working copy)
> > @@ -487,7 +487,8 @@
> >         }
> >  
> >         /* install interrupt handler */
> > -       result = request_irq(ndev->irq, &cirrus_interrupt, 0, ndev->name, ndev);
> > +       result = request_irq(ndev->irq, &cirrus_interrupt,
> > +			IRQF_TRIGGER_HIGH, ndev->name, ndev);
> >         if (result < 0) {
> >                 printk(KERN_ERR "%s: could not register interrupt %d\n",
> >                        ndev->name, ndev->irq);
> > 
> 
> -- 
> Pengutronix e.K.                           |                             |
> Industrial Linux Solutions                 | http://www.pengutronix.de/  |
> Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
> Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
