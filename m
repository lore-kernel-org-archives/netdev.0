From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [BUG] overflow in net/ipv4/route.c rt_check_expire()
Date: Mon, 4 Apr 2005 12:38:03 +0200
Message-ID: <16977.6411.415326.988754@robur.slu.se>
References: <E1DHdsP-0003Lr-00@gondolin.me.apana.org.au>
	<424E641A.1020609@cosmosbay.com>
	<16974.41648.568927.54429@robur.slu.se>
	<20050402193224.GA25157@gondor.apana.org.au>
	<16976.17876.832677.945878@robur.slu.se>
	<20050403214358.GA15901@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        Eric Dumazet <dada1@cosmosbay.com>, davem@davemloft.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050403214358.GA15901@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Herbert Xu writes:

 > The only way to attack a hash is by exploiting collisions and
 > create one or more excessively long chains.
 > 
 > This can be detected as follows at each rt hash insertion.  If
 > 
 > (total number of entries in cache >> (hash length - user defined length)) <
 > current bucket length
 > 
 > is true, then we schedule a rehash/flush.
 > 
 > Hash length is the number of bits in the hash, i.e.,
 > 
 > 1 << hash length == number of buckets
 > 
 > I'd suggest a default shift length of 3.  That is, if any individual
 > chain is growing beyond 8 times the average chain length then we've
 > got a problem.

 This is likely to happen in rt_intern_hash? I don't see how this can
 get along with chain-pruning there?

 IMO the thoughts of extending in-flow GC etc are interesting and can
 hopefully give us more robust performance.

					--ro
