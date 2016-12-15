From: "ira.weiny" <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC v2 00/10] HFI Virtual Network Interface Controller (VNIC)
Date: Thu, 15 Dec 2016 09:52:13 -0500
Message-ID: <20161215145212.GA29116@phlsvsds.ph.intel.com>
References: <1481788782-89964-1-git-send-email-niranjana.vishwanathapura@intel.com> <20161215091226.GC811@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20161215091226.GC811-U/DQcQFIOTAAJjI8aNfphQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 15, 2016 at 11:12:26AM +0200, Leon Romanovsky wrote:
> On Wed, Dec 14, 2016 at 11:59:32PM -0800, Vishwanathapura, Niranjana wrote:
> > Thanks Jason for the valuable feedback.
> > Here is the revised HFI VNIC patch series.
> >
> > ChangeLog:
> > =========
> > v1 => v2:
> > a) Removed hfi_vnic bus, instead make hfi_vnic driver an 'ib client',
> >    as per feedback from Jason Gunthorpe.
> > b) Interface changes, data structure changes and variable name changes
> >    associated with (a).
> > c) Add hfi_ibdev abstraction to provide VNIC control operations to
> >    hfi_vnic client.
> > d) Minor fixes
> > e) Moved hfi_vnic driver from .../sw/intel/vnic/hfi_vnic to
> >    .../sw/intel/hfi_vnic.
> 
> To put it into proportion, Jason asked you to do different thing.
> http://marc.info/?l=linux-rdma&m=147977108302151&w=2
> http://marc.info/?l=linux-rdma&m=148000415401842&w=2
> 
> And Christoph,
> http://marc.info/?l=linux-rdma&m=147985587425861&w=2

Understood.  However, we never heard back from Niranjanas analysis of the code
which stated that > 60% of the code was dealing with the OPA MADs used to
configure this device.

https://www.spinics.net/lists/linux-rdma/msg43579.html

Furthermore, neither Dave nor Doug has had time to weigh in on what we should
do.

So before we make that change we wanted to get consensus on using the
hfi1_ibdev abstraction rather than the bus.  This was the _real_ technical
change.

Beyond that it is really just which maintainer wants this driver.  To that end
I've also cc'ed Jeff Kirsher who maintains drivers/net/ethernet/intel.  Perhaps
Dave would like the driver to go through that tree?


I think there are pros and cons to both subtrees and in the end we will do
whatever is decided.

For maintainer review:

	1) The driver encapsulates ethernet packets with OPA headers

	2) VNIC uses OPA management packets (MADs) for its configuration

	3) A significant portion (> 60% +) of the code is specific to OPA

		https://www.spinics.net/lists/linux-rdma/msg43579.html

	4) The driver is from Intel and we expect Intel to be the primary
	   contributor to the code.

	5) The driver, like hfi1, is dual licensed (GPL/BSD)

	6) Based on Christophs feedback we will be adding device capability
	   bits to the IB core to indicate HFI VNIC support.

		https://www.spinics.net/lists/linux-rdma/msg44113.html


Doug, Dave, Jeff any thoughts?

Ira

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
