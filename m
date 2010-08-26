From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [IPoIB] Identify multicast packets and fix IGMP breakage V2
Date: Thu, 26 Aug 2010 15:15:53 -0700 (PDT)
Message-ID: <20100826.151553.242147157.davem@davemloft.net>
References: <adapqx5rtez.fsf@cisco.com>
	<alpine.DEB.2.00.1008261613160.24174@router.home>
	<alpine.DEB.2.00.1008261629440.24174@router.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ogerlitz-smomgflXvOZWk0Htik3J/w@public.gmane.org, jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org,
	yosefe-smomgflXvOZWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.00.1008261629440.24174-sBS69tsa9Uj/9pzu0YdTqQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Date: Thu, 26 Aug 2010 16:31:14 -0500 (CDT)

> @@ -271,6 +271,13 @@ static void ipoib_ib_handle_rx_wc(struct
>  	ipoib_ud_dma_unmap_rx(priv, mapping);
>  	ipoib_ud_skb_put_frags(priv, skb, wc->byte_len);
> 
> +	if ((wc->wc_flags & IB_WC_GRH) &&
> +		IN6_IS_ADDR_MULTICAST(&((struct ipv6hdr *)skb->data)->daddr))
> +
> +		skb->pkt_type = PACKET_MULTICAST;
> +	else
> +		skb->pkt_type = PACKET_HOST;

I really don't think you can assume there is an ipv6 header here
at all.

You'll need to parse the encapsulated protocol and process it as
ipv4 or ipv6 as needed.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
