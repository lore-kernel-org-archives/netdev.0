From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [BUG] overflow in net/ipv4/route.c rt_check_expire()
Date: Mon, 4 Apr 2005 12:27:43 +0200
Message-ID: <16977.5791.367581.655483@robur.slu.se>
References: <E1DHdsP-0003Lr-00@gondolin.me.apana.org.au>
	<424E641A.1020609@cosmosbay.com>
	<16974.41648.568927.54429@robur.slu.se>
	<20050402193224.GA25157@gondor.apana.org.au>
	<20050402115528.11f71a3c.davem@davemloft.net>
	<20050403074337.GA8083@gondor.apana.org.au>
	<16976.19092.562006.246545@robur.slu.se>
	<20050403214521.GB15901@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        "David S. Miller" <davem@davemloft.net>, dada1@cosmosbay.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050403214521.GB15901@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Herbert Xu writes:

 > The reason I'm suggesting the move to a kernel thread is because
 > softirq context is not preemptible.
 > 
 > So doing a large amount of work in it when your table is big means
 > that a UP machine will freeze for a while.

 The flush transient will happen also on UP... as I understand this 
 When we have changed the rt_hash_rnd and therefore invalidated all current 
 entries it would be best to blackhole *all* traffic until all old entries 
 are deleted this to avoid transients.

						--ro


 
