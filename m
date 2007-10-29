From: "Li Yang-r58472" <LeoLi@freescale.com>
Subject: RE: [PATCH] ucc_geth: add support for netpoll
Date: Mon, 29 Oct 2007 14:12:07 +0800
Message-ID: <989B956029373F45A0B8AF0297081890019B61BF@zch01exm26.fsl.freescale.net>
References: <20071011124842.GB13963@localhost.localdomain> <4723389F.7010109@ru.mvista.com> <20071027143731.GA2616@zarina>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Anton Vorontsov" <avorontsov@ru.mvista.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linuxppc-dev@ozlabs.org>
To: <cbou@mail.ru>, "Sergei Shtylyov" <sshtylyov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:42716 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751342AbXJ2GMO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2007 02:12:14 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20071027143731.GA2616@zarina>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Anton Vorontsov [mailto:cbou@mail.ru] 
> Sent: Saturday, October 27, 2007 10:38 PM
> To: Sergei Shtylyov
> Cc: Anton Vorontsov; netdev@vger.kernel.org; Li Yang-r58472; 
> linux-kernel@vger.kernel.org; linuxppc-dev@ozlabs.org
> Subject: Re: [PATCH] ucc_geth: add support for netpoll
> 
> On Sat, Oct 27, 2007 at 05:09:51PM +0400, Sergei Shtylyov wrote:
> > Hello.
> > 
> > Anton Vorontsov wrote:
> > 
> > > This patch adds netpoll support for the QE UCC Gigabit Ethernet 
> > > driver. The approach is very similar to the gianfar driver.
> > 
> >     It's rather contrarywise -- this is standard approach 
> and gianfar 
> > with its
> > 3 TSEC IRQs has a quite non-standard poll_controller() 
> implementation.
> 
> Oh.. well, right -- gianfar a bit more comlex in that regard.
> 
> > 
> > > Tested using netconsole.
> > 
> >     KGDBoE is considered a better test (I hope you've also 
> tested with it).
> 
> At the time of posting it was tested using netconsole only, a 
> few days later it's was tested using KGDBoE also. So, it works indeed.
> 
> > > Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com> 
> diff --git 
> > > a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c index 
> > > 18a6f48..06807ce 100644
> > > --- a/drivers/net/ucc_geth.c
> > > +++ b/drivers/net/ucc_geth.c
> > > @@ -3691,6 +3691,22 @@ static irqreturn_t 
> ucc_geth_irq_handler(int irq, void *info)
> > >  	return IRQ_HANDLED;
> > >  }
> > >  
> > > +#ifdef CONFIG_NET_POLL_CONTROLLER
> > > +/*
> > > + * Polling 'interrupt' - used by things like netconsole to send 
> > > +skbs
> > > + * without having to re-enable interrupts. It's not called while
> > > + * the interrupt routine is executing.
> > > + */
> > > +static void ucc_netpoll(struct net_device *dev) {
> > > +	struct ucc_geth_private *ugeth = netdev_priv(dev);
> > > +
> > > +	disable_irq(ugeth->ug_info->uf_info.irq);
> > > +	ucc_geth_irq_handler(ugeth->ug_info->uf_info.irq, dev);
> > > +	enable_irq(ugeth->ug_info->uf_info.irq);
> > 
> >     Why not make it less complex (for a reader and gcc too :-) ?
> 
> Yup, I'm agree here but it's too late. Again. ;-)
> 
> This patch already accepted into the -mm (a week or so after 
> the silence), so.. now I'd rather not bother Andrew with such 
> really cosmetic changes. But if Jeff would directly apply 
> modfied patch, I'll send it. ;-)

Oops.  The original patch happened to hit the Junk mail box. :(  I think
the patch is good to merge after the cosmetic change.  I can do it in
next pull request to Jeff.

Thanks
- Leo
