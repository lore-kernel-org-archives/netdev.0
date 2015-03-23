From: Erik Hugne <erik.hugne@ericsson.com>
Subject: Re: tcp_v4_err/request sock refcnt leak?
Date: Mon, 23 Mar 2015 12:15:16 +0100
Message-ID: <20150323111516.GB21258@haze>
References: <20150323090317.GB8934@haze>
 <550FEA98.3040009@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>
To: Fan Du <fengyuleidian0615@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg23.ericsson.net ([193.180.251.37]:49779 "EHLO
	sesbmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752035AbbCWLSy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 07:18:54 -0400
Content-Disposition: inline
In-Reply-To: <550FEA98.3040009@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 23, 2015 at 06:27:36PM +0800, Fan Du wrote:
> I'm not familiar with this part, IMHO, this might be a double call for reqsk_put?

Neither am i, but the below patch does not really make sense to me.

//E


> 
> 
> diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
> index 25a9615..fd805c0 100644
> --- a/net/dccp/ipv4.c
> +++ b/net/dccp/ipv4.c
> @@ -316,7 +316,6 @@ static void dccp_v4_err(struct sk_buff *skb, u32 info)
>  		 * errors returned from accept().
>  		 */
>  		inet_csk_reqsk_queue_drop(sk, req);
> -		reqsk_put(req);
>  		goto out;
> 
>  	case DCCP_REQUESTING:
> diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
> index 69d8f13..5137ab3 100644
> --- a/net/dccp/ipv6.c
> +++ b/net/dccp/ipv6.c
> @@ -174,7 +174,6 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
>  		}
> 
>  		inet_csk_reqsk_queue_drop(sk, req);
> -		reqsk_put(req);
>  		goto out;
> 
>  	case DCCP_REQUESTING:
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 5554b8f..b1eaf3d 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -487,7 +487,6 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
>  		 */
>  		inet_csk_reqsk_queue_drop(sk, req);
>  		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
> -		reqsk_put(req);
>  		goto out;
> 
>  	case TCP_SYN_SENT:
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index 6e3f90d..1d551fa 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -427,7 +427,6 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
> 
>  		inet_csk_reqsk_queue_drop(sk, req);
>  		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
> -		reqsk_put(req);
>  		goto out;
> 
>  	case TCP_SYN_SENT:
> 
