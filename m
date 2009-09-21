From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH 12/13] TProxy: added IPv6 support to the socket match
Date: Mon, 21 Sep 2009 13:59:20 -0400
Message-ID: <4AB7BEF8.5050800@hp.com>
References: <1253548005.12519.12.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Balazs Scheidler <bazsi@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:49142 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751175AbZIUR7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2009 13:59:47 -0400
In-Reply-To: <1253548005.12519.12.camel@bzorp.balabit>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Balazs Scheidler wrote:
> +static bool
> +socket_mt6_v1(const struct sk_buff *skb, const struct xt_match_param *par)
> +{
> +	struct ipv6hdr *iph = ipv6_hdr(skb);
> +	struct udphdr _hdr, *hp = NULL;
> +	struct sock *sk;
> +	struct in6_addr *daddr, *saddr;
> +	__be16 dport, sport;
> +        int thoff;
> +	u8 tproto;
> +        const struct xt_socket_mtinfo1 *info = (struct xt_socket_mtinfo1 *) par->matchinfo;
> +        
> +        tproto = ipv6_find_hdr(skb, &thoff, -1, NULL);
> +        if (tproto < 0) {
> +		pr_debug("socket match: Unable to find transport header in IPv6 packet, dropping\n");
> +		return NF_DROP;
> +        }
> +
> +	if (tproto == IPPROTO_UDP || tproto == IPPROTO_TCP) {
> +		hp = skb_header_pointer(skb, thoff,
> +					sizeof(_hdr), &_hdr);
> +		if (hp == NULL)
> +			return false;
> +
> +		saddr = &iph->saddr;
> +		sport = hp->source;
> +		daddr = &iph->daddr;
> +		dport = hp->dest;
> +
> +	} else if (tproto == IPPROTO_ICMP) {
> +		if (extract_icmp6_fields(skb, thoff, &tproto, &saddr, &daddr,
> +					 &sport, &dport))
> +			return false;
> +	} else {
> +		return false;
> +	}

Shouldn't this be IPPROTO_ICMPV6?

-Brian
