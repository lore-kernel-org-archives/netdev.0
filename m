From: "David S. Miller" <davem@davemloft.net>
Subject: Re: neigh_create/inetdev_destroy race?
Date: Mon, 30 Aug 2004 23:08:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040830230820.7514985d.davem@davemloft.net>
References: <20040814003428.GA17760@gondor.apana.org.au>
	<20040813173924.6d05be15.davem@redhat.com>
	<20040814005411.GA18350@gondor.apana.org.au>
	<20040814012513.GA721@gondor.apana.org.au>
	<20040814013030.GA2042@gondor.apana.org.au>
	<20040814050848.GA11874@gondor.apana.org.au>
	<20040814062703.GA4806@gondor.apana.org.au>
	<20040815191450.77532d5d.davem@redhat.com>
	<20040816105131.GA11299@gondor.apana.org.au>
	<20040828234201.79556f6e.davem@davemloft.net>
	<20040829065031.GA786@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040829065031.GA786@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 29 Aug 2004 16:50:31 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> > Secondly, until neigh_create() takes the tbl lock, it is not in
> > the hash tables and therefore neigh_ifdown() could not see it.
> 
> That part I agree with :) That's in fact what this race is about:
> neigh_ifdown does not guarantee that the hash table will be without
> references to idev.

I think we can clear this by putting neigh_parms_release() into an
RCU handler.  It can't be in in_dev_rcu_put.

I also now believe that these sorts of races you are mentioning percolate
out into ip_mc_destroy_dev().
