From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] CONFIG_PM=n slim: drivers/net/*
Date: Fri, 11 Aug 2006 19:49:52 -0700
Message-ID: <20060811194952.9d664698.akpm@osdl.org>
References: <20060812004623.GM6847@martell.zuzino.mipt.ru>
	<20060811184943.96419537.akpm@osdl.org>
	<20060812023014.GP6847@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:42682 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750785AbWHLCul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2006 22:50:41 -0400
To: Alexey Dobriyan <adobriyan@gmail.com>
In-Reply-To: <20060812023014.GP6847@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 12 Aug 2006 06:30:14 +0400
Alexey Dobriyan <adobriyan@gmail.com> wrote:

> On Fri, Aug 11, 2006 at 06:49:43PM -0700, Andrew Morton wrote:
> > On Sat, 12 Aug 2006 04:46:23 +0400
> > Alexey Dobriyan <adobriyan@gmail.com> wrote:
> >
> > > +#ifdef CONFIG_PM
> > >  static int amd8111e_suspend(struct pci_dev *pci_dev, pm_message_t state)
> > >  {
> > >  	struct net_device *dev = pci_get_drvdata(pci_dev);
> > > @@ -1873,7 +1879,7 @@ static int amd8111e_resume(struct pci_de
> > >
> > >  	return 0;
> > >  }
> > > -
> > > +#endif
> > >
> > >  static void __devexit amd8111e_remove_one(struct pci_dev *pdev)
> > >  {
> > > @@ -2152,8 +2158,10 @@ static struct pci_driver amd8111e_driver
> > >  	.id_table	= amd8111e_pci_tbl,
> > >  	.probe		= amd8111e_probe_one,
> > >  	.remove		= __devexit_p(amd8111e_remove_one),
> > > +#ifdef CONFIG_PM
> > >  	.suspend	= amd8111e_suspend,
> > >  	.resume		= amd8111e_resume
> > > +#endif
> > >  };
> >
> > The preferred way is
> >
> > #ifdef CONFIG_PM
> > static int amd8111e_suspend(...)
> > {
> > }
> > #else
> > #define amd8111e_suspend NULL
> > #define amd8111e_resume NULL
> > #endif
> 
> Plenty of drivers already use first variant.

That can be fixed.

> Also this won't allow
> 
> 	struct pci_driver {
> 		...
> 	#ifdef CONFIG_PM
> 		int (*suspend)(...);
> 		int (*resume)(...);
> 	#endif
> 		...
> 	};
> 
> which is good for a) space savings in CONFIG_PM=n case, and
> b) making drivers care about CONFIG_PM=n users hard way aka compilation
> failure.

eh?  Both versions will generate identical code.
