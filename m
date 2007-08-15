From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Subject: Re: [patch 08/18] 3c59x: check return of pci_enable_device()
Date: Wed, 15 Aug 2007 22:59:10 +0200
Message-ID: <20070815205910.GB6367@bayes.mathematik.tu-chemnitz.de>
References: <200708102105.l7AL5Jje008968@imap1.linux-foundation.org> <20070814095432.GA13825@hindley.org.uk> <20070815163000.GB619@bayes.mathematik.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: Mark Hindley <mark@hindley.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from john.hrz.tu-chemnitz.de ([134.109.132.2]:33160 "EHLO
	john.hrz.tu-chemnitz.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754573AbXHOU7P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 16:59:15 -0400
Content-Disposition: inline
In-Reply-To: <20070815163000.GB619@bayes.mathematik.tu-chemnitz.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 15, 2007 at 06:30:00PM +0200, Steffen Klassert wrote:
> On Tue, Aug 14, 2007 at 10:54:32AM +0100, Mark Hindley wrote:
> > On Tue, Aug 14, 2007 at 01:33:26AM -0400, Jeff Garzik wrote:
> > > I would strongly prefer that vortex_up return a value, since all the 
> > > important callers of this function can themselves return an error back 
> > > to the system.
> > > 
> > > we can definitely return a meaningful return value here, if 
> > > pci_enable_device() fails, and I would rather not apply a patch that 
> > > fails to propagate a serious condition (pci_enable_device failure is 
> > > indeed serious) when it is possible to do so
> > > 
> > 
> > OK. Any comments on this revised version? I have only ignored the return of
> > vortex_up in vortex_error. It is not immediately clear what to do if
> > vortex_up still fails there after a pci reset.
> > 
> > Mark
> > 
> > 
> > diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
> > index 001c66d..a1dfd6b 100644
> > --- a/drivers/net/3c59x.c
> > +++ b/drivers/net/3c59x.c
> > @@ -705,7 +705,7 @@ static struct {
> >  
> >  static int vortex_probe1(struct device *gendev, void __iomem *ioaddr, int irq,
> >  				   int chip_idx, int card_idx);
> > -static void vortex_up(struct net_device *dev);
> > +static int vortex_up(struct net_device *dev);
> >  static void vortex_down(struct net_device *dev, int final);
> >  static int vortex_open(struct net_device *dev);
> >  static void mdio_sync(void __iomem *ioaddr, int bits);
> > @@ -841,8 +841,11 @@ static int vortex_resume(struct pci_dev *pdev)
> >  			return -EBUSY;
> >  		}
> >  		if (netif_running(dev)) {
> > -			vortex_up(dev);
> > -			netif_device_attach(dev);
> > +			err = vortex_up(dev);
> > +			if (err)
> > +				return err;
> > +			else  
> > +				netif_device_attach(dev);
> >  		}
> >  	}
> >  	return 0;
> 
> I think we should free the requested irq if vortex_up really fails here.
> 

I was wrong, this will be done in vortex_close. So it is OK as it is.

Steffen 
