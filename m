From: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: [PATCH v3 for-next 05/13] IB/cm: Reference count ib_cm_ids
Date: Wed, 20 May 2015 00:49:44 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A82373A8FDD565@ORSMSX109.amr.corp.intel.com>
References: <1431253604-9214-1-git-send-email-haggaie@mellanox.com>
 <1431253604-9214-6-git-send-email-haggaie@mellanox.com>
 <20150511183459.GB25405@obsidianresearch.com>
 <5551A2CB.1010407@mellanox.com> <20150512185447.GA3503@obsidianresearch.com>
 <55532566.9040105@mellanox.com>
 <20150513165823.GA20343@obsidianresearch.com>
 <1828884A29C6694DAF28B7E6B8A82373A8FDC0C3@ORSMSX109.amr.corp.intel.com>
 <20150519192353.GA23612@obsidianresearch.com>
 <1828884A29C6694DAF28B7E6B8A82373A8FDD412@ORSMSX109.amr.corp.intel.com>
 <20150519234654.GA26634@obsidianresearch.com>
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
In-Reply-To: <20150519234654.GA26634-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> > I wonder if the existing ib_cm interface is even what we want.
> > Currently, the rdma_cm pushes the private data (i.e. IP address)
> > comparison into the ib_cm.  This is only used by the rdma_cm.
> > Should that instead be moved out of the ib_cm and handled in the
> > rdma_cm?  And then update the ib_cm to support multiple listens on
> > the same service id.
> 
> Well, that really is the problem here, the private data compare
> doesn't really do enough because rdma cm wildcard's the IP address and
> does it's own check anyhow. So I see all of this as different
> proposals on how to fix that. rdma_cm basically already does most of
> the private data compare itself.

Maybe the first thing to fix is this.  Since the private data compare is no longer sufficient, remove it and update the rdma_cm to handle the change.  Regardless of how the code ends up structured, the namespace support should then easily fit into that solution.

- Sean
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
