From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv6: implement rt_genid_bump_ipv6 with fn_sernum
 and remove rt6i_genid
Date: Thu, 11 Sep 2014 14:40:05 +0200
Message-ID: <1410439205.3507941.166282025.4D4C5695@webmail.messagingengine.com>
References: <1410267519.27979.31.camel@localhost>
 <130f98f49b1b90a30908bfda8f01109c91edfe1c.1410341451.git.hannes@stressinduktion.org>
 <20140910.130929.247064282043941043.davem@davemloft.net>
 <1410424207.2672.21.camel@localhost> <54119409.20907@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	nicolas.dichtel@6wind.com
To: Vlad Yasevich <vyasevich@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:57703 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754784AbaIKMkG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 08:40:06 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by gateway2.nyi.internal (Postfix) with ESMTP id 2C34020C5E
	for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 08:40:06 -0400 (EDT)
In-Reply-To: <54119409.20907@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 11, 2014, at 14:22, Vlad Yasevich wrote:
> On 09/11/2014 04:30 AM, Hannes Frederic Sowa wrote:
> > On Mi, 2014-09-10 at 13:09 -0700, David Miller wrote:
> >> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> >> Date: Wed, 10 Sep 2014 11:31:28 +0200
> >>
> >>> In case we need to force the sockets to relookup the routes we now
> >>> increase the fn_sernum on all fibnodes in the routing tree. This is a
> >>> costly operation but should only happen if we have major routing/policy
> >>> changes in the kernel (e.g. manual route adding/removal, xfrm policy
> >>> changes).
> >>
> >> Core routers can update thousands of route updates per second, and they
> >> do this via what you refer to as "manual route adding/removal".
> > 
> > Sorry, I was too unspecific here. Route changes because of address
> > removal/addition on the local stack.
> > 
> > The reason why we do the bump_id here is that we want to flush all the
> > socket caches in case we have either lost or gained access to a new
> > source address.
> > 
> > If you think about e.g. BGP routers which update lots of routes, they
> > aren't affected and the flush won't happen on every route change.
> > 
> >> I don't think we want to put such a scalability problem into the tree.
> >>
> >> There has to be a lightweight way to address this.
> > 
> > I am still investigating why this bump_id actually happened. Seems the
> > reason is only sctp ontop of IPv6 and maybe we can build something much
> > more lightweight, yes.
> 
> No.  It was proven that a regular TCP socket could continue sending
> traffic using an address that was removed.

I have seen the original discussion regarding SCTP. I still think the
reason for this is that we don't update fn_sernum during pruning clones
from the trie.

Bye,
Hannes
