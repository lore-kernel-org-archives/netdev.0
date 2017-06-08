From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next 1/8] qed: LL2 to use packed information for tx
Date: Thu, 08 Jun 2017 19:23:58 -0400 (EDT)
Message-ID: <20170608.192358.1444190196602150329.davem@davemloft.net>
References: <20170608161323.7597-1-Yuval.Mintz@cavium.com>
        <20170608161323.7597-2-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org
To: Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170608161323.7597-2-Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Date: Thu, 8 Jun 2017 19:13:16 +0300

> @@ -67,6 +79,21 @@ struct qed_ll2_stats {
>  	u64 sent_bcast_pkts;
>  };
>  
> +struct qed_ll2_tx_pkt_info {
> +	u8 num_of_bds;
> +	u16 vlan;
> +	u8 bd_flags;
> +	u16 l4_hdr_offset_w;	/* from start of packet */
> +	enum qed_ll2_tx_dest tx_dest;
> +	enum qed_ll2_roce_flavor_type qed_roce_flavor;
> +	dma_addr_t first_frag;
> +	u16 first_frag_len;
> +	bool enable_ip_cksum;
> +	bool enable_l4_cksum;
> +	bool calc_ip_len;
> +	void *cookie;
> +};
> +

This layout is extremely inefficient, with lots of padding in between
struct members.

Group small u8 members and u16 members together so that they consume
full 32-bit areas so you can eliminate all of the padding.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
