From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [PATCH] option for large routing hash
Date: Sat, 13 Dec 2003 00:10:16 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16346.19160.434671.377642@robur.slu.se>
References: <16343.12816.917811.588853@robur.slu.se>
	<20031210150537.5fd0edb0.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, kuznet@ms2.inr.ac.ru,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031210150537.5fd0edb0.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


David S. Miller writes:

 > I wish we had resolved that in the long thread we had about it
 > a few months ago.  We should really reestablish the point we had
 > reached, and try to make some more forward progress.
 > 
 > This problem is not going to go away, as you say.

 No I will not. I revisited the patches and they seems to some help but 
 here must be some other problem too. Seems we have to start over. Well 
 let me add the patch with the debugging from Sarma to start with. At 
 least there is no problem to trigger the overflows.


 > I think I see what you're saying though, and in my opinion there
 > is way too much black magic in choosing gc_thresh etc. routing cache
 > parameters.
 > 
 > Other caches in the kernel grow to fill the needs of the system.  The
 > routing cache grows only as large as it has been configured to be
 > allowed to grow, and afterwards it no longer responds to increasing
 > system needs.
 > 
 > The IPV4 routing front end has exactly this kind of logic.  As you
 > load more and more routing table entries into the kernel it grows
 > the hashes in response.
 > 
 > > So it crucial to distinguish between the cases. Can it be done from
 > > incoming traffic? 
 > 
 > This is the real question, and the other is how to implement dynamic
 > hash table growth in the routing cache.  The locking is particularly
 > problematic, but RCU may be able to help us with this.
 > 
 > Monitoring traffic to make this decision is hard because to determine
 > whether cache misses are due to not well formed traffic vs. too small
 > cache sizing we'd need the entry we garbage collected to determine the
 > latter.  It's the chicken and egg problem.

 Yes. Well for desktop systems and system with not too much flows there is 
 no problem. For hi-flow servers and routers we should expect administrators
 do some manual setup according their environment. As we started this
 thread IMO increasing just hash size is the most continent in this case
 a as most routing cache parameters is derived from it so the black
 magic is untouched but still doing it's magic. We have used this for some
 time on our routers. Of course things can be done better but RCU is probably 
 the most annoying for now.

 Cheers.
						--ro
