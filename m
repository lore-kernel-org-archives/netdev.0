From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 1/7] fou: Get net from sock_net if dev_net
 unavailable
Date: Tue, 24 May 2016 15:01:36 -0700 (PDT)
Message-ID: <20160524.150136.139892523857598607.davem@davemloft.net>
References: <1464043706-2843932-1-git-send-email-tom@herbertland.com>
	<1464043706-2843932-2-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60189 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752133AbcEXWBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2016 18:01:38 -0400
In-Reply-To: <1464043706-2843932-2-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Mon, 23 May 2016 15:48:20 -0700

> diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
> index 5f9207c..96260c6 100644
> --- a/net/ipv4/fou.c
> +++ b/net/ipv4/fou.c
> @@ -807,13 +807,20 @@ int __fou_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
>  		       u8 *protocol, __be16 *sport, int type)
>  {
>  	int err;
> +	struct net *net;
>  

Please order local variables from longest to shortest line.

>  	err = iptunnel_handle_offloads(skb, type);
>  	if (err)
>  		return err;
>  
> -	*sport = e->sport ? : udp_flow_src_port(dev_net(skb->dev),
> -						skb, 0, 0, false);
> +	if (skb->dev)
> +		net = dev_net(skb->dev);
> +	else if (skb->sk)
> +		net = sock_net(skb->sk);

This is getting rediculous.  Why not just put the net namespace pointer into
the tunnel encap object?
