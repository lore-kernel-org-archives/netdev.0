From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: Pre-step for supporting GRO on vxlan
 traffic
Date: Fri, 03 Jan 2014 19:34:15 -0500 (EST)
Message-ID: <20140103.193415.802802822047682766.davem@davemloft.net>
References: <1388669276-6206-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hkchu@google.com, edumazet@google.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35372 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753866AbaADAeQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 19:34:16 -0500
In-Reply-To: <1388669276-6206-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Thu,  2 Jan 2014 15:27:55 +0200

> @@ -1125,8 +1119,8 @@ static void vxlan_rcv(struct vxlan_sock *vs,
>  	 * leave the CHECKSUM_UNNECESSARY, the device checksummed it
>  	 * for us. Otherwise force the upper layers to verify it.
>  	 */
> -	if (skb->ip_summed != CHECKSUM_UNNECESSARY || !skb->encapsulation ||
> -	    !(vxlan->dev->features & NETIF_F_RXCSUM))
> +	if ((skb->ip_summed != CHECKSUM_UNNECESSARY && skb->ip_summed != CHECKSUM_PARTIAL)
> +	    || !skb->encapsulation || !(vxlan->dev->features & NETIF_F_RXCSUM))

Never start conditional continuation lines with the conditional operator.

Operators in a chain always _end_ a line, never begin them.
