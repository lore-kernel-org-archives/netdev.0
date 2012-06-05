From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] inetpeer: fix a race in inetpeer_gc_worker()
Date: Tue, 5 Jun 2012 14:42:57 +0200
Message-ID: <20120605124257.GE27795@secunet.com>
References: <1338888507.2760.2146.camel@edumazet-glaptop>
 <20120605115640.GC27795@secunet.com>
 <1338898752.2760.2482.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53414 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751371Ab2FEMnD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jun 2012 08:43:03 -0400
Content-Disposition: inline
In-Reply-To: <1338898752.2760.2482.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 05, 2012 at 02:19:12PM +0200, Eric Dumazet wrote:
> On Tue, 2012-06-05 at 13:56 +0200, Steffen Klassert wrote:
> > On Tue, Jun 05, 2012 at 11:28:27AM +0200, Eric Dumazet wrote:
> > > From: Eric Dumazet <edumazet@google.com>
> > > 
> > > commit 5faa5df1fa2024 (inetpeer: Invalidate the inetpeer tree along with
> > > the routing cache) added a race :
> > > 
> > > Before freeing an inetpeer, we must respect a RCU grace period, and make
> > > sure no user will attempt to increase refcnt.
> > > 
> > 
> > As already mentioned in the other mail. In this case, I think
> > we can just delete the inetpeer once the refcount got zero.
> > 
> 
> Nope, a concurrent lookup can find an entry about to be freed.

Hm, I agree that we need rcu protection when we remove single entries
from an inetpeer tree. But in this case we invalidate the entire tree.

The first lookup after inetpeer_invalidate_tree() was invoked should
find an empty tree, base->root initialized to peer_avl_empty_rcu.

Maybe I'm wrong, but I don't see how a lookup should find such an
old invalidated tree.
