From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [BUG] overflow in net/ipv4/route.c rt_check_expire()
Date: Mon, 4 Apr 2005 14:29:33 +0200
Message-ID: <16977.13101.410241.382741@robur.slu.se>
References: <E1DHdsP-0003Lr-00@gondolin.me.apana.org.au>
	<424E641A.1020609@cosmosbay.com>
	<16974.41648.568927.54429@robur.slu.se>
	<20050402193224.GA25157@gondor.apana.org.au>
	<20050402115528.11f71a3c.davem@davemloft.net>
	<20050403074337.GA8083@gondor.apana.org.au>
	<16976.19092.562006.246545@robur.slu.se>
	<20050403214521.GB15901@gondor.apana.org.au>
	<16977.5791.367581.655483@robur.slu.se>
	<20050404103814.GA32269@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        "David S. Miller" <davem@davemloft.net>, dada1@cosmosbay.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050404103814.GA32269@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Herbert Xu writes:

 > That's nasty because if you have a large cache like Eric, then you'll
 > be dropping packets for quite a while :)
 > 
 > Actually, what's so bad about seeing transients? One cost that
 > I can see is that you'll be walking a chain only to conclude that
 > none of the entries might match.  But this is pretty cheap as long as
 > we keep the chain lengths short.
 > 
 > The other cost is that we might be creating an entry that gets flushed
 > straight away.  However, that's no worse than not using the cache at
 > all since in that case we'll be creating one entry for each packet
 > anyway.

 Maybe you're right and systems seems to survive. But the transit period
 should be as short as possible. 

 > Both of these can be avoided too if we really cared.  All we need
 > is one bit per chain that indicated whether it's been flushed.  So
 > when ip_route_* hits a chain that hasn't been flushed, it could
 > 
 > 1) Skip the lookup step.
 > 2) Create the rt entry as usual.
 > 3) Flush the chain while we insert the entry and set the bit.

 Yes better was thinking of something like this too.


					   --ro
