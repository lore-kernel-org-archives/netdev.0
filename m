From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] route: Remove redirect_genid
Date: Sun, 04 Mar 2012 21:55:05 -0500 (EST)
Message-ID: <20120304.215505.1141896485416671142.davem@davemloft.net>
References: <20120301062159.GB15404@secunet.com>
	<20120301062316.GD15404@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47916 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751949Ab2CECzX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2012 21:55:23 -0500
In-Reply-To: <20120301062316.GD15404@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 1 Mar 2012 07:23:16 +0100

>  				peer = rt->peer;
> -				if (peer) {
> -					if (peer->redirect_learned.a4 != new_gw ||
> -					    peer->redirect_genid != redirect_genid) {
> -						peer->redirect_learned.a4 = new_gw;
> -						peer->redirect_genid = redirect_genid;
> -						atomic_inc(&__rt_peer_genid);
> -					}
> -					check_peer_redir(&rt->dst, peer);
> +				if (peer && peer->redirect_learned.a4 != new_gw) {
> +					peer->redirect_learned.a4 = new_gw;
> +					atomic_inc(&__rt_peer_genid);
>  				}
> +				check_peer_redir(&rt->dst, peer);
>  			}

If peer is NULL you cannot call check_peer_redir() because it assumes
that the passed in peer is non-NULL and dereferences it unconditionally.

Please keep the conditionals as they were, the check_peer_redir() call
was intentionally protected by the if (peer) check, and that way you
won't be introducing this bug.
