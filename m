From: Samuel Ortiz <sameo@linux.intel.com>
Subject: Re: [PATCH 1/3] mfd: add support for Janz CMOD-IO PCI MODULbus
 Carrier Board
Date: Fri, 26 Mar 2010 01:26:30 +0100
Message-ID: <20100326002629.GA31389@sortiz.org>
References: <>
 <1268930324-29841-2-git-send-email-iws@ovro.caltech.edu>
 <20100319163849.GB30409@sortiz.org>
 <20100319182209.GD13672@ovro.caltech.edu>
 <20100325225929.GA20618@sortiz.org>
 <20100325232244.GG10454@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	socketcan-core@lists.berlios.de
To: "Ira W. Snyder" <iws@ovro.caltech.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100325232244.GG10454@ovro.caltech.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 25, 2010 at 04:22:44PM -0700, Ira W. Snyder wrote:
> On Thu, Mar 25, 2010 at 11:59:30PM +0100, Samuel Ortiz wrote:
> > Hi Ira,
> > 
> > First of all, sorry for the late reply. Then my answers:
> > 
> > On Fri, Mar 19, 2010 at 11:22:09AM -0700, Ira W. Snyder wrote:
> > > 
> > > > > +/*
> > > > > + * Subdevice Support
> > > > > + */
> > > > Please use the mfd-core API for building and registering platform sub devices.
> > > > The pieces of code below should shrink significantly.
> > > > 
> > > 
> > > Using this framework, how is it possible to create  the devices that I
> > > do down below. For each subdevice, I need three resources:
> > > 
> > > 1) MODULbus registers -- PCI BAR3 + (0x200 * module_num)
> > > 2) PLX Control Registers -- PCI BAR4
> > > 3) IRQ
> > > 
> > > Specifically, the way IORESOURCE_MEM resources are copied seems wrong.
> > > They start at the base address of only one resource and use the offsets
> > > provided in the struct mfd_cell. See the if-statement at
> > > drivers/mfd/mfd-core.c line 48.
> > > 
> > > I need two use two different parent resources. The mfd_add_devices()
> > > function doesn't support this.
> > I would still like you to use the mfd-core API. Here is my proposal:
> > 
> > 1) I modify mfd_add_device() to support a NULL mem_base argument. When
> > mem_base is NULL, we would have:
> > 
> > res[r].parent = NULL and res[r].start = cell->resources[r].start;
> > 
> > The platform code will use iomem_resource as the parent for this resource.
> > 
> 
> I don't know the implications of using iomem_resource as the parent
> resource. If you think it is ok, I have no objections.
> 
> If it helps, I can provide the PCI resource as a parent resource in my
> resources. Then, when mem_base is NULL, the mfd-core could do this:
> 
> res[r].parent = cell->resources[r].parent
> 
> This is basically what I did in my patch. I used the PCI resource as the
> parent of all child resources. I don't know if that is safe, but it
> works. :)
> 
> The mfd_add_device() function does this for IORESOURCE_IO resources. It
> only tries to be smart for IORESOURCE_MEM and IORESOURCE_IRQ resources.
I pushed an mfd-core change that basically falls back to the default resource
copying when mem_base is NULL. That should allow you to use the API now.

> > > > > +#define PCI_VENDOR_ID_JANZ		0x13c3
> > > > That probably belongs to pci_ids.h
> > > > 
> > > 
> > > Should I add a patch to the series for this?
> > Either that or merge the pci_ids.h changes with this patch.
> > 
> 
> I guess it is a trivial enough change to merge with this patch.
> 
> I'll wait for your patch to the mfd-core API before making changes and
> sending out the next round of updates.
Very nice. The above mentioned change in my for-next branch, commit
6802a325f541bbea3168cf61ba239443193e1f9a.

Cheers,
Samuel.

-- 
Intel Open Source Technology Centre
http://oss.intel.com/
