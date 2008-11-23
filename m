From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 8139too: use err.h macros
Date: Sun, 23 Nov 2008 13:53:11 -0800 (PST)
Message-ID: <20081123.135311.74121589.davem@davemloft.net>
References: <20081123102237.42cc99dd@extreme>
	<20081123183645.GA11340@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, romieu@fr.zoreil.com,
	netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59051
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751178AbYKWVxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Nov 2008 16:53:12 -0500
In-Reply-To: <20081123183645.GA11340@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jeff@garzik.org>
Date: Sun, 23 Nov 2008 13:36:45 -0500

> On Sun, Nov 23, 2008 at 10:22:37AM -0800, Stephen Hemminger wrote:
> > Instead of using call by reference use the PTR_ERR macros to handle
> > return value with error case. Compile tested only.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > 
> > --- a/drivers/net/8139too.c	2008-11-23 10:16:26.000000000 -0800
> > +++ b/drivers/net/8139too.c	2008-11-23 10:19:05.000000000 -0800
> > @@ -741,8 +741,7 @@ static void rtl8139_chip_reset (void __i
> >  }
> >  
> >  
> > -static int __devinit rtl8139_init_board (struct pci_dev *pdev,
> > -					 struct net_device **dev_out)
> > +static __devinit struct net_device * rtl8139_init_board (struct pci_dev *pdev)
> >  {
> >  	void __iomem *ioaddr;
> >  	struct net_device *dev;
> 
> I won't NAK this, but I do wonder why a solution based on yucky
> magic typecasting is preferred...?

Two return values without having to return it by reference
as an argument.

I blogged about the pros and cons of this earlier this year.
