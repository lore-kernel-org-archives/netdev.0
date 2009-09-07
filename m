From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH 1/2] Add an alternative cs89x0 driver
Date: Mon, 7 Sep 2009 15:21:31 +0200
Message-ID: <20090907132131.GA25789@pengutronix.de>
References: <1240387172-21818-1-git-send-email-s.hauer@pengutronix.de> <1240387172-21818-2-git-send-email-s.hauer@pengutronix.de> <20090826104634.GA14425@e-circ.dyndns.org> <20090907102434.GC31592@pengutronix.de> <20090907123554.GA2928@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Kurt Van Dijck <kurt.van.dijck@eia.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:37002 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751462AbZIGNV3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2009 09:21:29 -0400
Content-Disposition: inline
In-Reply-To: <20090907123554.GA2928@e-circ.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 07, 2009 at 02:35:54PM +0200, Kurt Van Dijck wrote:
> On Mon, Sep 07, 2009 at 12:24:34PM +0200, Sascha Hauer wrote:
> > Date: Mon, 7 Sep 2009 12:24:34 +0200
> > Subject: Re: [PATCH 1/2] Add an alternative cs89x0 driver
> > From: Sascha Hauer <s.hauer@pengutronix.de>
> > To: Kurt Van Dijck <kurt.van.dijck@eia.be>
> > Cc: netdev@vger.kernel.org
> > List-ID: <netdev.vger.kernel.org>
> > 
> > Hi Kurt,
> > 
> > On Wed, Aug 26, 2009 at 12:46:34PM +0200, Kurt Van Dijck wrote:
> > > Hi Sacha,
> > > 
> > > I'm using a 2.6.25.
> > > Converting to your platform_device based driver,
> > > I needed to configure the irq (see patch, irq flags).
> > > Looking in the old cs89x0.c, it's done in the driver. Should I have
> > > configured the irq level elsewhere? Or is this patch valid to do?
> > 
> > This is the way to go. I don't know if the cs89x0 has configurable
> > interrupt levels though.
> I haven't read any spec about cs89x0, but by looking in the existing
> code:
> 1) IRQF_TRIGGER_HIGH seems like the default
> 2) the old driver didn't do any irq config in the chip either.
> May I assume you were lucky testing the driver on a platform that had
> IRQF_TRIGGER_HIGH per default?
> I have it running (with patch) on a iMX31 (arm)

I tested it with an i.MX1. Looking at the code it seems that
__irq_set_trigger is only called if one of the trigger mask bits is set.
So the interrupt control registers are never touched when 0 is passed as
irq flags. The reset default for i.MX is rising edge.

Sascha


-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
