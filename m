From: "Steve Wise" <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Subject: RE: [PATCH v2 10/17] IB/Verbs: Adopt management helpers for IB helpers
Date: Tue, 7 Apr 2015 15:16:30 -0500
Message-ID: <008401d0716f$bc41c5c0$34c55140$@opengridcomputing.com>
References: <5523CCD5.6030401@profitbricks.com> <5523CF0A.5090206@profitbricks.com> <20150407201259.GA17147@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Roland Dreier'" <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"'Sean Hefty'" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"'Hal Rosenstock'" <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"'Tom Tucker'" <tom-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	"'Hoang-Nam Nguyen'" <hnguyen-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	"'Christoph Raisch'" <raisch-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	"'Mike Marciniszyn'" <infinipath-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"'Eli Cohen'" <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"'Faisal Latif'" <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"'Upinder Malhi'" <umalhi-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>,
	"'Trond Myklebust'" <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	"'J. Bruce Fields'" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"'David S. Miller'" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"'Ira Weiny'" <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"'PJ Waskiewicz'" <pj.waskiewicz-PrFOU5CTvK1l57MIdRCFDg@public.gmane.org>,
	"'Tatyana Nikolova'" <Tatyana.E.Nikolova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"'Or Gerlitz'" <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"'Jack Morgenstein'" <jac
To: "'Jason Gunthorpe'" <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
	"'Michael Wang'" <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150407201259.GA17147-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Content-Language: en-us
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Jason Gunthorpe [mailto:jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org]
> Sent: Tuesday, April 07, 2015 3:13 PM
> To: Michael Wang
> Cc: Roland Dreier; Sean Hefty; linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
> netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Hal Rosenstock; Tom Tucker; Steve Wise; Hoang-Nam Nguyen; Christoph Raisch; Mike Marciniszyn; Eli Cohen;
> Faisal Latif; Upinder Malhi; Trond Myklebust; J. Bruce Fields; David S. Miller; Ira Weiny; PJ Waskiewicz; Tatyana Nikolova; Or
Gerlitz; Jack
> Morgenstein; Haggai Eran; Ilya Nelkenbaum; Yann Droneaud; Bart Van Assche; Shachar Raindel; Sagi Grimberg; Devesh Sharma; Matan
> Barak; Moni Shoua; Jiri Kosina; Selvin Xavier; Mitesh Ahuja; Li RongQing; Rasmus Villemoes; Alex Estrin; Doug Ledford; Eric
Dumazet; Erez
> Shitrit; Tom Gundersen; Chuck Lever
> Subject: Re: [PATCH v2 10/17] IB/Verbs: Adopt management helpers for IB helpers
> 
> On Tue, Apr 07, 2015 at 02:35:22PM +0200, Michael Wang wrote:
> > index f704254..4e61104 100644
> > +++ b/drivers/infiniband/core/sa_query.c
> > @@ -540,7 +540,7 @@ int ib_init_ah_from_path(struct ib_device *device, u8 port_num,
> >  	ah_attr->port_num = port_num;
> >  	ah_attr->static_rate = rec->rate;
> >
> > -	force_grh = rdma_port_get_link_layer(device, port_num) == IB_LINK_LAYER_ETHERNET;
> > +	force_grh = !rdma_transport_ib(device, port_num);
> 
> Maybe these tests should be called cap_mandatory_grh - but I'm not
> really sure how iWarp uses the GRH fields in the AH...
> 

iWARP runs on top of TCP...this SA code is all IB-specific.  The reason it was checking for ETHERNET, I think, is for RoCE.    So
this change is totally incorrect,  I think,  because RoCE is an IB transport, but it runs on ETHERNET.

Steve.



--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
