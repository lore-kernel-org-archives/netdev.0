From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2] gro: introduce gro_mac_header_len
Date: Tue, 07 Feb 2012 15:33:25 -0500 (EST)
Message-ID: <20120207.153325.1941809701255235550.davem@davemloft.net>
References: <CAG4TOxNcB8+SP3f0WhZG1GZ481s+=7pVRv91vzAbwDzUZD8g_A@mail.gmail.com>
	<20120206.151509.1959432192519622134.davem@davemloft.net>
	<CAL1RGDWZuFY=zeYYf2Tegw=YdpGxs9j5w2-8ADuFq1zH3vGX3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, ogerlitz@mellanox.com,
	sean.hefty@intel.com, herbert@gondor.hengli.com.au,
	linux-rdma@vger.kernel.org, shlomop@mellanox.com,
	netdev@vger.kernel.org
To: roland@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36725 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756226Ab2BGUdi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 15:33:38 -0500
In-Reply-To: <CAL1RGDWZuFY=zeYYf2Tegw=YdpGxs9j5w2-8ADuFq1zH3vGX3w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <roland@kernel.org>
Date: Tue, 7 Feb 2012 11:51:46 -0800

Overall, looks great.

> @@ -843,9 +837,8 @@ static int ipoib_hard_header(struct sk_buff *skb,
>  	if (dst)
>  		n = dst_get_neighbour_noref_raw(dst);
>  	if ((!dst || !n) && daddr) {
> -		struct ipoib_pseudoheader *phdr =
> -			(struct ipoib_pseudoheader *) skb_push(skb, sizeof *phdr);
> -		memcpy(phdr->hwaddr, daddr, INFINIBAND_ALEN);
> +		struct ipoib_cb *cb = (struct ipoib_cb *) skb->cb;
> +		memcpy(cb->hwaddr, daddr, INFINIBAND_ALEN);

I would simplify this to "!skb_dst(skb)", any failure of
dst_get_neighbour_noref_raw() (now and in the future) would be
transient.

You're trying to see if this is a "neigh resolvable" path or not, and
the correct test for that is whether a dst is attached to the SKB.
