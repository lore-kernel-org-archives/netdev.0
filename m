From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] [IPv6]: IPV6_MULTICAST_IF setting is ignored on link-local
 connect()
Date: Mon, 7 Jan 2008 17:18:56 -0800
Message-ID: <OF3393858D.9874E03A-ON882573CA.00071BC8-882573CA.000738ED@us.ibm.com>
References: <47825B50.2060200@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:53246 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754093AbYAHBS5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2008 20:18:57 -0500
In-Reply-To: <47825B50.2060200@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian,
        Looks good to me.

                        +-DLS


Acked-by: David L Stevens <dlstevens@us.ibm.com>

> How about the simple patch below?  I just removed the ENINVAL check from 

> my original patch, but it accomplishes the same thing.
...
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>
> ---
> diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
> index 2ed689a..5d4245a 100644
> --- a/net/ipv6/datagram.c
> +++ b/net/ipv6/datagram.c
> @@ -123,11 +123,11 @@ ipv4_connected:
>              goto out;
>           }
>           sk->sk_bound_dev_if = usin->sin6_scope_id;
> -         if (!sk->sk_bound_dev_if &&
> -             (addr_type & IPV6_ADDR_MULTICAST))
> -            fl.oif = np->mcast_oif;
>        }
> 
> +      if (!sk->sk_bound_dev_if && (addr_type & IPV6_ADDR_MULTICAST))
> +         sk->sk_bound_dev_if = np->mcast_oif;
> +
>        /* Connect to link-local address requires an interface */
>        if (!sk->sk_bound_dev_if) {
>           err = -EINVAL;

