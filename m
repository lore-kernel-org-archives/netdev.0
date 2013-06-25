From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 2/2] sit: add support of x-netns
Date: Tue, 25 Jun 2013 16:56:12 -0700 (PDT)
Message-ID: <20130625.165612.1653110297729408070.davem@davemloft.net>
References: <51C9A4E3.2060906@6wind.com>
	<1372170295-4717-1-git-send-email-nicolas.dichtel@6wind.com>
	<1372170295-4717-3-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com, bcrl@kvack.org,
	ravi.mlists@gmail.com, bhutchings@solarflare.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35253 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752400Ab3FYX4N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 19:56:13 -0400
In-Reply-To: <1372170295-4717-3-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 25 Jun 2013 16:24:55 +0200

> @@ -453,6 +454,8 @@ int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
>  	tstats->rx_bytes += skb->len;
>  	u64_stats_update_end(&tstats->syncp);
>  
> +	skb_scrub_packet(skb);
> +
>  	if (tunnel->dev->type == ARPHRD_ETHER) {
>  		skb->protocol = eth_type_trans(skb, tunnel->dev);
>  		skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);

I can't see how this can be ok.

If something in netfilter depends upon the state you are clearing out
here, someone's packet filtering setup is going to break.

I'm not applying these patches, sorry.
