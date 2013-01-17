From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: add anti-spoofing checks for 6to4 and 6rd
Date: Thu, 17 Jan 2013 14:27:37 +0100
Message-ID: <20130117132737.GA32036@order.stressinduktion.org>
References: <20130117033258.GA23782@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:33766 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751058Ab3AQN1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 08:27:38 -0500
Content-Disposition: inline
In-Reply-To: <20130117033258.GA23782@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 17, 2013 at 04:32:58AM +0100, Hannes Frederic Sowa wrote:
> +static int sit_chksrc(struct ip_tunnel *tunnel, const __be32 *addr,
> +		const struct in6_addr *addr6)
> +{
> +#ifdef CONFIG_IPV6_SIT_6RD
> +	if (ipv6_prefix_equal(addr6, &tunnel->ip6rd.prefix,
> +				tunnel->ip6rd.prefixlen) &&
> +		memcmp(addr, &addr6->s6_addr16[1], 4))
> +		return 0;

This is wrong. David, please drop my patch, sorry. I will respin another one.
In 6rd setups one can, of course, have longer prefixlens than 16.

Thanks!
