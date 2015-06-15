From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH 08/11] IB/cma: Add net_dev and private data checks to
 RDMA CM
Date: Mon, 15 Jun 2015 11:08:37 -0600
Message-ID: <20150615170837.GA14982@obsidianresearch.com>
References: <1434358036-15526-1-git-send-email-haggaie@mellanox.com>
 <1434358036-15526-9-git-send-email-haggaie@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Doug Ledford <dledford@redhat.com>, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>
To: Haggai Eran <haggaie@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:33403 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755567AbbFORIl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jun 2015 13:08:41 -0400
Content-Disposition: inline
In-Reply-To: <1434358036-15526-9-git-send-email-haggaie@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 15, 2015 at 11:47:13AM +0300, Haggai Eran wrote:
> Instead of relying on a the ib_cm module to check an incoming CM request's
> private data header, add these checks to the RDMA CM module. This allows a
> following patch to to clean up the ib_cm interface and remove the code that
> looks into the private headers. It will also allow supporting namespaces in
> RDMA CM by making these checks namespace aware later on.

I was expecting one of these patches to flow the net_device from here:

> +static struct net_device *cma_get_net_dev(struct ib_cm_event *ib_event,
> +					  const struct cma_req_info *req)
> +{

Down through cma_req_handler and cma_new_conn_id so that we get rid of
the cma_translate_addr on the ingress side.

Having the ingress side use one ingress net_device for all processing
seems very important to me...

Jason
