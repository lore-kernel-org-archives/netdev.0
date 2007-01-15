From: Dan Williams <dcbw@redhat.com>
Subject: Re: 3c59x.c patch to 2.6.18 fixing Wake on Lan (WOL)
Date: Mon, 15 Jan 2007 11:00:35 -0500
Message-ID: <1168876836.8922.1.camel@localhost.localdomain>
References: <4.3.2.7.2.20070115091058.063866c8@www.n4comm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:35738 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750878AbXAOP6L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jan 2007 10:58:11 -0500
To: Harry Coin <hcoin@n4comm.com>
In-Reply-To: <4.3.2.7.2.20070115091058.063866c8@www.n4comm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-01-15 at 09:12 -0600, Harry Coin wrote:
> Hello all.
> 
> The 3c59x.c in kernel 2.6.18 (and as I see later ones too) attempts
> to enable PME from the already awake D0 state. The PME config space on Dell 
> Optiplexs
> for this chip has a zero in the capabilities for this bit-- no 'wake from d0'.
> 
> The pci_enable_wake in 2.6.18 tests the capabilities before enabling PME,
> so the pci_wake call fails, its result is not tested, so no error is reported.
> 
> The routine changes the wake request from 0 to D3_hot.  This fix
> causes wake on lan (WOL) to work properly on older Dell Optiplex models.
> 
> Kindly overlook newbie mistakes.  Thank you.

You'll want to include a line like:

Signed-off-by: Harry Coin <your email here>

which signifies that you are legally able to contribute the attached
patch under the GPL license.  Do this right before the start of the
patch (where you put your signature in the previous mail).

Dan

> Harry Coin
> Bettendorf, Iowa
> 
> 
> --- drivers-orig/3c59x.c        2007-01-15 00:03:52.000000000 -0600
> +++ drivers-fixed/3c59x.c       2007-01-15 00:46:37.000000000 -0600
> @@ -3090,8 +3090,8 @@
>   /* Set Wake-On-LAN mode and put the board into D3 (power-down) state. */
>   static void acpi_set_WOL(struct net_device *dev)
>   {
> -       struct vortex_private *vp = netdev_priv(dev);
> -       void __iomem *ioaddr = vp->ioaddr;
> +  struct vortex_private *vp = netdev_priv(dev);
> +  void __iomem *ioaddr = vp->ioaddr;
> 
>          if (vp->enable_wol) {
>                  /* Power up on: 1==Downloaded Filter, 2==Magic Packets, 
> 4==Link Status. */
> @@ -3101,7 +3101,7 @@
>                  iowrite16(SetRxFilter|RxStation|RxMulticast|RxBroadcast, 
> ioaddr + EL3_CMD);
>                  iowrite16(RxEnable, ioaddr + EL3_CMD);
> 
> -               pci_enable_wake(VORTEX_PCI(vp), 0, 1);
> +               pci_enable_wake(VORTEX_PCI(vp),PCI_D3hot,1);
> 
>                  /* Change the power state to D3; RxEnable doesn't take 
> effect. */
>                  pci_set_power_state(VORTEX_PCI(vp), PCI_D3hot);
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

