From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/5] ipv6: RFC 4884 partial support for
 SIT/GRE tunnels
Date: Sat, 18 Jun 2016 20:54:48 -0700 (PDT)
Message-ID: <20160618.205448.2083694904305197335.davem@davemloft.net>
References: <1466292400-3638-1-git-send-email-edumazet@google.com>
	<1466292400-3638-6-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ghorbel@pivasoftware.com,
	eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37999 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751601AbcFSDyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jun 2016 23:54:52 -0400
In-Reply-To: <1466292400-3638-6-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Sat, 18 Jun 2016 16:26:40 -0700

> @@ -588,12 +594,26 @@ int ip6_err_gen_icmpv6_unreach(struct sk_buff *skb, int nhs, int type)
>  		skb2->dev = rt->dst.dev;
>  
>  	ipv6_addr_set_v4mapped(ip_hdr(skb)->saddr, &temp_saddr);
> +
> +	if (data_len) {
> +		/* RFC 4884 (partial) support :
> +		 * insert 0 padding at the end, before the extensions
> +		 */
> +		__skb_push(skb2, nhs);
> +		skb_reset_network_header(skb2);
> +		memcpy(skb2->data, skb2->data + nhs, data_len - nhs);

Since this is overlapping, it really need to use memmove() instead of
memcpy().
