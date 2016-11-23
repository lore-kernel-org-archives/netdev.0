From: "ira.weiny" <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC 02/10] IB/hfi-vnic: Virtual Network Interface Controller (VNIC) Bus driver
Date: Tue, 22 Nov 2016 19:05:05 -0500
Message-ID: <20161123000502.GA27968@phlsvsds.ph.intel.com>
References: <1479508938-63799-1-git-send-email-niranjana.vishwanathapura@intel.com> <1479508938-63799-3-git-send-email-niranjana.vishwanathapura@intel.com> <20161119190445.GG22775@obsidianresearch.com> <20161121213017.GB67872@knc-06.sc.intel.com> <20161121213930.GA30111@obsidianresearch.com> <20161121232629.GA67988@knc-06.sc.intel.com> <20161121233118.GA31132@obsidianresearch.com> <20161122015304.GB67988@knc-06.sc.intel.com> <20161122170407.GE3956@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20161122170407.GE3956-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 22, 2016 at 10:04:07AM -0700, Jason Gunthorpe wrote:
> On Mon, Nov 21, 2016 at 05:53:04PM -0800, Vishwanathapura, Niranjana wrote:
> > There are many example drivers in kernel which are using bus_register() in
> > an initcall.
> 
> There really are not, certainly not in major subsystems.

I see 2 drivers in the Block subsystem which do this:


19   5354  /nfs/site/home/iweiny/linux-stable/drivers/block/cciss.c <<cciss_init>>
	err = bus_register(&cciss_bus_type);
20   6447 /nfs/site/home/iweiny/linux-stable/drivers/block/rbd.c <<rbd_sysfs_init>>
	ret = bus_register(&rbd_bus_type);

2 drivers in the drm subsystem which do this:


29   1155  /nfs/site/home/iweiny/linux-stable/drivers/gpu/drm/drm_mipi_dsi.c <<mipi_dsi_bus_init>>
	return bus_register(&mipi_dsi_bus_type);
30    242 /nfs/site/home/iweiny/linux-stable/drivers/gpu/host1x/dev.c <<tegra_host1x_init>>
	err = bus_register(&host1x_bus_type);

And I think there are a couple others.

I'm not sure what these devices/buses do but they are registering their own bus
while being in another major subsystem.  Is what we are doing really so
crazy/wrong?


>
> > We could add a custom Interface between HFI1 driver and hfi_vnic drivers
> > without involving a bus.
> 
> hfi is already registering on the infiniband class, just use that.
> 

I don't understand what you mean here?

The bus_register provides a really clean way for the hfi1 driver and hfi_vnic
driver to find each other.  This includes being able to support hfi1 with or
without hfi_vnic being loaded.  Note that without configuration from the "EM"
Ethernet Manager the hfi_vnic does not export a net device.

Why wouldn't we use this core kernel support?[*]

> > But using the existing bus model gave a lot of in-built flexibility in
> > decoupling devices from the drivers.
> 
> If you want to have your own bus then you need your own hfi
> subsystem. drivers/infiniband is not a dumping ground..
> 

We don't consider drivers/infiniband a "dumping ground".  There is a
requirement on ib_mad from the hfi_vnic driver.

Ira

[*] As an aside why does the ib_core not use this methodology?  It dawned on
me that this may be a better way to fix our module load problems.  However, I
have not looked into details.

> Jason
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
