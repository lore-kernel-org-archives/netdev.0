From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [BUG] overflow in net/ipv4/route.c rt_check_expire()
Date: Mon, 4 Apr 2005 15:17:12 +0200
Message-ID: <16977.15960.242211.442811@robur.slu.se>
References: <E1DHdsP-0003Lr-00@gondolin.me.apana.org.au>
	<424E641A.1020609@cosmosbay.com>
	<16974.41648.568927.54429@robur.slu.se>
	<20050402193224.GA25157@gondor.apana.org.au>
	<16976.17876.832677.945878@robur.slu.se>
	<20050403214358.GA15901@gondor.apana.org.au>
	<16977.6411.415326.988754@robur.slu.se>
	<20050404104857.GA32359@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        Eric Dumazet <dada1@cosmosbay.com>, davem@davemloft.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050404104857.GA32359@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Herbert Xu writes:

 > What I'm trying to catch is the case when you've got x number of
 > entries in the table and a large fraction of them are all in one
 > chain.
 > 
 > This does not conflict with the goal of keeping the chains short.
 > 
 > Even if you strictly allow only 8 entries per chain, it's trivial
 > to exceed 8 times the average chain length.

 OK! Since deletions doen't happen instantly..
 
 Try some code it can print a warning to start with.


 > >  IMO the thoughts of extending in-flow GC etc are interesting and can
 > >  hopefully give us more robust performance.
 > 
 > Indeed, it looks like Alexey has already put the code there.  It just
 > needs to be made more strict :) It needs to free entries even if they
 > are in use.
 > 
 > After all, freeing an entry in use can't be much worse than not having
 > a cache at all.  OTOH, having a very long chain is definitely much worse
 > than not having a cache :)

 FYI I'm experimenting with "new" routing algo that does 24-bit ipv4 lookup 
 and routing without route hash to see if we can come close route hash
 performance  This needs memory. :)

 IP: FIB routing table of 16777216 buckets, 65536Kbytes for table id=255

 Needs some more work before testing.

						--ro
