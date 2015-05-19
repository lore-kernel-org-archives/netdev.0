From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH v3 for-next 05/13] IB/cm: Reference count ib_cm_ids
Date: Tue, 19 May 2015 13:23:53 -0600
Message-ID: <20150519192353.GA23612@obsidianresearch.com>
References: <1431253604-9214-1-git-send-email-haggaie@mellanox.com>
 <1431253604-9214-6-git-send-email-haggaie@mellanox.com>
 <20150511183459.GB25405@obsidianresearch.com>
 <5551A2CB.1010407@mellanox.com>
 <20150512185447.GA3503@obsidianresearch.com>
 <55532566.9040105@mellanox.com>
 <20150513165823.GA20343@obsidianresearch.com>
 <1828884A29C6694DAF28B7E6B8A82373A8FDC0C3@ORSMSX109.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Haggai Eran <haggaie@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>
To: "Hefty, Sean" <sean.hefty@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:38538 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750923AbbESTX5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2015 15:23:57 -0400
Content-Disposition: inline
In-Reply-To: <1828884A29C6694DAF28B7E6B8A82373A8FDC0C3@ORSMSX109.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 15, 2015 at 07:11:10PM +0000, Hefty, Sean wrote:
> > The fact the CM might share a listen (and only a listen) ID behind the
> > scenes is not the caller's problem. That is an implementation choice,
> > each caller stands alone and uses the API properly, assuming it is the
> > only user of the returned cm_id.
> 
> Actually, I seriously question why the ib_cm should be modified at all for any of this.

I find Haggai's argument compelling, it is a very small amount of code
and data to add a sharing count, and a very large amount to duplicate
the whole service id map into cma.c.

It is in-kernel after all, we should co-design module APIs to work
efficiently.

Jason
