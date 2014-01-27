From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ip, ipv6: handle gso skbs in forwarding path
Date: Mon, 27 Jan 2014 00:34:03 -0800 (PST)
Message-ID: <20140127.003403.165822194531743765.davem@davemloft.net>
References: <1390810971-23959-1-git-send-email-fw@strlen.de>
	<1390810971-23959-2-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56779 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753334AbaA0IeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jan 2014 03:34:04 -0500
In-Reply-To: <1390810971-23959-2-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon, 27 Jan 2014 09:22:51 +0100

> Changes since V2:
>  - make this thing apply to current -net tree
>  - kill unused variables in ip_forward/ip6_output

Still need changes.
> +	return skb_gso_network_seglen(skb) > dst_mtu(skb_dst(skb));

You can't use dst_mtu() directly, in order to be consistent with the
rest of the forwarding code in this file you must use something like:

>  	mtu = ip_dst_mtu_maybe_forward(&rt->dst, true);
