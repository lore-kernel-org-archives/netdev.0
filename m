From: "ira.weiny" <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2 06/11] IB/cm, cma: Move RDMA IP CM private-data parsing code from ib_cma to ib_cm
Date: Mon, 20 Apr 2015 19:29:05 -0400
Message-ID: <20150420232904.GB1409@phlsvsds.ph.intel.com>
References: <1429520622-10303-1-git-send-email-haggaie@mellanox.com> <1429520622-10303-7-git-send-email-haggaie@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1429520622-10303-7-git-send-email-haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 20, 2015 at 12:03:37PM +0300, Haggai Eran wrote:
> From: Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> 
> When receiving a connection request, ib_cm needs to associate the request with
> a network namespace. To do this, it needs to know the request's destination
> IP. For this the RDMA IP CM packet formatting functionality needs to be
> exposed to ib_cm.
> 

[snip]

> +
> +int cm_save_net_info(struct sockaddr *src_addr,
> +		     struct sockaddr *dst_addr,
> +		     struct ib_cm_event *ib_event)
> +{
> +	struct cm_work *work = container_of(ib_event, struct cm_work, cm_event);
> +
> +	if ((rdma_port_get_link_layer(work->port->cm_dev->ib_device,
> +				      work->port->port_num) ==
> +	     IB_LINK_LAYER_INFINIBAND) &&
> +	    (ib_event->event == IB_CM_REQ_RECEIVED)) {

The original code in the RDMA CM had a check for AF_IB.  Isn't that needed here
as well?

Ira

> +		cm_save_ib_info(src_addr, dst_addr,
> +				ib_event->param.req_rcvd.primary_path);
> +		return 0;
> +	}
> +
> +	return cm_save_ip_info(src_addr, dst_addr, work);
> +}
> +EXPORT_SYMBOL(cm_save_net_info);
> +
>  struct ib_cm_id *ib_create_cm_id(struct ib_device *device,
>  				 ib_cm_handler cm_handler,
>  				 void *context)
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
