From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [BUG] overflow in net/ipv4/route.c rt_check_expire()
Date: Sat, 2 Apr 2005 15:48:32 +0200
Message-ID: <16974.41648.568927.54429@robur.slu.se>
References: <E1DHdsP-0003Lr-00@gondolin.me.apana.org.au>
	<424E641A.1020609@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
        netdev@oss.sgi.com, Robert.Olsson@data.slu.se
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <424E641A.1020609@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Eric Dumazet writes:

 > > This patch is doing too many things.  How about splitting it up?
 > > 
 > > For instance the spin lock stuff is pretty straightforward and
 > > should be in its own patch.

 Yes a good idea so it can be tested separatly....

 > > The benefits of the GC changes are not obvious to me.  rt_check_expire
 > > is simply meant to kill off old entries.  It's not really meant to be
 > > used to free up entries when the table gets full.


 Agree with Herbert... 

 >   entries|  in_hit|in_slow_|in_slow_|in_no_ro|  in_brd|in_marti|in_marti| 
 > out_hit|out_slow|out_slow|gc_total|gc_ignor|gc_goal_|gc_dst_o|in_hlist|out_hlis|
 >          |        |     tot|      mc|     ute|        |  an_dst|  an_src|        |    _tot|     _mc|        |      ed|    miss| verflow| 
 > _search|t_search|
 >   2618087|   28581|    7673|       0|       0|       0|       0|       0|    1800|    1450|       0|       0|       0|       0|       0| 


 > Without serious tuning, this machine could not handle this load, or even half of it.
 
 Yes thats a pretty much load. Very short flows some reason? 
 What's your ip_rt_gc_min_interval? GC should be allowed to 
 run frequent to smoothen out the GC load. Also good idea 
 to decrease gc_thresh and you hash is really huge.

 
 > Crashes usually occurs when secret_interval interval is elapsed : rt_cache_flush(0); is called, and the whole machine begins to die.

 A good idea to increase the secret_interval interval but it should survive.

						--ro
