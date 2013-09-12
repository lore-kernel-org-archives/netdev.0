From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] fix NULL pointer dereference in
 br_handle_frame
Date: Thu, 12 Sep 2013 15:18:55 -0400 (EDT)
Message-ID: <20130912.151855.2190474215627495241.davem@davemloft.net>
References: <1378988195-2710-1-git-send-email-zhiguohong@tencent.com>
	<1379001428-2727-1-git-send-email-zhiguohong@tencent.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, zhiguohong@tencent.com
To: honkiko@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37015 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752855Ab3ILTS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 15:18:58 -0400
In-Reply-To: <1379001428-2727-1-git-send-email-zhiguohong@tencent.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hong Zhiguo <honkiko@gmail.com>
Date: Thu, 12 Sep 2013 23:57:08 +0800

> @@ -60,7 +60,7 @@ static int br_pass_frame_up(struct sk_buff *skb)
>  int br_handle_frame_finish(struct sk_buff *skb)
>  {
>  	const unsigned char *dest = eth_hdr(skb)->h_dest;
> -	struct net_bridge_port *p = br_port_get_rcu(skb->dev);
> +	enet_bridge_port *p = rcu_dereference(skb->dev->rx_handler_data);

You did not even compile test this patch.

This is a good way to make people not want to review your work at all,
because if you don't care enough to even compile test your patch why
should other people care enough to look at it?
