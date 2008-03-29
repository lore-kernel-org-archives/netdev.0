From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] [NETFILTER] xt_TCPMSS: combine nearly identical
 reverse_mtu4/6
Date: Sat, 29 Mar 2008 18:13:47 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0803291812430.8589@wrl-59.cs.helsinki.fi>
References: <Pine.LNX.4.64.0803291520210.8374@wrl-59.cs.helsinki.fi>
 <alpine.LNX.1.10.0803291621170.28605@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Patrick Hardy <kaber@trash.net>, netfilter-devel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Jan Engelhardt <jengelh@computergmbh.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:54832 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752138AbYC2QNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2008 12:13:49 -0400
In-Reply-To: <alpine.LNX.1.10.0803291621170.28605@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 29 Mar 2008, Jan Engelhardt wrote:

> How about this one instead?

A minor correction is necessary, see below.

> commit 1143bd2cbcddb9fcdbffea6a2edfde42dca5bb46
> Author: Jan Engelhardt <jengelh@computergmbh.de>
> Date:   Sat Mar 29 16:20:13 2008 +0100
> 
>     [NETFILTER]: Collapse tcpmss_reverse_mtu{4,6} into one function
> 
>     Signed-off-by: Jan Engelhardt <jengelh@computergmbh.de>
> ---
>  net/netfilter/xt_TCPMSS.c |   44 ++++++++++++++------------------------------
>  1 files changed, 14 insertions(+), 30 deletions(-)
> 
> diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
> index 217e2b6..2e3fe8e 100644
> --- a/net/netfilter/xt_TCPMSS.c
> +++ b/net/netfilter/xt_TCPMSS.c
> @@ -147,15 +147,19 @@ tcpmss_mangle_packet(struct sk_buff *skb,
>  	return TCPOLEN_MSS;
>  }
> 
> -static u_int32_t tcpmss_reverse_mtu4(const struct iphdr *iph)
> +static u_int32_t tcpmss_reverse_mtu(const struct sk_buff *skb,
> +                                    unsigned int family)
>  {
> -	struct flowi fl = {
> -		.fl4_dst = iph->saddr,
> -	};
> +	struct flowi fl = {};
>  	const struct nf_afinfo *ai;
>  	struct rtable *rt = NULL;
>  	u_int32_t mtu     = ~0U;
> 
> +	if (family == AF_INET)
> +		fl.fl4_dst = ip_hdr(skb)->saddr;
> +	else
> +		fl.fl6_dst = ipv6_hdr(skb)->saddr;
> +
>  	rcu_read_lock();
>  	ai = nf_get_afinfo(AF_INET);

s/AF_INET/family/



-- 
 i.
