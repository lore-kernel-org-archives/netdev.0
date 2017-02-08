From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net 2/2] packet: round up linear to header len
Date: Wed, 8 Feb 2017 07:34:54 -0800
Message-ID: <20170208153454.GD30741@oracle.com>
References: <20170207205721.23207-1-willemdebruijn.kernel@gmail.com>
 <20170207205721.23207-3-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        eric.dumazet@gmail.com, dvyukov@google.com,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1050.oracle.com ([141.146.126.70]:44747 "EHLO
        aserp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751906AbdBHP5F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 10:57:05 -0500
Received: from aserp1040.oracle.com (aserp1040.oracle.com [141.146.126.69])
        by aserp1050.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id v18FaCme015094
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <netdev@vger.kernel.org>; Wed, 8 Feb 2017 15:36:12 GMT
Content-Disposition: inline
In-Reply-To: <20170207205721.23207-3-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (02/07/17 15:57), Willem de Bruijn wrote:
> @@ -2816,8 +2816,9 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
>  	err = -ENOBUFS;
>  	hlen = LL_RESERVED_SPACE(dev);
>  	tlen = dev->needed_tailroom;
> -	skb = packet_alloc_skb(sk, hlen + tlen, hlen, len,
> -			       __virtio16_to_cpu(vio_le(), vnet_hdr.hdr_len),
> +	linear = __virtio16_to_cpu(vio_le(), vnet_hdr.hdr_len);
> +	linear = max(linear, min_t(int, len, dev->hard_header_len));
> +	skb = packet_alloc_skb(sk, hlen + tlen, hlen, len, linear,
>  			       msg->msg_flags & MSG_DONTWAIT, &err);

do we need a similar check in packet_sendsmg_spkt (even if it
is deprecated, would be better to get it to align with packet_snd?)

Also tpacket_fill_skb should ensure that copylen is set up like
the code above?

--Sowmini
