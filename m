From: Tom Talpey <tom-CLs1Zie5N5HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2 01/17] IB/Verbs: Implement new callback query_transport()
 for each HW
Date: Fri, 10 Apr 2015 20:01:26 -0400
Message-ID: <55286456.8060805@talpey.com>
References: <5523CCD5.6030401@profitbricks.com> <5523D098.3020007@profitbricks.com> <1428517786.2980.180.camel@redhat.com> <20150408201015.GB28666@obsidianresearch.com> <20150410061610.GA26288@phlsvsds.ph.intel.com> <20150410161551.GA26419@obsidianresearch.com> <20150410173836.GE10675@phlsvsds.ph.intel.com> <20150410180455.GA1277@obsidianresearch.com> <1428690266.2980.381.camel@redhat.com> <20150410191723.GC1277@obsidianresearch.com> <20150410210639.GB19907@phlsvsds.ph.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Tom Tucker <tom-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	Hoang-Nam Nguyen <hnguyen-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Christoph Raisch <raisch-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Mike Marciniszyn <infinipath-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Upinder Malhi <umalhi-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	PJ Waskiewicz <pj.waskiewicz-PrFOU5CTvK1l57MIdRCFDg@public.gmane.org>,
	Tatyana Nikolova <Tatyana.E.Nikolova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jack Morg
To: "ira.weiny" <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150410210639.GB19907-W4f6Xiosr+yv7QzWx2u06xL4W9x8LtSr@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 4/10/2015 5:06 PM, ira.weiny wrote:
> On Fri, Apr 10, 2015 at 01:17:23PM -0600, Jason Gunthorpe wrote:
>...
> So trying to sum up.
>
> Have we settled on the following "capabilities"?  Helper function names aside.
>
> /* legacy to communicate to userspace */
> RDMA_LINK_LAYER_IB       = 0x0000000000000001,
> RDMA_LINK_LAYER_ETH      = 0x0000000000000002,
> RDMA_LINK_LAYER_MASK     = 0x000000000000000f, /* more bits? */
> 	/* I'm hoping we don't need more bits here */
>
>
> /* legacy to communicate to userspace */
> RDMA_TRANSPORT_IB        = 0x0000000000000010,
> RDMA_TRANSPORT_IWARP     = 0x0000000000000020,
> RDMA_TRANSPORT_USNIC     = 0x0000000000000040,
> RDMA_TRANSPORT_USNIC_UDP = 0x0000000000000080,
> RDMA_TRANSPORT_MASK      = 0x00000000000000f0, /* more bits? */
> 	/* I'm hoping we don't need more bits here */
>
>
> /* New flags */
>
> RDMA_MGMT_IB_MAD         = 0x0000000000000100, /* ib_mad module support */
> RDMA_MGMT_QP0            = 0x0000000000000200, /* ib_mad QP0 support */
> RDMA_MGMT_IB_SA          = 0x0000000000000400, /* ib_sa module support */
> 					       /* NOTE includes IB Mcast */
> RDMA_MGMT_IB_CM          = 0x0000000000000800, /* ib_cm module support */
> RDMA_MGMT_OPA_MAD        = 0x0000000000001000, /* ib_mad OPA MAD support */
> RDMA_MGMT_MASK           = 0x00000000000fff00,

You explicitly say "userspace" - why would an upper layer need to
know the link, transport and management details? These seem to be
mid-layer matters.

> RDMA_ADDR_IB             = 0x0000000000100000, /* Port does IB AH, PR, Pkey */
> RDMA_ADDR_IBoE           = 0x0000000000200000, /* Port does IBoE AH, PR, Pkey */
> /* Do we need iWarp (TCP) here? */
> RDMA_ADDR_IB_MASK        = 0x000000000ff00000,

I do see a ULP needing to know the address family needed to pass to
rdma_connect and rdma_listen, so I would add "IP", but not "iWARP".

> RDMA_SEPARATE_READ_SGE   = 0x0000000010000000,
> RDMA_QUIRKS_MASK         = 0x000000fff0000000

This is good, but it also needs an attribute to signal the need for a
remote-writable RDMA Read sink buffer, for today's iWARP.

Tom.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
