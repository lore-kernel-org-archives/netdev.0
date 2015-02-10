From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH] ipv6: Partial checksum only UDP packets
Date: Tue, 10 Feb 2015 17:23:12 +0100
Message-ID: <20150210162312.GB3372@kria>
References: <20150210140704.GA3372@kria>
 <1423583752-31932-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, Vladislav Yasevich <vyasevic@redhat.com>
To: Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:58212 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751012AbbBJQXS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Feb 2015 11:23:18 -0500
Content-Disposition: inline
In-Reply-To: <1423583752-31932-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-02-10, 10:55:52 -0500, Vladislav Yasevich wrote:
> ip6_append_data is used by other protocols and some of them can't
> be partially checksummed.  Only partially checksum UDP protocol.
> 
> Fixes: 32dce968dd987a (ipv6: Allow for partial checksums on non-ufo packets)
> Reported-by: Sabrian Dubroca <sd@queasysnail.net>

not a big deal, but since there's a small problem with this version
(see below):

s/Sabrian/Sabrina/

> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
> ---
> Hi Sabrina
> 
> Can you try this patch.  Thanks.
> 
>  net/ipv6/ip6_output.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index d33df4c..8f2d558 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -1273,7 +1273,7 @@ emsgsize:
>  	/* If this is the first and only packet and device
>  	 * supports checksum offloading, let's use it.
>  	 */
> -	if (!skb &&
> +	if (!skb && sk->protocol == IPPROTO_UDP &&
                        ^^^

should be  sk->sk_protocol


And you can add:

Tested-by: Sabrina Dubroca <sd@queasysnail.net>


Thanks Vlad!

>  	    length + fragheaderlen < mtu &&
>  	    rt->dst.dev->features & NETIF_F_V6_CSUM &&
>  	    !exthdrlen)
> -- 
> 1.9.3


-- 
Sabrina
