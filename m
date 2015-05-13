From: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: [PATCH v3 for-next 00/13] Add network namespace support in the
 RDMA-CM
Date: Wed, 13 May 2015 17:30:01 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A82373A8FDA1AB@ORSMSX109.amr.corp.intel.com>
References: <1431253604-9214-1-git-send-email-haggaie@mellanox.com>
 <1828884A29C6694DAF28B7E6B8A82373A8FD7B85@ORSMSX109.amr.corp.intel.com>
 <55531073.1000305@mellanox.com>
 <1828884A29C6694DAF28B7E6B8A82373A8FDA13B@ORSMSX109.amr.corp.intel.com>
 <20150513171823.GB20343@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150513171823.GB20343-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> > > > How does network namespace support work with iWarp?
> > >
> > > We did not implement network namespace support for iWarp. Only for
> > > InfiniBand. The iWarp code continues to use &init_net whenever a
> network
> > > namespace is needed, as it does today.
> >
> > We need a solution that supports both.  It's odd for the RDMA CM to
> > support a feature only for some devices, when the solution should be
> > general.
> 
> Yes, it is not optimal, but given that every protocol uses a
> completely different scheme to interact with netdev, I'm not sure
> there is another option but to do them piecemeal?

Piecemeal isn't necessarily the problem.  No thought appears to have been given to how this scheme supports iWarp at all.  My concern is around whether any changes should be made to the ib_cm, versus keeping everything contained in the rdma_cm.  I.e. do we want the same kref schemed added to the iw_cm, or keep reference counts only in the rdma_cm?

> I'm happy to see this patch much smaller and without the vestigial
> half-roce support that the prior version included.

agreed

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
