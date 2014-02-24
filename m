From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 2/6] 6lowpan: fix fragmentation on sending
 side
Date: Mon, 24 Feb 2014 18:52:13 -0500 (EST)
Message-ID: <20140224.185213.1069306984692624378.davem@davemloft.net>
References: <1393009142-1694-1-git-send-email-alex.aring@gmail.com>
	<1393009142-1694-3-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	martin.townsend@xsilon.com
To: alex.aring@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48450 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753237AbaBXXwP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 18:52:15 -0500
In-Reply-To: <1393009142-1694-3-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Aring <alex.aring@gmail.com>
Date: Fri, 21 Feb 2014 19:58:58 +0100

> +	err = lowpan_fragment_xmit(skb, head, header_length,
> +				   frag_plen + lowpan_size, 0,
> +				   LOWPAN_DISPATCH_FRAG1);
>  	if (err) {
>  		pr_debug("%s unable to send FRAG1 packet (tag: %d)",
>  			 __func__, tag);
>  		goto exit;
>  	}
>  
> -	offset = LOWPAN_FRAG_SIZE;
> +	offset = lowpan_size + frag_plen;
> +	dgram_offset = mac_cb(skb)->frag_info.d_offset + frag_plen;

This isn't going to work.

Once you call dev_queue_xmit(), the skb control block can be reused by
other layers.  In particular the device qdisc layer is going to
scramble the control block on you.

Once a packet travels from one layer to another, SKB control block
is likewise transferred.
