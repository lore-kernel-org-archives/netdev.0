From: Christoph Lameter <christoph@lameter.com>
Subject: Re: atomic_dec_and_test for child dst needed in dst_destroy?
Date: Thu, 7 Apr 2005 15:30:28 -0700 (PDT)
Message-ID: <Pine.LNX.4.58.0504071520050.3983@graphe.net>
References: <Pine.LNX.4.58.0504051925250.21486@graphe.net>
 <E1DJ5y2-0003rF-00@gondolin.me.apana.org.au> <20050406111721.3ac67605.davem@davemloft.net>
 <20050407110724.GA8760@gondor.apana.org.au> <Pine.LNX.4.58.0504070842420.29731@graphe.net>
 <20050407212504.GA4939@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        pravins@calsoftinc.com, shai@scalesx86.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050407212504.GA4939@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 8 Apr 2005, Herbert Xu wrote:

> Only child entries with NOHASH unset can be on the GC list.
>
> > If its not on the hash table and not on the gc list then how could the
> > refcnt be > 1 ? Doesnt the refcnt > 1 imply that multiple concurrent
> > accesses are possible?
>
> For NOHASH entries refcnt can be greater than one due to dst_pop.
> Of course concurrent access is possible.  However, the important
> thing is that only the "owner" of an entry can call dst_destroy.
>
> In the case of NOHASH entries, we are the owner.

So in case f.e. the refcnt was 2 for a child NOHASH entry, then we
decrement the refcnt for the child but do not free it. However after
dst_destroy the parent is gone and presumably some skb->dst are still
pointing to the dst entry (or is there something else accounting for the
remaining __refcnt)?

What happens to the child dst entry? Will the system simply never
deallocate it?
