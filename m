From: Harry Coin <hcoin@n4comm.com>
Subject: Re: 3c59x.c patch to 2.6.18 fixing Wake on Lan (WOL)
Date: Mon, 15 Jan 2007 11:35:35 -0600
Message-ID: <4.3.2.7.2.20070115113207.03dcc558@www.n4comm.com>
References: <4.3.2.7.2.20070115091058.063866c8@www.n4comm.com>
 <4.3.2.7.2.20070115091058.063866c8@www.n4comm.com> <1168876836.8922.1.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail14d.g14.rapidsite.net ([128.121.64.66]:28383 "HELO
	mail14d.g14.rapidsite.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751326AbXAORnq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jan 2007 12:43:46 -0500
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1168876836.8922.1.camel@localhost.localdomain>
References: <4.3.2.7.2.20070115091058.063866c8@www.n4comm.com>
 <4.3.2.7.2.20070115091058.063866c8@www.n4comm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

At 11:00 AM 1/15/2007 -0500, Dan Williams wrote:
>On Mon, 2007-01-15 at 09:12 -0600, Harry Coin wrote:
> > Hello all.
> >
> > The 3c59x.c in kernel 2.6.18 (and as I see later ones too) attempts
> > to enable PME from the already awake D0 state. The PME config space on 
> Dell
> > Optiplexs
> > for this chip has a zero in the capabilities for this bit-- no 'wake 
> from d0'.
> >
> > The pci_enable_wake in 2.6.18 tests the capabilities before enabling PME,
> > so the pci_wake call fails, its result is not tested, so no error is 
> reported.
> >
> > The routine changes the wake request from 0 to D3_hot.  This fix
> > causes wake on lan (WOL) to work properly on older Dell Optiplex models.
> >
> > Kindly overlook newbie mistakes.  Thank you.
>
>You'll want to include a line like:
>
>Signed-off-by: Harry Coin <your email here>
>
>which signifies that you are legally able to contribute the attached
>patch under the GPL license.  Do this right before the start of the
>patch (where you put your signature in the previous mail).
>
>Dan

  Thank you.  I've added it to a repeat of the original posting copied below.

> >
> >
> > --- drivers-orig/3c59x.c        2007-01-15 00:03:52.000000000 -0600
> > +++ drivers-fixed/3c59x.c       2007-01-15 00:46:37.000000000 -0600
> > @@ -3090,8 +3090,8 @@
> >   /* Set Wake-On-LAN mode and put the board into D3 (power-down) state. */
> >   static void acpi_set_WOL(struct net_device *dev)
> >   {
> > -       struct vortex_private *vp = netdev_priv(dev);
> > -       void __iomem *ioaddr = vp->ioaddr;
> > +  struct vortex_private *vp = netdev_priv(dev);
> > +  void __iomem *ioaddr = vp->ioaddr;
> >
> >          if (vp->enable_wol) {
> >                  /* Power up on: 1==Downloaded Filter, 2==Magic Packets,
> > 4==Link Status. */
> > @@ -3101,7 +3101,7 @@
> >                  iowrite16(SetRxFilter|RxStation|RxMulticast|RxBroadcast,
> > ioaddr + EL3_CMD);
> >                  iowrite16(RxEnable, ioaddr + EL3_CMD);
> >
> > -               pci_enable_wake(VORTEX_PCI(vp), 0, 1);
> > +               pci_enable_wake(VORTEX_PCI(vp),PCI_D3hot,1);
> >
> >                  /* Change the power state to D3; RxEnable doesn't take
> > effect. */
> >                  pci_set_power_state(VORTEX_PCI(vp), PCI_D3hot);
> >
> > Harry Coin
> > Bettendorf, Iowa
Signed-off-by: Harry Coin hcoin@n4comm.com


