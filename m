From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC 02/10] IB/hfi-vnic: Virtual Network Interface Controller
 (VNIC) Bus driver
Date: Thu, 24 Nov 2016 18:13:50 -0800
Message-ID: <20161125021350.GA74946@knc-06.sc.intel.com>
References: <20161121213017.GB67872@knc-06.sc.intel.com>
 <20161121213930.GA30111@obsidianresearch.com>
 <20161121232629.GA67988@knc-06.sc.intel.com>
 <20161121233118.GA31132@obsidianresearch.com>
 <20161122015304.GB67988@knc-06.sc.intel.com>
 <20161122170407.GE3956@obsidianresearch.com>
 <20161123000502.GA27968@phlsvsds.ph.intel.com>
 <20161123004932.GA13598@obsidianresearch.com>
 <20161124000825.GA73280@knc-06.sc.intel.com>
 <20161124161545.GA20818@obsidianresearch.com>
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
In-Reply-To: <20161124161545.GA20818-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 24, 2016 at 09:15:45AM -0700, Jason Gunthorpe wrote:
>On Wed, Nov 23, 2016 at 04:08:25PM -0800, Vishwanathapura, Niranjana wrote:
>
>> In order to pass the hfi function pointers to the hfi_vnic ULP, I can,
>> a) Have hfi_vnic ULP define an interface API for hfi1 driver to call to
>> register its callback (as you pointed). Unfortunately there will be a module
>> dependency here.
>> Or,
>
>That is probably backwards
>
>> b) Add a new member ‘struct vnic_ops’ either to the ib_device structure or
>> ib_port_immutable structure. As it is hfi1 specific, only hfi1 driver will
>> set it. No module dependency here.
>
>You can add a hfi1_get_vnic_ops(struct ib_device *) and implement it
>in your module..
>

In order to be truely device independent the hfi_vnic ULP should not depend on 
a device exported symbol. Instead device should register its functions with the 
ULP. Hence the approaches a) and b).

Niranjana

>Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
