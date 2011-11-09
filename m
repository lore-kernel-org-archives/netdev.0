From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 3/4] ipv4: Fix inetpeer expiration handling
Date: Wed, 9 Nov 2011 13:47:38 +0100
Message-ID: <20111109124738.GC10138@secunet.com>
References: <20111011110842.GC1830@secunet.com>
 <20111011111122.GF1830@secunet.com>
 <4E9FBEA1.2050407@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:39617 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753982Ab1KIMrn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Nov 2011 07:47:43 -0500
Content-Disposition: inline
In-Reply-To: <4E9FBEA1.2050407@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 20, 2011 at 02:24:33PM +0800, Gao feng wrote:
> 
> there are serval problem.
> 1:rt->peer maybe null,we should call rt_bind_peer just like the code below.

If rt->peer is NULL, rt_bind_peer() sets rt->rt_peer_genid = rt_peer_genid().
So your check for rt->rt_peer_genid != rt_peer_genid() is false then and
creates cases where an unchecked peer is bound to a route.

> 2:rt->peer_pmtu_orig is null. if we hasn't send packet before,the func check_peer_pmtu hasn't be called.
>   so the peer->pmtu_orig is null.

If a peer is bound to a route during slow path route lookup, the peer
should be properly initialized with rt_init_metrics(). So
rt->peer_pmtu_orig should not be null here as far as I can see.

I still think that my original patch fixes the problem.
