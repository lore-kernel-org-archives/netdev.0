From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: (diet-)FIB alternative fib_hlist.c
Date: Wed, 4 May 2005 22:10:31 +0200
Message-ID: <17017.11319.855946.521718@robur.slu.se>
References: <17016.62444.34282.625407@robur.slu.se>
	<m1zmvax2cx.fsf@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, Jens.Laas@data.slu.se,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <m1zmvax2cx.fsf@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Andi Kleen writes:

 > Great patch! I wanted to do something like this for a long time :/
 > It is a good solution for 99.999% of all users who never have more
 > than a few routes.
 > 
 > Random comments while reading the code:
 > 
 > I would perhaps add a printk that warns the user if there are
 > more than 10 routes or so to use a different FIB.

 When we find the break-even point we can a print warning at insertions
 above this point. A minor problem.

 > Also I would try to replace the write locks with normal spinlocks.
 > read/write locks should not be needed for the use case of a normal
 > client who basically never changes the routing table, and normal
 > spinlocks are more friendly to modern cache coherency protocols.

 Interesting. I'll guess this goes for all FIB variants. Needs some 
 experimentation.

 > With only a few routes it is overkill to have two kmem caches,
 > which both need at least a page each. With 10-20 routes you
 > waste half the memory because of that. Better use a single 
 > slab cache for both object types or just kmalloc.

 Doable. slab objects are nice & easy to monitor during development.

 > Now we only need support for loadable fibs, then
 > distributions could use this too. Loadable ones should
 > be pretty easy, as long as you dont try to make them unloadable.

  First step yes. Also we need hi-pref system to have multiple 
  FIB variants. Just attack it if got some ideas.

 > The later would need a lot of reference counting in fast paths,
 > which would be probably a bad idea. And losing that capability
 > is not a big issue.

 Yes leave that out for now.

 Cheers.
					--ro

 
