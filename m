From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH 08/11] IB/cma: Add net_dev and private data checks to
 RDMA CM
Date: Wed, 17 Jun 2015 11:18:43 -0600
Message-ID: <20150617171843.GC27232@obsidianresearch.com>
References: <1434358036-15526-1-git-send-email-haggaie@mellanox.com>
 <1434358036-15526-9-git-send-email-haggaie@mellanox.com>
 <20150615170837.GA14982@obsidianresearch.com>
 <557FB382.5090300@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <557FB382.5090300-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 16, 2015 at 08:26:26AM +0300, Haggai Eran wrote:
> On 15/06/2015 20:08, Jason Gunthorpe wrote:
> > On Mon, Jun 15, 2015 at 11:47:13AM +0300, Haggai Eran wrote:
> >> Instead of relying on a the ib_cm module to check an incoming CM request's
> >> private data header, add these checks to the RDMA CM module. This allows a
> >> following patch to to clean up the ib_cm interface and remove the code that
> >> looks into the private headers. It will also allow supporting namespaces in
> >> RDMA CM by making these checks namespace aware later on.
> > 
> > I was expecting one of these patches to flow the net_device from here:
> > 
> >> +static struct net_device *cma_get_net_dev(struct ib_cm_event *ib_event,
> >> +					  const struct cma_req_info *req)
> >> +{
> > 
> > Down through cma_req_handler and cma_new_conn_id so that we get rid of
> > the cma_translate_addr on the ingress side.
> > 
> > Having the ingress side use one ingress net_device for all processing
> > seems very important to me...
> 
> Is it really very important? I thought the bound_dev_if of a passive
> connection id is only used by the netlink statistics mechanism.

I mean 'very important' in the sense it makes the RDMA-CM *make
logical sense*, not so much in the 'can user space tell'.

So yes, cleaning this seems very important to establish that logical
narrative of how the packet flows through this code.

Plus, there is an init_net in the cma_translate_addr path that needs to
be addressed - so purging cma_translate_addr is a great way to handle
that. That would leave only the call in rdma_bind_addr, and for bind,
the process net namespace is the correct thing to use.

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
