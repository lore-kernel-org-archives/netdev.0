From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [RFC 02/10] IB/hfi-vnic: Virtual Network Interface Controller
 (VNIC) Bus driver
Date: Mon, 21 Nov 2016 16:31:18 -0700
Message-ID: <20161121233118.GA31132@obsidianresearch.com>
References: <1479508938-63799-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <1479508938-63799-3-git-send-email-niranjana.vishwanathapura@intel.com>
 <20161119190445.GG22775@obsidianresearch.com>
 <20161121213017.GB67872@knc-06.sc.intel.com>
 <20161121213930.GA30111@obsidianresearch.com>
 <20161121232629.GA67988@knc-06.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20161121232629.GA67988-wPcXA7LoDC+1XWohqUldA0EOCMrvLtNR@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 21, 2016 at 03:26:29PM -0800, Vishwanathapura, Niranjana wrote:
 
> I did not see any example IB mad agent outside drivers/inifiniband
> folder.

You can be the first.

> I did see some netdev drivers outside the net/ folder (like ipoib and
> drivers/infiniband/hw/nes/).

It is very rare, and arguably ipoib was a mistake..

> The hfi_vnic Ethernet driver is entirely a soft driver without any HW access.
> Also, any interface changes between hfi_vnic and the HFI driver makes it
> difficult to manage if they are under two subsystems/maintainers.

We manage this already for all the rocee drivers that are based on
netdev drivers, you will be fine.

> We have 'rdmavt' and 'soft-roce' drivers under drivers/infiniband/sw/ folder
> which are soft drivers similar to hfi_vnic. So we decided to put
> 'hif_vnic'

As I said those are HCA drivers & support, not just random 'software'.

> >>>>+	ida_init(&hfi_vnic_ctrl_ida);
> >>>>+	idr_init(&hfi_vnic_idr);
> >>>>+
> >>>>+	rc = bus_register(&hfi_vnic_bus);
> >>>
> >>>Why on earth do we need this? Didn't I give you enough grief for the
> >>>psm stuff and now you want to create an entire subystem hidden away!?
> >>>
> >>>Use some netlink scheme to control your vnic like the rest of the net
> >>>stack..
> >>>
> >>
> >>The hfi_vnic_bus is only abstracting the HW independent functionality (like
> >>Ethernet interface, encapsulation, IB MAD interface etc) with the HW
> >>dependent functionality (sending/receiving packets on the wire).
> >>Thus providing a cleaner interface between HW independent hfi_vnic Ethernet
> >>and Control drivers and the HW dependent HFI1 driver.
> >
> >That doesn't explain anything, sound like you don't need it so get rid
> >of it.

> >>There is no other User interface here other than the standard Ethernet
> >>interface through network stack.
> >
> >Good, then this isn't needed, because it doesn't provide a user interface.
> >
> 
> Can you explain what exactly you are asking to get rid of here and why?

Get rid of the bus_register/etc as drivers do not get to call this.

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
