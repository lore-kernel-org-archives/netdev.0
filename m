From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC 02/10] IB/hfi-vnic: Virtual Network Interface Controller
 (VNIC) Bus driver
Date: Wed, 30 Nov 2016 23:41:36 -0800
Message-ID: <20161201074136.GB110434@knc-06.sc.intel.com>
References: <20161121232629.GA67988@knc-06.sc.intel.com>
 <20161121233118.GA31132@obsidianresearch.com>
 <20161122015304.GB67988@knc-06.sc.intel.com>
 <20161122170407.GE3956@obsidianresearch.com>
 <20161123000502.GA27968@phlsvsds.ph.intel.com>
 <20161123004932.GA13598@obsidianresearch.com>
 <20161124000825.GA73280@knc-06.sc.intel.com>
 <20161124161545.GA20818@obsidianresearch.com>
 <20161129062938.GA84990@knc-06.sc.intel.com>
 <20161129162113.GC742@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: "ira.weiny" <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20161129162113.GC742-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 29, 2016 at 09:21:13AM -0700, Jason Gunthorpe wrote:
>On Mon, Nov 28, 2016 at 10:29:38PM -0800, Vishwanathapura, Niranjana wrote:
>> On Thu, Nov 24, 2016 at 09:15:45AM -0700, Jason Gunthorpe wrote:
>> >>And will move the hfi_vnic module under
>> >>???drivers/infiniband/ulp/hfi_vnic???.
>> >
>> >I would prefer drivers/net/ethernet
>> >
>> >This is clearly not a ULP since it doesn't use verbs.
>> >
>>
>> I understand it is not using verbs, but the control path (ib_device client)
>> is using verbs (IB MAD).
>> Our prefernce is to keep it somewhere under drivers/infiniband. Summarizing
>> reasons again here,
>>
>> - VNIC control driver (ib_device client) is an IB MAD agent.
>> - It is purly a software construct, encapsualtes ethernet packets in
>> Omni-path packet and depends on hfi1 driver here for HW access.
>
>Is the majority of the code MAD focused or net stack focused?
>
>I'm not sure it matters, it isn't like we can review Intel's
>proprietary mad stuff anyhow. :\
>
>Jason

That is an intersting measure. In hfi_vnic driver, I would say, >60% of the 
code is MAD focused, mainly interfacing with the IB MAD agent.
It also includes populating/parsing those MAD packets. At the least it is not 
supporting the driver to be put under net folder.

Even in the remaining <40%, half of it is involved with encapsulating ethernet 
frames with Omni-path header (does this makes it belong under 
drivers/infiniband/hw?).
The net stack interface part is pretty standard, hence is not much of code.

I do see the reason to put it under net folder, but I am seeing more reason for 
it to be somewhere under drivers/infiniband.

Niranjana

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
