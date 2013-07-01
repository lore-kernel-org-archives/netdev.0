From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH net-next] net: Include phys_port identifier in the
 RTM_NEWLINK message
Date: Mon, 1 Jul 2013 21:14:47 +0100
Message-ID: <1372709687.2083.62.camel@bwh-desktop.uk.level5networks.com>
References: <20130628153424.GA4340@fedora-17-guest.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <john.r.fastabend@intel.com>
To: <Narendra_K@Dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:53642 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755800Ab3GAUOv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 16:14:51 -0400
In-Reply-To: <20130628153424.GA4340@fedora-17-guest.blr.amer.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-06-28 at 21:04 +0530, Narendra_K@Dell.com wrote:
> This patch adds a new netlink attribute 'IFLA_PHYS_PORT' to identify
> the 'phys_port' identifier and includes the 'phys_port' identifier
> in the RTM_NEWLINK message.
> 
> Signed-off-by: Narendra K <narendra_k@dell.com>
Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

> ---
>  include/uapi/linux/if_link.h | 1 +
>  net/core/rtnetlink.c         | 7 +++++++
>  2 files changed, 8 insertions(+)
> 
> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
> index 03f6170..6dc4476 100644
> --- a/include/uapi/linux/if_link.h
> +++ b/include/uapi/linux/if_link.h
> @@ -143,6 +143,7 @@ enum {
>  	IFLA_NUM_TX_QUEUES,
>  	IFLA_NUM_RX_QUEUES,
>  	IFLA_CARRIER,
> +	IFLA_PHYS_PORT,
>  	__IFLA_MAX
>  };
>  
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 9007533..ade66a3 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -751,6 +751,7 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
>  	       + nla_total_size(sizeof(struct rtnl_link_stats64))
>  	       + nla_total_size(MAX_ADDR_LEN) /* IFLA_ADDRESS */
>  	       + nla_total_size(MAX_ADDR_LEN) /* IFLA_BROADCAST */
> +	       + nla_total_size(MAX_ADDR_LEN) /* IFLA_PHYS_PORT */
>  	       + nla_total_size(4) /* IFLA_TXQLEN */
>  	       + nla_total_size(4) /* IFLA_WEIGHT */
>  	       + nla_total_size(4) /* IFLA_MTU */
> @@ -913,6 +914,12 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
>  			goto nla_put_failure;
>  	}
>  
> +	if (dev->phys_port.port_id_len) {
> +		if (nla_put(skb, IFLA_PHYS_PORT, dev->phys_port.port_id_len,
> +			    dev->phys_port.port_id))
> +			goto nla_put_failure;
> +	}
> +
>  	attr = nla_reserve(skb, IFLA_STATS,
>  			sizeof(struct rtnl_link_stats));
>  	if (attr == NULL)
> -- 
> 1.8.0.1
> 

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
