From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [patch net-next v2 05/12] net: ipmr: Add MFC offload indication
Date: Mon, 25 Sep 2017 12:36:45 +0300
Message-ID: <7d9433b4-50c9-3ac0-4eef-c8f847897e8c@cumulusnetworks.com>
References: <20170924172212.10096-1-jiri@resnulli.us>
 <20170924172212.10096-6-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, andrew@lunn.ch
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:50039 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934075AbdIYJgs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 05:36:48 -0400
Received: by mail-wm0-f50.google.com with SMTP id r74so17575035wme.4
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 02:36:48 -0700 (PDT)
In-Reply-To: <20170924172212.10096-6-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/09/17 20:22, Jiri Pirko wrote:
> From: Yotam Gigi <yotamg@mellanox.com>
> 
> Allow drivers, registered to the fib notification chain indicate whether a
> multicast MFC route is offloaded or not, similarly to unicast routes. The
> indication of whether a route is offloaded is done using the mfc_flags
> field on an mfc_cache struct, and the information is sent to the userspace
> via the RTNetlink interface only.
> 
> Currently, MFC routes are either offloaded or not, thus there is no need to
> add per-VIF offload indication.
> 
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
> v1->v2:
>  - Add comment for the MFC_OFFLOAD flag
> ---
>  include/linux/mroute.h | 2 ++
>  net/ipv4/ipmr.c        | 3 +++
>  2 files changed, 5 insertions(+)
> 
> diff --git a/include/linux/mroute.h b/include/linux/mroute.h
> index 54c5cb8..5566580 100644
> --- a/include/linux/mroute.h
> +++ b/include/linux/mroute.h
> @@ -90,9 +90,11 @@ struct mr_table {
>  
>  /* mfc_flags:
>   * MFC_STATIC - the entry was added statically (not by a routing daemon)
> + * MFC_OFFLOAD - the entry was offloaded to the hardware
>   */
>  enum {
>  	MFC_STATIC = BIT(0),
> +	MFC_OFFLOAD = BIT(1),
>  };
>  
>  struct mfc_cache_cmp_arg {
> diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
> index ba71bc4..2a795d2 100644
> --- a/net/ipv4/ipmr.c
> +++ b/net/ipv4/ipmr.c
> @@ -2268,6 +2268,9 @@ static int __ipmr_fill_mroute(struct mr_table *mrt, struct sk_buff *skb,
>  	    nla_put_u32(skb, RTA_IIF, mrt->vif_table[c->mfc_parent].dev->ifindex) < 0)
>  		return -EMSGSIZE;
>  
> +	if (c->mfc_flags & MFC_OFFLOAD)
> +		rtm->rtm_flags |= RTNH_F_OFFLOAD;
> +
>  	if (!(mp_attr = nla_nest_start(skb, RTA_MULTIPATH)))
>  		return -EMSGSIZE;
>  
> 

Thanks!

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
