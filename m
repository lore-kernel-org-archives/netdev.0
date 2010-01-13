From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: potential overflow in de4x5.c
Date: Tue, 12 Jan 2010 21:31:02 -0700
Message-ID: <20100113043101.GA29226@lackof.org>
References: <20100103101356.GA13023@bicker> <20100104072844.GB518@lackof.org> <20100104073514.GA987@lackof.org> <20100107154007.GE8134@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grant Grundler <grundler@parisc-linux.org>,
	Kyle McMartin <kyle@mcmartin.ca>, netdev@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from complete.lackof.org ([198.49.126.79]:39831 "EHLO
	complete.lackof.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750859Ab0AMEbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 23:31:04 -0500
Content-Disposition: inline
In-Reply-To: <20100107154007.GE8134@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 07, 2010 at 06:40:07PM +0300, Dan Carpenter wrote:
> > > > #define MOTO_SROM_BUG    (lp->active == 8 && (get_unaligned_le32(dev->dev_addr) & 0x00ffffff) == 0x3e0008)
...
> Basically the MOTO_SROM_BUG macro is asking:  Do we have an array overflow 
> and a hardware bug?  If so we had better do something about the hardware
> bug.  It sounds silly to me.

Hardware bug? A firmware bug I think.

I read the MOTO_SROM_BUG to be using both "active" and "dev_addr"
to be certain it was dealing with a broken SROM. And then fixing up
the "bork3d" values reported by the SROM (setting active to 0).

This still leaves open the question about when lp->active
could be >= DE4X5_MAX_MII. 


> > BTW, someone suggested to fix up this same bit of code before:
> >    http://www.mail-archive.com/netdev@vger.kernel.org/msg09838.html
> > 
> > And I'm not sure why that patch wasn't accepted then either. Patch looks fine to me.
> > 
> 
> Someone has updated the code since he posted the patch, presumably to fix
> the second overflow he mentioned.

*nod*

> 
> There is still another one left unfixed though which smatch misses.  
> 
>   5073          if ((j == limit) && (i < DE4X5_MAX_MII)) {
>   5074              for (k=0; k < DE4X5_MAX_PHY && lp->phy[k].id; k++);
>   5075              lp->phy[k].addr = i;
> 
> k could be == DE4X5_MAX_PHY on line 5075.

Yup. In theory at least. But can anyone point me at a DE4X5 device that
could have 7 or more phys attached to it?
I expect no more than three cases (thin_lan Coax, RJ45, MAU) but am
probably missing a few others - unlikely more than one or two more.

One unlikely but possible case: broken HW which reads ~0U (PCI Master Abort)
for phy[] values.

cheers,
grant
