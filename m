From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC 02/10] IB/hfi-vnic: Virtual Network Interface Controller
 (VNIC) Bus driver
Date: Wed, 30 Nov 2016 23:39:25 -0800
Message-ID: <20161201073925.GA110434@knc-06.sc.intel.com>
References: <20161123000502.GA27968@phlsvsds.ph.intel.com>
 <20161123004932.GA13598@obsidianresearch.com>
 <20161124000825.GA73280@knc-06.sc.intel.com>
 <20161124161545.GA20818@obsidianresearch.com>
 <20161125021350.GA74946@knc-06.sc.intel.com>
 <20161125190509.GB16504@obsidianresearch.com>
 <20161129063106.GB84990@knc-06.sc.intel.com>
 <20161129161950.GB742@obsidianresearch.com>
 <1828884A29C6694DAF28B7E6B8A82373AB0B9B46@ORSMSX109.amr.corp.intel.com>
 <20161129165009.GA3167@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "Weiny, Ira" <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "Dalessandro, Dennis" <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20161129165009.GA3167-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 29, 2016 at 09:50:09AM -0700, Jason Gunthorpe wrote:
>On Tue, Nov 29, 2016 at 04:44:37PM +0000, Hefty, Sean wrote:
>> > You are not making a subsystem. Don't overcomplicate things. A
>> > multi-part device device can just directly link.
>>
>> The VNIC may be usable over multiple generations of HFIs, but I
>> don't know if that is the intent.
>
>If Intel wants to build a HFI subystem within RDMA with multiple
>drivers then sure, but they are not there yet, and we don't even know
>what that could look like. So it is better to leave it simple for now.
>
>Jason

Sorry for the delay, I was weighing in couple options.
We envisioned vnic as a pure software construct and hence should be independent 
(like ipoib). ie., both hfi_vnic and hfi1 should be independently loadable 
(like ipoib) despite hfi_vnic being dependent on hfi1 here for HW access.

There doesn't seem to be much value of hfi_vnic being a 'ib client', if it 
still has compilation and module dependency on hfi1 module.

The more I think of it, having vnic ops added to ib device structure (option 
(b)) makes it cleaner (no dependency). We can probably consider extending 'ib 
device' in hfi1 in order for hfi_vnic to get to the vnic ops. But (b) makes it 
simpler.

Though Jason's suggestion could be a temporary measure for this patch series, 
the above approach is what I would like to target here.

Niranjana

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
