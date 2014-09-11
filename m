From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv6: implement rt_genid_bump_ipv6 with
 fn_sernum and remove rt6i_genid
Date: Thu, 11 Sep 2014 10:30:07 +0200
Message-ID: <1410424207.2672.21.camel@localhost>
References: <1410267519.27979.31.camel@localhost>
	 <130f98f49b1b90a30908bfda8f01109c91edfe1c.1410341451.git.hannes@stressinduktion.org>
	 <20140910.130929.247064282043941043.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	nicolas.dichtel@6wind.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:53495 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753406AbaIKIaL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 04:30:11 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by gateway2.nyi.internal (Postfix) with ESMTP id B6BD720AF6
	for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 04:30:10 -0400 (EDT)
In-Reply-To: <20140910.130929.247064282043941043.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mi, 2014-09-10 at 13:09 -0700, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Wed, 10 Sep 2014 11:31:28 +0200
> 
> > In case we need to force the sockets to relookup the routes we now
> > increase the fn_sernum on all fibnodes in the routing tree. This is a
> > costly operation but should only happen if we have major routing/policy
> > changes in the kernel (e.g. manual route adding/removal, xfrm policy
> > changes).
> 
> Core routers can update thousands of route updates per second, and they
> do this via what you refer to as "manual route adding/removal".

Sorry, I was too unspecific here. Route changes because of address
removal/addition on the local stack.

The reason why we do the bump_id here is that we want to flush all the
socket caches in case we have either lost or gained access to a new
source address.

If you think about e.g. BGP routers which update lots of routes, they
aren't affected and the flush won't happen on every route change.

> I don't think we want to put such a scalability problem into the tree.
> 
> There has to be a lightweight way to address this.

I am still investigating why this bump_id actually happened. Seems the
reason is only sctp ontop of IPv6 and maybe we can build something much
more lightweight, yes.

Thanks,
Hannes
