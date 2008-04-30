From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH][IPV6]: Compilation fix for compat MCAST_MSFILTER sockopts.
Date: Wed, 30 Apr 2008 07:26:29 -0700
Message-ID: <OF3F5D943F.5B85126C-ON8825743B.004ED1BA-8825743B.004F51C2@us.ibm.com>
References: <481875DF.2020401@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:45354 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753848AbYD3O1B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Apr 2008 10:27:01 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3UEQuYw016017
	for <netdev@vger.kernel.org>; Wed, 30 Apr 2008 10:26:56 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3UEQi7f291052
	for <netdev@vger.kernel.org>; Wed, 30 Apr 2008 10:26:44 -0400
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3UKQhYT011968
	for <netdev@vger.kernel.org>; Wed, 30 Apr 2008 14:26:43 -0600
In-Reply-To: <481875DF.2020401@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel,
Definitely should be in compat_ipv6_getsockopt() as the original was-- I 
hope
your patch doesn't do the same thing when applied!

Good catch!
                                                        +-DLS

Acked-by: David L Stevens <dlstevens@us.ibm.com>

netdev-owner@vger.kernel.org wrote on 04/30/2008 06:36:31 AM:

> The last hunk from the commit dae50295 (ipv4/ipv6 compat: Fix SSM
> applications on 64bit kernels.) escaped from the compat_ipv6_setsockopt
> to the ipv6_getsockopt (I guess due to patch smartness wrt searching
> for context) thus breaking 32-bit and 64-bit-without-compat compilation.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> ---
> 
> diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
> index b4a26f2..56d55fe 100644
> --- a/net/ipv6/ipv6_sockglue.c
> +++ b/net/ipv6/ipv6_sockglue.c
> @@ -1089,10 +1089,6 @@ int ipv6_getsockopt(struct sock *sk, int level, 
int optname,
>     if(level != SOL_IPV6)
>        return -ENOPROTOOPT;
> 
> -   if (optname == MCAST_MSFILTER)
> -      return compat_mc_getsockopt(sk, level, optname, optval, optlen,
> -         ipv6_getsockopt);
> -
>     err = do_ipv6_getsockopt(sk, level, optname, optval, optlen);
>  #ifdef CONFIG_NETFILTER
>     /* we need to exclude all possible ENOPROTOOPTs except default case 
*/
> @@ -1131,6 +1127,10 @@ int compat_ipv6_getsockopt(struct sock *sk, int 
level, 
> int optname,
>     if (level != SOL_IPV6)
>        return -ENOPROTOOPT;
> 
> +   if (optname == MCAST_MSFILTER)
> +      return compat_mc_getsockopt(sk, level, optname, optval, optlen,
> +         ipv6_getsockopt);
> +
>     err = do_ipv6_getsockopt(sk, level, optname, optval, optlen);
>  #ifdef CONFIG_NETFILTER
>     /* we need to exclude all possible ENOPROTOOPTs except default case 
*/
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

