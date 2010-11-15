From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: don't use atomic bit operation
Date: Mon, 15 Nov 2010 11:59:42 +0100
Message-ID: <4CE1129E.5040505@trash.net>
References: <1289725534-8439-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62216 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755562Ab0KOK7n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 05:59:43 -0500
In-Reply-To: <1289725534-8439-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14.11.2010 10:05, Changli Gao wrote:
> As we own ct, and the others can't see it until we confirm it, we don't
> need to use atomic bit operation on ct->status.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ---
>  include/net/netfilter/nf_nat_core.h |    4 ++--
>  net/ipv4/netfilter/nf_nat_core.c    |    4 ++--
>  2 files changed, 4 insertions(+), 4 deletions(-)
> diff --git a/include/net/netfilter/nf_nat_core.h b/include/net/netfilter/nf_nat_core.h
> index 33602ab..52ac1d8 100644
> --- a/include/net/netfilter/nf_nat_core.h
> +++ b/include/net/netfilter/nf_nat_core.h
> @@ -21,9 +21,9 @@ static inline int nf_nat_initialized(struct nf_conn *ct,
>  				     enum nf_nat_manip_type manip)
>  {
>  	if (manip == IP_NAT_MANIP_SRC)
> -		return test_bit(IPS_SRC_NAT_DONE_BIT, &ct->status);
> +		return IPS_SRC_NAT_DONE_BIT & ct->status;
>  	else
> -		return test_bit(IPS_DST_NAT_DONE_BIT, &ct->status);
> +		return IPS_DST_NAT_DONE_BIT & ct->status;
>  }

Looks fine, but I changed the order to ct->status & ...

Applied.
