From: "David S. Miller" <davem@davemloft.net>
Subject: Re: atomic_dec_and_test for child dst needed in dst_destroy?
Date: Wed, 6 Apr 2005 11:17:21 -0700
Message-ID: <20050406111721.3ac67605.davem@davemloft.net>
References: <Pine.LNX.4.58.0504051925250.21486@graphe.net>
	<E1DJ5y2-0003rF-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: christoph@lameter.com, herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1DJ5y2-0003rF-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 06 Apr 2005 18:32:54 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> In fact, the atomic_dec_and_test is really only needed for unhashed
> entries (i.e., IPsec).  So we could do something like this so that
> all hashed entries undergo atomic_dec.
> 
> This would only make sense if there were architectures where
> atomic_dec is significantly cheaper compared to atomic_dec_and_test.
> 
> Do such beasts exist?

See his other emails in this thread.  If it can be converted to
atomic_dec() then he wants to change the counter into an array
of counters on NUMA systems.

But his trick only works if the atomic_dec_and_test() can be eliminated
for all cases, which we're now quite certain is not possible.
