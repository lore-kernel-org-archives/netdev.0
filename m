From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [BUG] overflow in net/ipv4/route.c rt_check_expire()
Date: Sat, 2 Apr 2005 16:46:31 +0200
Message-ID: <16974.45127.318022.377635@robur.slu.se>
References: <E1DHdsP-0003Lr-00@gondolin.me.apana.org.au>
	<424E641A.1020609@cosmosbay.com>
	<16974.41648.568927.54429@robur.slu.se>
	<424EA7C2.6060308@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <424EA7C2.6060308@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Eric Dumazet writes:

 > Well... yes. This is a real server, not a DOS simulation.
 > 1 million TCP flows, and about 3 million peers using UDP frames.

 I see.

 > >  What's your ip_rt_gc_min_interval? GC should be allowed to 
 > >  run frequent to smoothen out the GC load. Also good idea 
 > >  to decrease gc_thresh and you hash is really huge.

 > No. As soon as I lower gc_thresh (and let gc running), the machine starts to drop connections and crash some seconds later.
 > I found I had to make the hash table very large (but lowering elasticity, ie chain length) .
 > It needs lot of ram, but at least CPU usage of net/ipv4/route.c is close to 0.

 OK! Not so bad. Most of your GC likely happens in rt_intern_hash chain pruning.
 This way you keep hash-chains short and get "datadriven" GC. But there must be 
 bugs causing the crash...
 
 Maybe there should be an explicit control hash lengths not via elasticity 
 but adding even more tuning knobs hurts. :)

						--ro
