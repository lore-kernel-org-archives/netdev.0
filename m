From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC 02/10] IB/hfi-vnic: Virtual Network Interface Controller
 (VNIC) Bus driver
Date: Wed, 23 Nov 2016 16:08:25 -0800
Message-ID: <20161124000825.GA73280@knc-06.sc.intel.com>
References: <1479508938-63799-3-git-send-email-niranjana.vishwanathapura@intel.com>
 <20161119190445.GG22775@obsidianresearch.com>
 <20161121213017.GB67872@knc-06.sc.intel.com>
 <20161121213930.GA30111@obsidianresearch.com>
 <20161121232629.GA67988@knc-06.sc.intel.com>
 <20161121233118.GA31132@obsidianresearch.com>
 <20161122015304.GB67988@knc-06.sc.intel.com>
 <20161122170407.GE3956@obsidianresearch.com>
 <20161123000502.GA27968@phlsvsds.ph.intel.com>
 <20161123004932.GA13598@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: "ira.weiny" <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20161123004932.GA13598-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 22, 2016 at 05:49:32PM -0700, Jason Gunthorpe wrote:
>> > > We could add a custom Interface between HFI1 driver and hfi_vnic drivers
>> > > without involving a bus.
>> >
>> > hfi is already registering on the infiniband class, just use that.
>>
>> I don't understand what you mean here?
>
>Get the struct ib_device for the hfi and then do something to get hfi
>specific function calls.
>
>Or work it backwards with a _register function..
>

OK, thanks for your feedback.
We can make the hfi_vnic module as an ib client (which it is) like other ULPs, 
and do not have an in-built or custom bus for binding.
Then the hfi_vnic ULP by some mechanism will identify the device as hfi1 device 
and will only serve that device.

In order to pass the hfi function pointers to the hfi_vnic ULP, I can,
a) Have hfi_vnic ULP define an interface API for hfi1 driver to call to 
register its callback (as you pointed). Unfortunately there will be a module 
dependency here.
Or,
b) Add a new member ‘struct vnic_ops’ either to the ib_device structure or 
ib_port_immutable structure. As it is hfi1 specific, only hfi1 driver will set 
it. No module dependency here.

And will move the hfi_vnic module under ‘drivers/infiniband/ulp/hfi_vnic’.
All these will remove undue complexity and fit the driver in current design 
framework as per your suggestion.
Let me know your comments.

Niranjana

>
>Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
