From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH] e100: Use pci_pme_active to clear PME_Status and disable PME#
Date: Mon, 15 Sep 2008 01:44:35 +0200
Message-ID: <200809150144.36142.rjw@sisk.pl>
References: <200808051730.27599.alessandro.guido@gmail.com> <200808080018.05887.rjw@sisk.pl> <48CC1F7C.7050908@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jesse Barnes <jbarnes@virtuousgeek.org>,
	Alessandro Guido <alessandro.guido@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	pm list <linux-pm@lists.linux-foundation.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754782AbYINXkJ@vger.kernel.org>
In-Reply-To: <48CC1F7C.7050908@garzik.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday, 13 of September 2008, Jeff Garzik wrote:
> Rafael J. Wysocki wrote:
> > e100: Use pci_pme_active to clear PME_Status and disable PME#
> > 
> > Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
> > 
> > ---
> >  drivers/net/e100.c |    4 +---
> >  1 file changed, 1 insertion(+), 3 deletions(-)
> > 
> > Index: linux-2.6/drivers/net/e100.c
> > ===================================================================
> > --- linux-2.6.orig/drivers/net/e100.c
> > +++ linux-2.6/drivers/net/e100.c
> > @@ -2738,9 +2738,7 @@ static int __devinit e100_probe(struct p
> >  		nic->flags |= wol_magic;
> >  
> >  	/* ack any pending wake events, disable PME */
> > -	err = pci_enable_wake(pdev, 0, 0);
> > -	if (err)
> > -		DPRINTK(PROBE, ERR, "Error clearing wake event\n");
> > +	pci_pme_active(pdev, false);
> 
> Since I am rusty on my PCI...  why is this needed?

Because we just want to clear PME_Status and disable PME#, but
pci_enable_wake() involves an ACPI call and generally depends on the
dev->power.can_wakeup and dev->power.should_wakeup flags being set.

The patch I sent here http://marc.info/?l=linux-kernel&m=122096638020191&w=4
has a better changelog.

Thanks,
Rafael
