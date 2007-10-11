From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [IPv6] Update setsockopt(IPV6_MULTICAST_IF) to support RFC 3493, try2
Date: Thu, 11 Oct 2007 10:49:14 -0700
Message-ID: <OFF4E419EA.816C7D2D-ON88257371.0061B23A-88257371.0061CC92@us.ibm.com>
References: <470E5FF8.7050004@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:48078 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755371AbXJKRtW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 13:49:22 -0400
In-Reply-To: <470E5FF8.7050004@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Acked-by: David L Stevens <dlstevens@us.ibm.com>

> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>
> diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
> index 532425d..1334fc1 100644
> --- a/net/ipv6/ipv6_sockglue.c
> +++ b/net/ipv6/ipv6_sockglue.c
> @@ -539,12 +539,15 @@ done:
>     case IPV6_MULTICAST_IF:
>        if (sk->sk_type == SOCK_STREAM)
>           goto e_inval;
> -      if (sk->sk_bound_dev_if && sk->sk_bound_dev_if != val)
> -         goto e_inval;
> 
> -      if (__dev_get_by_index(&init_net, val) == NULL) {
> -         retv = -ENODEV;
> -         break;
> +      if (val) {
> +         if (sk->sk_bound_dev_if && sk->sk_bound_dev_if != val)
> +            goto e_inval;
> +
> +         if (__dev_get_by_index(&init_net, val) == NULL) {
> +            retv = -ENODEV;
> +            break;
> +         }
>        }
>        np->mcast_oif = val;
>        retv = 0;

