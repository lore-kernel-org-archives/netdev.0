From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: atomic_dec_and_test for child dst needed in dst_destroy?
Date: Fri, 8 Apr 2005 09:07:38 +1000
Message-ID: <20050407230738.GA29330@gondor.apana.org.au>
References: <Pine.LNX.4.58.0504051925250.21486@graphe.net> <E1DJ5y2-0003rF-00@gondolin.me.apana.org.au> <20050406111721.3ac67605.davem@davemloft.net> <20050407110724.GA8760@gondor.apana.org.au> <Pine.LNX.4.58.0504070842420.29731@graphe.net> <20050407212504.GA4939@gondor.apana.org.au> <Pine.LNX.4.58.0504071520050.3983@graphe.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        pravins@calsoftinc.com, shai@scalesx86.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Lameter <christoph@lameter.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0504071520050.3983@graphe.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Apr 07, 2005 at 03:30:28PM -0700, Christoph Lameter wrote:
> 
> So in case f.e. the refcnt was 2 for a child NOHASH entry, then we
> decrement the refcnt for the child but do not free it. However after
> dst_destroy the parent is gone and presumably some skb->dst are still
> pointing to the dst entry (or is there something else accounting for the
> remaining __refcnt)?
> 
> What happens to the child dst entry? Will the system simply never
> deallocate it?

If the refcnt is non-zero after the atomic_dec and the entry is NOHASH,
we return it and the caller will add it to the GC list.

See the relevant section in dst_run_gc and dst_free.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
