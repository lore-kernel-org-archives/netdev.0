From: "Amir Vadai\"" <amir@vadai.me>
Subject: Re: [net-next PATCH 3/7] net: sched: add cls_u32 offload hooks for
 netdevs
Date: Thu, 4 Feb 2016 15:18:57 +0200
Message-ID: <20160204131857.GA1458@office.Home>
References: <20160203092708.1356.13733.stgit@john-Precision-Tower-5810>
 <20160203092837.1356.8823.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ogerlitz@mellanox.com, jiri@resnulli.us, jhs@mojatatu.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34885 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965647AbcBDNP7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 08:15:59 -0500
Received: by mail-wm0-f68.google.com with SMTP id g62so401681wme.2
        for <netdev@vger.kernel.org>; Thu, 04 Feb 2016 05:15:58 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160203092837.1356.8823.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 03, 2016 at 01:28:37AM -0800, John Fastabend wrote:
> This patch allows netdev drivers to consume cls_u32 offloads via
> the ndo_setup_tc ndo op.
> 
> This works aligns with how network drivers have been doing qdisc
> offloads for mqprio.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  include/linux/netdevice.h |    6 +++-
>  include/net/pkt_cls.h     |   33 ++++++++++++++++++++
>  net/sched/cls_u32.c       |   73 ++++++++++++++++++++++++++++++++++++++++++++-
>  3 files changed, 109 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 9090ff7..861ce67 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -778,17 +778,21 @@ static inline bool netdev_phys_item_id_same(struct netdev_phys_item_id *a,
>  typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
>  				       struct sk_buff *skb);
>  
> -/* This structure holds attributes of qdisc and classifiers
> +/* These structures hold the attributes of qdisc and classifiers
>   * that are being passed to the netdevice through the setup_tc op.
>   */
>  enum {
>  	TC_SETUP_MQPRIO,
> +	TC_SETUP_CLSU32,
>  };
>  
> +struct tc_cls_u32_offload;
> +
>  struct tc_to_netdev {
>  	unsigned int type;
>  	union {
>  		u8 tc;
> +		struct tc_cls_u32_offload *cls_u32;
>  	};
>  };
>  
> diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
> index bc49967..0bd12cd 100644
> --- a/include/net/pkt_cls.h
> +++ b/include/net/pkt_cls.h
> @@ -358,4 +358,37 @@ tcf_match_indev(struct sk_buff *skb, int ifindex)
>  }
>  #endif /* CONFIG_NET_CLS_IND */
>  
> +struct tc_cls_u32_knode {
> +	struct tcf_exts *exts;
> +	u8 fshift;
> +	u32 handle;
> +	u32 val;
> +	u32 mask;
> +	u32 link_handle;
> +	struct tc_u32_sel *sel;
> +};
> +
> +struct tc_cls_u32_hnode {
> +	u32 handle;
> +	u32 prio;
> +	unsigned int divisor;
> +};
> +
> +enum {
> +	TC_CLSU32_NEW_KNODE,
TC_CLSU32_NEW_KNODE is never used

[...]
