From: Steven Whitehouse <swhiteho@redhat.com>
Subject: Re: [PATCH] decnet: Don't set RTCF_DIRECTSRC.
Date: Tue, 24 Jul 2012 09:14:04 +0100
Message-ID: <1343117644.2712.1.camel@menhir>
References: <20120723.131739.2064070169913079873.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56984 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755365Ab2GXIPc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2012 04:15:32 -0400
In-Reply-To: <20120723.131739.2064070169913079873.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, 2012-07-23 at 13:17 -0700, David Miller wrote:
> It's an ipv4 defined route flag, and only ipv4 uses it.
> 
This flag was really just being used to tag cached (direct) routes for
debugging purposes, so looks good to me.

Acked-by: Steven Whitehouse <swhiteho@redhat.com>

Steve.

> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/decnet/dn_route.c |    2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
> index 23cc11d..85a3604 100644
> --- a/net/decnet/dn_route.c
> +++ b/net/decnet/dn_route.c
> @@ -1424,7 +1424,6 @@ static int dn_route_input_slow(struct sk_buff *skb)
>  		/* Packet was intra-ethernet, so we know its on-link */
>  		if (cb->rt_flags & DN_RT_F_IE) {
>  			gateway = cb->src;
> -			flags |= RTCF_DIRECTSRC;
>  			goto make_route;
>  		}
>  
> @@ -1437,7 +1436,6 @@ static int dn_route_input_slow(struct sk_buff *skb)
>  
>  		/* Close eyes and pray */
>  		gateway = cb->src;
> -		flags |= RTCF_DIRECTSRC;
>  		goto make_route;
>  	default:
>  		goto e_inval;
