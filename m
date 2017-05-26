From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 2/2] net: ndisc.c: minor code improvement
Date: Fri, 26 May 2017 07:05:27 -0700
Message-ID: <1495807527.29207.28.camel@perches.com>
References: <1495805052-2974-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        David Ahern <dsahern@gmail.com>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: yuan linyu <cugyly@163.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0031.hostedemail.com ([216.40.44.31]:45381 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S940578AbdEZOFd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 10:05:33 -0400
In-Reply-To: <1495805052-2974-1-git-send-email-cugyly@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-05-26 at 21:24 +0800, yuan linyu wrote:
> From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> 
> on x86_64, text size decrease 80 bytes

You are sending whitespace and code reduction changes.

Please send the object code size reduction changes
as a separate patch from the whitespace only changes.

> Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> ---
>  net/ipv6/ndisc.c | 32 ++++++++++++++++----------------
>  1 file changed, 16 insertions(+), 16 deletions(-)
> 
> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> index 292c827..ee9b12c 100644
> --- a/net/ipv6/ndisc.c
> +++ b/net/ipv6/ndisc.c
> @@ -147,17 +147,16 @@ void __ndisc_fill_addr_option(struct sk_buff *skb, int type, void *data,
>  
>  	opt[0] = type;
>  	opt[1] = space >> 3;
> +	opt   += 2;
>  
> -	memset(opt + 2, 0, pad);
> +	memset(opt, 0, pad);
>  	opt   += pad;
>  	space -= pad;
>  
> -	memcpy(opt + 2, data, data_len);
> -	data_len += 2;
> +	memcpy(opt, data, data_len);
>  	opt += data_len;
>  	space -= data_len;
> -	if (space > 0)
> -		memset(opt, 0, space);
> +	memset(opt, 0, space);
>  }
>  EXPORT_SYMBOL_GPL(__ndisc_fill_addr_option);
>  
> @@ -997,6 +996,7 @@ static void ndisc_recv_na(struct sk_buff *skb)
>  	if (neigh) {
>  		u8 old_flags = neigh->flags;
>  		struct net *net = dev_net(dev);
> +		u32 flags;
>  
>  		if (neigh->nud_state & NUD_FAILED)
>  			goto out;
> @@ -1013,13 +1013,14 @@ static void ndisc_recv_na(struct sk_buff *skb)
>  			goto out;
>  		}
>  
> +		flags = NEIGH_UPDATE_F_WEAK_OVERRIDE | NEIGH_UPDATE_F_OVERRIDE_ISROUTER;
> +		if (msg->icmph.icmp6_override)
> +			flags |= NEIGH_UPDATE_F_OVERRIDE;
> +		if (msg->icmph.icmp6_router)
> +			flags |= NEIGH_UPDATE_F_ISROUTER;
>  		ndisc_update(dev, neigh, lladdr,
>  			     msg->icmph.icmp6_solicited ? NUD_REACHABLE : NUD_STALE,
> -			     NEIGH_UPDATE_F_WEAK_OVERRIDE|
> -			     (msg->icmph.icmp6_override ? NEIGH_UPDATE_F_OVERRIDE : 0)|
> -			     NEIGH_UPDATE_F_OVERRIDE_ISROUTER|
> -			     (msg->icmph.icmp6_router ? NEIGH_UPDATE_F_ISROUTER : 0),
> -			     NDISC_NEIGHBOUR_ADVERTISEMENT, &ndopts);
> +			     flags, NDISC_NEIGHBOUR_ADVERTISEMENT, &ndopts);
>  
>  		if ((old_flags & ~neigh->flags) & NTF_ROUTER) {
>  			/*
> @@ -1217,12 +1218,11 @@ static void ndisc_router_discovery(struct sk_buff *skb)
>  	 * received RA message (RFC 2462) -- yoshfuji
>  	 */
>  	old_if_flags = in6_dev->if_flags;
> -	in6_dev->if_flags = (in6_dev->if_flags & ~(IF_RA_MANAGED |
> -				IF_RA_OTHERCONF)) |
> -				(ra_msg->icmph.icmp6_addrconf_managed ?
> -					IF_RA_MANAGED : 0) |
> -				(ra_msg->icmph.icmp6_addrconf_other ?
> -					IF_RA_OTHERCONF : 0);
> +	in6_dev->if_flags &= ~(IF_RA_MANAGED | IF_RA_OTHERCONF);
> +	if (ra_msg->icmph.icmp6_addrconf_managed)
> +		in6_dev->if_flags |= IF_RA_MANAGED;
> +	if (ra_msg->icmph.icmp6_addrconf_other)
> +		in6_dev->if_flags |= IF_RA_OTHERCONF;
>  
>  	if (old_if_flags != in6_dev->if_flags)
>  		send_ifinfo_notify = true;
