From: Sean Hefty <mshefty@ichips.intel.com>
Subject: Re: [PATCH 2/2] iWARP Core Changes.
Date: Wed, 31 May 2006 14:26:42 -0700
Message-ID: <447E0A12.5090209@ichips.intel.com>
References: <20060531182650.3308.81538.stgit@stevo-desktop> <20060531182654.3308.41372.stgit@stevo-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, openib-general@openib.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr18.intel.com ([134.134.136.17]:40098 "EHLO
	orsfmr003.jf.intel.com") by vger.kernel.org with ESMTP
	id S965161AbWEaV0p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 17:26:45 -0400
To: Steve Wise <swise@opengridcomputing.com>
In-Reply-To: <20060531182654.3308.41372.stgit@stevo-desktop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mainly nits...

Steve Wise wrote:
> -static int copy_addr(struct rdma_dev_addr *dev_addr, struct net_device *dev,
> +int copy_addr(struct rdma_dev_addr *dev_addr, struct net_device *dev,
>  		     unsigned char *dst_dev_addr)

Might want to rename this to something like rdma_copy_addr if you're going to 
export it.

> +static int cma_iw_handler(struct iw_cm_id *iw_id, struct iw_cm_event *iw_event)
> +{
> +	struct rdma_id_private *id_priv = iw_id->context;
> +	enum rdma_cm_event_type event = 0;
> +	struct sockaddr_in *sin;
> +	int ret = 0;
> +
> +	atomic_inc(&id_priv->dev_remove);
> +
> +	switch (iw_event->event) {
> +	case IW_CM_EVENT_CLOSE:
> +		event = RDMA_CM_EVENT_DISCONNECTED;
> +		break;
> +	case IW_CM_EVENT_CONNECT_REPLY:
> +		sin = (struct sockaddr_in*)&id_priv->id.route.addr.src_addr;
> +		*sin = iw_event->local_addr;
> +		sin = (struct sockaddr_in*)&id_priv->id.route.addr.dst_addr;

spacing nit - (struct sockaddr_in *) &id_priv->...

> +struct net_device *ip_dev_find(u32 ip);

Just include header file with definition.

> +	sin = (struct sockaddr_in*)&new_cm_id->route.addr.src_addr;
> +	*sin = iw_event->local_addr;
> +	sin = (struct sockaddr_in*)&new_cm_id->route.addr.dst_addr;

same spacing nit...  appears in a couple other places as well.

> +static inline union ib_gid* iw_addr_get_sgid(struct rdma_dev_addr* rda)
> +{
> +	return (union ib_gid*)rda->src_dev_addr;
> +}
> +
> +static inline union ib_gid* iw_addr_get_dgid(struct rdma_dev_addr* rda)
> +{
> +	return (union ib_gid*)rda->dst_dev_addr;
> +}

spacing nits

> +struct iw_cm_verbs;
>  struct ib_device {
>  	struct device                *dma_device;
>  
> @@ -846,6 +873,8 @@ struct ib_device {
>  
>  	u32                           flags;
>  
> +	struct iw_cm_verbs*           iwcm;
> +

'*' placement nit

- Sean
