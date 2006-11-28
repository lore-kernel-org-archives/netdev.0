From: "Amit S. Kale" <amitkale@netxen.com>
Subject: RE: Re: [PATCH 3/3] NetXen: 64-bit memory fixes, driver cleanup
Date: Tue, 28 Nov 2006 08:04:40 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0611280733110.6776@dut39>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org, brazilnut@us.ibm.com, jeff@garzik.org,
	wendyx@us.ibm.com, sanjeev@netxen.com, rob@netxen.com,
	netxenproj@linsyssoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:58690 "EHLO
	nxmail.netxen.com") by vger.kernel.org with ESMTP id S935691AbWK1QEq
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Nov 2006 11:04:46 -0500
To: shemminger@osdl.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

<SNIP>
> > > you need explicit bounce buffers.  If you can't DMA from unaligned 
address,
> > > > the write a small routine to copy the skb to a new one.
> > >
> > >
> > > The hardware supports DMA into 35 bit addresses. The intent is to
> > > enable DMA into addresses upto 32G.
> > >
> >
> > You should then set the same value for pci_set_dma_mask, because then 
the IOMMU
> > can help. See both b44 or tg3 drivers, they have to deal with odd size 
masks.
> > I don't think you have to do all the bounce buffer work in the driver.

Using bounce buffers has following tradeoffs:
1. Overhead of code maintenance.
2. Slow performance.
Also on some ia64 machines we saw reduced performance because of larger 
ring sizes.

But if we remove bounce buffers and use IOMMU instead, it might not 
work for some Opteron configurations. On one of our Opterons we could not 
set the IOMMU from kernel command line (it asked to set it from the BIOS where there was no 
such option in the BIOS)

So what do you suggest, should we use the IOMMU or should we keep the 
bounce buffers as they are?

Thanks,
Amit Kale.


