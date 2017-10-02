From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next 01/12] qed: Add ll2 option to limit the number
 of bds per packet
Date: Mon, 02 Oct 2017 10:56:01 -0700 (PDT)
Message-ID: <20171002.105601.1655145601306767130.davem@davemloft.net>
References: <1506932638-26268-1-git-send-email-Michal.Kalderon@cavium.com>
        <1506932638-26268-2-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org
To: Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1506932638-26268-2-git-send-email-Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Date: Mon, 2 Oct 2017 11:23:47 +0300

> +		p_pkt = (void *)((u8 *)p_tx->descq_array + desc_size * i);

Hmmm... this is definitely a red flag.

> @@ -63,17 +63,14 @@ struct qed_ll2_rx_packet {
>  struct qed_ll2_tx_packet {
>  	struct list_head list_entry;
>  	u16 bd_used;
> -	u16 vlan;
> -	u16 l4_hdr_offset_w;
> -	u8 bd_flags;
>  	bool notify_fw;
>  	void *cookie;
> -
> +	/* Flexible Array of bds_set determined by max_bds_per_packet */
>  	struct {
>  		struct core_tx_bd *txq_bd;
>  		dma_addr_t tx_frag;
>  		u16 frag_len;
> -	} bds_set[ETH_TX_MAX_BDS_PER_NON_LSO_PACKET];
> +	} bds_set[1];
>  };

If you do this then you have to make the ->descq_array a void pointer
or something.

Otherwise someone will try to access it as an array and it will
explode because the elements of the array are of a variable size.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
