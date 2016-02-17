From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip6_gre: clear IPCB in ip6gre_xmit2 in case
 dst_link_failure called
Date: Wed, 17 Feb 2016 10:26:31 -0500 (EST)
Message-ID: <20160217.102631.728315767953679869.davem@davemloft.net>
References: <1454990874-10497-1-git-send-email-bernie.harris@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	stable@vger.kernel.org
To: bernie.harris@alliedtelesis.co.nz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53251 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965188AbcBQP0d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 10:26:33 -0500
In-Reply-To: <1454990874-10497-1-git-send-email-bernie.harris@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bernie Harris <bernie.harris@alliedtelesis.co.nz>
Date: Tue,  9 Feb 2016 17:07:54 +1300

> @@ -678,6 +678,7 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
>  				tunnel->err_time + IP6TUNNEL_ERR_TIMEO)) {
>  			tunnel->err_count--;
>  
> +			memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
>  			dst_link_failure(skb);
>  		} else
>  			tunnel->err_count = 0;
> -- 
> 2.7.1
> 

I have a hard time accepting this because I see no other place in ipv6 tunnel
handling where we have to handle this kind of case.

If anything, this code should mimick the code in ip6_udp_tunnel6_xmit_skb()
which clears only the IPCH(skb)->opt field, and does so unconditionally.

If this happens for GRE ipv6 tunnels, it potentially could happen for any
tunnel.  Therefore we should apply consistent handling of this problem
to every ipv6 tunnel implementation rather than just one spot.

Thanks.
