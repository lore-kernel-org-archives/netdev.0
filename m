From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] {pktgen, xfrm} re-caculate IPv4 checksum after
 transformation
Date: Sat, 30 Nov 2013 16:17:49 -0500 (EST)
Message-ID: <20131130.161749.1028599462373827329.davem@davemloft.net>
References: <1385693949-3786-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: fan.du@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34563 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750908Ab3K3VRv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Nov 2013 16:17:51 -0500
In-Reply-To: <1385693949-3786-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>
Date: Fri, 29 Nov 2013 10:59:09 +0800

> @@ -2786,6 +2786,8 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
>  #ifdef CONFIG_XFRM
>  	if (!process_ipsec(pkt_dev, skb, protocol))
>  		return NULL;
> +	iph = ip_hdr(skb);
> +	ip_send_check(iph);
>  #endif

This is rediculous.  You're computing the checksum _twice_ unconditionally,
even if process_ipsec() does _nothing_.

Make process_ipsec() fix the checksum, but only if it actually does
something which makes the recomputation even necessary.

Thanks.
