From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] net/mlx4_en: Fix IPv6 csum calculation
Date: Fri, 28 Aug 2015 12:46:57 -0700
Message-ID: <1440791217.11525.141.camel@perches.com>
References: <1440790107-24268-1-git-send-email-clsoto@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, ogerlitz@mellanox.com,
	brking@linux.vnet.ibm.com, amirv@mellanox.com,
	Muhammad Mahajna <muhammadm@mellanox.com>
To: clsoto@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0047.hostedemail.com ([216.40.44.47]:59958 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752514AbbH1TrA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 15:47:00 -0400
In-Reply-To: <1440790107-24268-1-git-send-email-clsoto@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-08-28 at 14:28 -0500, clsoto@linux.vnet.ibm.com wrote:
> From: Carol L Soto <clsoto@linux.vnet.ibm.com>
> 
> Seeing this message with mlx4_eni with IPv6: hw csum failure
> 
> Changing IPv6 csum calculation to be based on OFED 2.4 code.
> When calculate IPv6 csum based also on source and destination
> addresses.
[]
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
[]
> +static __wsum csum_ipv6_magic_nofold(const struct in6_addr *saddr,
> +				     const struct in6_addr *daddr,
> +				     __u32 len, unsigned short proto)
> +{
> +	__wsum res = 0;
> +
> +	res = csum_add(res, saddr->in6_u.u6_addr32[0]);
> +	res = csum_add(res, saddr->in6_u.u6_addr32[1]);
> +	res = csum_add(res, saddr->in6_u.u6_addr32[2]);
> +	res = csum_add(res, saddr->in6_u.u6_addr32[3]);
> +	res = csum_add(res, daddr->in6_u.u6_addr32[0]);
> +	res = csum_add(res, daddr->in6_u.u6_addr32[1]);
> +	res = csum_add(res, daddr->in6_u.u6_addr32[2]);
> +	res = csum_add(res, daddr->in6_u.u6_addr32[3]);
> +	res = csum_add(res, len);
> +	res = csum_add(res, htonl(proto));

You should try running sparse on this code.
