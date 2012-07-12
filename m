From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 05/16] ipv4: Generalize ip_do_redirect() and hook into
 new dst_ops->redirect.
Date: Thu, 12 Jul 2012 02:05:25 -0700
Message-ID: <1342083925.7969.6.camel@joe2Laptop>
References: <20120712.011108.1163869605581840179.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:34464 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933143Ab2GLJFZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jul 2012 05:05:25 -0400
In-Reply-To: <20120712.011108.1163869605581840179.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-12 at 01:11 -0700, David Miller wrote:
> All of the redirect acceptance policy is now contained within.
[]
> @@ -1271,42 +1273,18 @@ static void rt_del(unsigned int hash, struct rtable *rt)
>  	spin_unlock_bh(rt_hash_lock_addr(hash));
>  }
>  
> -static void ip_do_redirect(struct rtable *rt, __be32 old_gw, __be32 new_gw)
> -{
> -	struct neighbour *n;
> -
> -	if (rt->rt_gateway != old_gw)
> -		return;
> -
> -	n = ipv4_neigh_lookup(&rt->dst, NULL, &new_gw);
> -	if (n) {
> -		if (!(n->nud_state & NUD_VALID)) {
> -			neigh_event_send(n, NULL);
> -		} else {
> -			rt->rt_gateway = new_gw;
> -			rt->rt_flags |= RTCF_REDIRECTED;
> -			call_netevent_notifiers(NETEVENT_NEIGH_UPDATE, n);
> -		}
> -		neigh_release(n);
> -	}
> -}

Oh well, nevermind about the comment I made in 3/6.
I should read the whole thing first.
