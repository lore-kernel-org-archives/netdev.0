From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v3 2/7] vxlan: avoid checking socket multiple
 times.
Date: Tue, 15 Nov 2016 15:15:56 +0100
Message-ID: <20161115151556.60bf4b99@griffin>
References: <1479098638-4921-1-git-send-email-pshelar@ovn.org>
        <1479098638-4921-3-git-send-email-pshelar@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53120 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932406AbcKOOP7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 09:15:59 -0500
In-Reply-To: <1479098638-4921-3-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pravin,

please CC reviewers of the previous version when submitting a new
version. You'll get faster reviews that way.

On Sun, 13 Nov 2016 20:43:53 -0800, Pravin B Shelar wrote:
> @@ -2069,11 +2069,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
>  		struct dst_entry *ndst;
>  		u32 rt6i_flags;
>  
> -		if (!sock6)
> -			goto drop;
> -		sk = sock6->sock->sk;
> -
> -		ndst = vxlan6_get_route(vxlan, skb,
> +		ndst = vxlan6_get_route(vxlan, sock6, skb,
>  					rdst ? rdst->remote_ifindex : 0, tos,
>  					label, &dst->sin6.sin6_addr,
>  					&src->sin6.sin6_addr,
> @@ -2093,6 +2089,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
>  			goto tx_error;
>  		}
>  
> +		sk = sock6->sock->sk;
>  		/* Bypass encapsulation if the destination is local */
>  		rt6i_flags = ((struct rt6_info *)ndst)->rt6i_flags;
>  		if (!info && rt6i_flags & RTF_LOCAL &&

This moves the sk assignment from one arbitrary place to a different
arbitrary place, while it would be best to just remove it and open code
sock6->sock->sk in the call to udp_tunnel6_xmit_skb. But patch 6 does
that later, so whatever.

Acked-by: Jiri Benc <jbenc@redhat.com>
