From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Subject: Re: [PATCH  v4 01/13] Linux RDMA Core Changes
Date: Wed, 3 Jan 2007 17:00:13 +0200
Message-ID: <20070103150013.GO6019@mellanox.co.il>
References: <1167836172.4187.9.camel@stevo-desktop>
Reply-To: "Michael S. Tsirkin" <mst@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roland Dreier <rdreier@cisco.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, openib-general@openib.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dev.mellanox.co.il ([194.90.237.44]:36493 "EHLO
	dev.mellanox.co.il" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750787AbXACPCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jan 2007 10:02:16 -0500
To: Steve Wise <swise@opengridcomputing.com>
Content-Disposition: inline
In-Reply-To: <1167836172.4187.9.camel@stevo-desktop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > 
> > No, it won't need 2 transitions - just an extra function call,
> > so it won't hurt performance - it would improve performance.
> > 
> > ib_uverbs_req_notify_cq would call
> > 
> > 	ib_uverbs_req_notify_cq()
> > 	{
> > 			ib_set_cq_udata(cq, udata)
> > 			ib_req_notify_cq(cq, cmd.solicited_only ?
> > 				IB_CQ_SOLICITED : IB_CQ_NEXT_COMP);
> > 	}
> > 
> 
> ib_set_cq_udata() would transition into the kernel to pass in the
> consumer's index.  In addition, ib_req_notify_cq would also transition
> into the kernel since its not a bypass function for chelsio.

We misunderstand each other.

ib_uverbs_req_notify_cq is in drivers/infiniband/core/uverbs_cmd.c -
all this code runs inside the IB_USER_VERBS_CMD_REQ_NOTIFY_CQ command,
so there is a single user to kernel transition.

-- 
MST
