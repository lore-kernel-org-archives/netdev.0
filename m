From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 3/3] NetXen: 64-bit memory fixes, driver cleanup
Date: Tue, 28 Nov 2006 10:40:32 -0800
Message-ID: <20061128104032.6d3121ac@freekitty>
References: <Pine.LNX.4.64.0611280733110.6776@dut39>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brazilnut@us.ibm.com, jeff@garzik.org,
	wendyx@us.ibm.com, sanjeev@netxen.com, rob@netxen.com,
	netxenproj@linsyssoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:19166 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S936032AbWK1TFq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Nov 2006 14:05:46 -0500
To: "Amit S. Kale" <amitkale@netxen.com>
In-Reply-To: <Pine.LNX.4.64.0611280733110.6776@dut39>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 28 Nov 2006 08:04:40 -0800 (PST)
"Amit S. Kale" <amitkale@netxen.com> wrote:

> Hi Stephen,
> 
> <SNIP>
> > > > you need explicit bounce buffers.  If you can't DMA from unaligned 
> address,
> > > > > the write a small routine to copy the skb to a new one.
> > > >
> > > >
> > > > The hardware supports DMA into 35 bit addresses. The intent is to
> > > > enable DMA into addresses upto 32G.
> > > >
> > >
> > > You should then set the same value for pci_set_dma_mask, because then 
> the IOMMU
> > > can help. See both b44 or tg3 drivers, they have to deal with odd size 
> masks.
> > > I don't think you have to do all the bounce buffer work in the driver.
> 
> Using bounce buffers has following tradeoffs:
> 1. Overhead of code maintenance.
> 2. Slow performance.
> Also on some ia64 machines we saw reduced performance because of larger 
> ring sizes.
> 
> But if we remove bounce buffers and use IOMMU instead, it might not 
> work for some Opteron configurations. On one of our Opterons we could not 
> set the IOMMU from kernel command line (it asked to set it from the BIOS where there was no 
> such option in the BIOS)
> 
> So what do you suggest, should we use the IOMMU or should we keep the 
> bounce buffers as they are?
> 
> Thanks,
> Amit Kale.


I don't mind workarounds, it is just that the problem is not unique to your driver
and we need a platform or general solution. There are lots of devices that stupid
hardware and need smaller masks.

-- 
Stephen Hemminger <shemminger@osdl.org>
