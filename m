From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPSEC]: Kill nested read lock by deleting xfrm_init_tempsel
Date: Sat, 2 Apr 2005 12:09:47 +1000
Message-ID: <20050402020947.GA24998@gondor.apana.org.au>
References: <20050214221200.GA18465@gondor.apana.org.au> <20050214221433.GB18465@gondor.apana.org.au> <20050214221607.GC18465@gondor.apana.org.au> <424864CE.5060802@trash.net> <20050328233917.GB15369@gondor.apana.org.au> <424B40C2.90304@trash.net> <20050331004658.GA26395@gondor.apana.org.au> <20050331212325.5e996432.davem@davemloft.net> <20050402004956.GA24339@gondor.apana.org.au> <20050401172007.7296eced.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, kuznet@ms2.inr.ac.ru, jmorris@redhat.com,
        yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050401172007.7296eced.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Apr 01, 2005 at 05:20:07PM -0800, David S. Miller wrote:
> On Sat, 2 Apr 2005 10:49:56 +1000
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > The second patch creates a dead lock since it does a nested read
> > lock.  The solution is simply to get rid of xfrm_init_tempsel
> > and call the afinfo version directly.
> 
> read locks nest even in the presence of pending writers

Doh! I should've read the code first :)

It's still a valid clean-up patch though.

There is another reason why it won't dead lock.  We don't actually
ever hold the write lock on afinfo :) Is there any reason why we
dont't just use xfrm_state_afinfo_lock instead of afinfo->lock?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
