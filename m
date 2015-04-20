From: "ira.weiny" <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2 07/11] IB/cm: Add network namespace support
Date: Mon, 20 Apr 2015 19:35:21 -0400
Message-ID: <20150420233520.GC1409@phlsvsds.ph.intel.com>
References: <1429520622-10303-1-git-send-email-haggaie@mellanox.com> <1429520622-10303-8-git-send-email-haggaie@mellanox.com> <20150420170659.GD7676@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20150420170659.GD7676-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 20, 2015 at 11:06:59AM -0600, Jason Gunthorpe wrote:
> On Mon, Apr 20, 2015 at 12:03:38PM +0300, Haggai Eran wrote:
> > From: Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> > 
> > Add namespace support to the IB-CM layer.
> 
> > - Each CM-ID now has a network namespace it is associated with, assigned at
> >   creation. This namespace is used as needed during subsequent action on the
> >   CM-ID or related objects.
> 
> There is really something weird about this layering. At the CM layer
> there should be no concept of an IP address, it only deals with GIDs.
> 
> So how can a CM object have a network namespace associated with it?
> 
> >  {
> >  	av->port = port;
> >  	av->pkey_index = wc->pkey_index;
> >  	ib_init_ah_from_wc(port->cm_dev->ib_device, port->port_num, wc,
> > -			   grh, &av->ah_attr, &init_net);
> > +			   grh, &av->ah_attr, net);
> 
> There is something deeply wrong with adding network namespace
> arguments to verbs.
> 
> For rocee the gid index clearly specifies the network namespace
> to use, so much of this should go away and have rocee get the
> namespace from the gid index.
> 
> Ie in ib_init_ah_from_wc we have the ib_wc which contains the sgid
> index.
> 
> I'm really not excited at how many places are gaining a net when those
> layers shouldn't even need to care about IP layer details. Just acting
> as a pass through for rocee doesn't make sense.
> 

I had the same feeling when I saw the addition of the network namespace to the
MAD code, especially the RMPP code.

It seems like there should be a better way to deal with this.  My gut says that
the namespace should be handled separate from the ib_init_ah_from_wc.  Perhaps
as a secondary call used only when the namespace is needed?  But I'm not sure
when it is appropriate/needed.

Ira

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
