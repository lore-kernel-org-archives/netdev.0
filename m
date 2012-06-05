From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] inetpeer: fix a race in inetpeer_gc_worker()
Date: Tue, 5 Jun 2012 15:01:42 +0200
Message-ID: <20120605130142.GF27795@secunet.com>
References: <1338888507.2760.2146.camel@edumazet-glaptop>
 <20120605115640.GC27795@secunet.com>
 <1338898752.2760.2482.camel@edumazet-glaptop>
 <20120605124257.GE27795@secunet.com>
 <1338900966.2760.2596.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53723 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756194Ab2FENBy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jun 2012 09:01:54 -0400
Content-Disposition: inline
In-Reply-To: <1338900966.2760.2596.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 05, 2012 at 02:56:06PM +0200, Eric Dumazet wrote:
> On Tue, 2012-06-05 at 14:42 +0200, Steffen Klassert wrote:
> > 
> > Hm, I agree that we need rcu protection when we remove single entries
> > from an inetpeer tree. But in this case we invalidate the entire tree.
> > 
> > The first lookup after inetpeer_invalidate_tree() was invoked should
> > find an empty tree, base->root initialized to peer_avl_empty_rcu.
> > 
> > Maybe I'm wrong, but I don't see how a lookup should find such an
> > old invalidated tree.
> > 
> 
> You are absolutely wrong yes.
> 
> A concurrent lookup can read previous values of the root pointer, even
> if you wrote a new value in it. Thats whole RCU point.

Argh, yes. You are absolutely right of course, now I got it :)
Thanks for your explaination.
