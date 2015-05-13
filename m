From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH v3 for-next 00/13] Add network namespace support in the
 RDMA-CM
Date: Wed, 13 May 2015 11:18:23 -0600
Message-ID: <20150513171823.GB20343@obsidianresearch.com>
References: <1431253604-9214-1-git-send-email-haggaie@mellanox.com>
 <1828884A29C6694DAF28B7E6B8A82373A8FD7B85@ORSMSX109.amr.corp.intel.com>
 <55531073.1000305@mellanox.com>
 <1828884A29C6694DAF28B7E6B8A82373A8FDA13B@ORSMSX109.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1828884A29C6694DAF28B7E6B8A82373A8FDA13B-P5GAC/sN6hkd3b2yrw5b5LfspsVTdybXVpNB7YpNyf8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, May 13, 2015 at 04:45:59PM +0000, Hefty, Sean wrote:
> > > How does network namespace support work with iWarp?
> > 
> > We did not implement network namespace support for iWarp. Only for
> > InfiniBand. The iWarp code continues to use &init_net whenever a network
> > namespace is needed, as it does today.
> 
> We need a solution that supports both.  It's odd for the RDMA CM to
> support a feature only for some devices, when the solution should be
> general.

Yes, it is not optimal, but given that every protocol uses a
completely different scheme to interact with netdev, I'm not sure
there is another option but to do them piecemeal?

I'm happy to see this patch much smaller and without the vestigial
half-roce support that the prior version included.

This should be a good starting point for someone to do iWarp, it is
pretty simple since there is no UD component. roce will be much
harder, I think.

Should we inhibit the RDMA uapi on non-init namespaces? At least
that way iWarp/etc won't work at all, instead of leaking through the
container.

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
