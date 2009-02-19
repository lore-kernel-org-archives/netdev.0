From: Ira Snyder <iws@ovro.caltech.edu>
Subject: Re: [RFC v1] virtio: add virtio-over-PCI driver
Date: Thu, 19 Feb 2009 08:14:38 -0800
Message-ID: <20090219161438.GA12795@ovro.caltech.edu>
References: <20090217222425.GA18801@ovro.caltech.edu> <7DF0AF56456B8F4081E3C44CCCE311DE15199F@zch01exm23.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>,
	Arnd Bergmann <arnd@arndb.de>,
	Jan-Bernd Themann <THEMANN@de.ibm.com>
To: Zang Roy-R61911 <tie-fei.zang@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ovro.ovro.caltech.edu ([192.100.16.2]:41389 "EHLO
	ovro.ovro.caltech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752198AbZBSQOk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2009 11:14:40 -0500
Content-Disposition: inline
In-Reply-To: <7DF0AF56456B8F4081E3C44CCCE311DE15199F@zch01exm23.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 19, 2009 at 02:10:08PM +0800, Zang Roy-R61911 wrote:
>  
> 
> > -----Original Message-----
> > From: 
> > linuxppc-dev-bounces+tie-fei.zang=freescale.com@ozlabs.org 
> > [mailto:linuxppc-dev-bounces+tie-fei.zang=freescale.com@ozlabs
> > .org] On Behalf Of Ira Snyder
> > Sent: Wednesday, February 18, 2009 6:24 AM
> > To: linux-kernel@vger.kernel.org
> > Cc: linuxppc-dev@ozlabs.org; netdev@vger.kernel.org; Rusty 
> > Russell; Arnd Bergmann; Jan-Bernd Themann
> > Subject: [RFC v1] virtio: add virtio-over-PCI driver
> snip
> > diff --git a/drivers/virtio/Kconfig b/drivers/virtio/Kconfig
> > index 3dd6294..efcf56b 100644
> > --- a/drivers/virtio/Kconfig
> > +++ b/drivers/virtio/Kconfig
> > @@ -33,3 +33,25 @@ config VIRTIO_BALLOON
> >  
> >  	 If unsure, say M.
> >  
> > +config VIRTIO_OVER_PCI_HOST
> > +	tristate "Virtio-over-PCI Host support (EXPERIMENTAL)"
> > +	depends on PCI && EXPERIMENTAL
> > +	select VIRTIO
> > +	---help---
> > +	  This driver provides the host support necessary for 
> > using virtio
> > +	  over the PCI bus with a Freescale MPC8349EMDS 
> > evaluation board.
> > +
> > +	  If unsure, say N.
> > +
> > +config VIRTIO_OVER_PCI_FSL
> > +	tristate "Virtio-over-PCI Guest support (EXPERIMENTAL)"
> > +	depends on MPC834x_MDS && EXPERIMENTAL
> > +	select VIRTIO
> > +	select DMA_ENGINE
> > +	select FSL_DMA
> > +	---help---
> > +	  This driver provides the guest support necessary for 
> > using virtio
> > +	  over the PCI bus.
> > +
> > +	  If unsure, say N.
> > +
> > diff --git a/drivers/virtio/Makefile b/drivers/virtio/Makefile
> > index 6738c44..f31afaa 100644
> > --- a/drivers/virtio/Makefile
> > +++ b/drivers/virtio/Makefile
> > @@ -2,3 +2,5 @@ obj-$(CONFIG_VIRTIO) += virtio.o
> >  obj-$(CONFIG_VIRTIO_RING) += virtio_ring.o
> >  obj-$(CONFIG_VIRTIO_PCI) += virtio_pci.o
> >  obj-$(CONFIG_VIRTIO_BALLOON) += virtio_balloon.o
> > +obj-$(CONFIG_VIRTIO_OVER_PCI_HOST) += vop_host.o
> > +obj-$(CONFIG_VIRTIO_OVER_PCI_FSL) += vop_fsl.o
> I suppose we  need to build the kernel twice. one for vop_host  (on host
> with pci enabled) and the
> other is for vop_fsl ( on agent with pci disabled). Is it possible to
> build one image for both host and 
> agent.  We do not scan the pci bus if the controller is configured to
> agent.
> 

You should be able to build a kernel with support for both host and
guest operation, and then use the device tree to switch which driver you
get. The host driver won't be used without a PCI bus, and the guest
driver won't be used without the message unit.

> Also, is it possible to include mpc85xx architecture? They should be
> same.
> There is some code for 85xx in Fresscale BSP.
> http://www.bitshrine.org/gpp/linux-fsl-2.6.23-MPC8568MDS_PCI_Agent_PCIe_
> EP_Drvier.patch

I looked at the cardnet driver before I implemented my PCINet driver. I
hunch it would be rejected for the same reasons, but maybe not. Also, it
makes no use of DMA, which is critical for good transfer speed. Using
memcpy() in PCINet gives performance around 10 mbit/sec, which is
terrible.

I'm sure the driver isn't very hard to port to 85xx, I just don't have
any 85xx boards to test with. The driver only directly interacts with
the messaging unit, which is a pretty simple piece of hardware.

Thanks,
Ira
