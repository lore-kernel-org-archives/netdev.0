From: "Milam, Chad" <Chad_Milam@nyc.yr.com>
Subject: RE: dst cache overflow 2.2.x; x>=16
Date: Mon, 15 Apr 2002 11:21:07 -0400
Sender: owner-netdev@oss.sgi.com
Message-ID: <D4CA6B275AA33241AC771F0C0B43A921011BE868@nyc285ex01.nyc.corp.yr.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Return-path: <owner-netdev@oss.sgi.com>
content-class: urn:content-classes:message
To: <netdev@oss.sgi.com>
List-Id: netdev.vger.kernel.org

Robert Olson writes:
> jamal writes:
>  >
>  > If i summarize your problem is that you are building up
>  > dst caches faster than they can be garbage collected.
>  >
>  > Solution
>  > 1. Make the max size large enough to catchup with rate
>  > 2. Make sure that every time you go into garbage collection you are
>  > successful.
>  > - reducing the min interval to 1 might be a little aggressive.
>  > But you can tune this later
>  > - You wanna make sure you get a large positive "goal" every time
>  > play with ip_rt_gc_elasticity (/proc/sys/net/ipv4/route/gc_elasticity)
>  > also the rt_hash_log
>  >
>  > All the above are configurable via /proc
>  >
>  > have to run
> 
>  And in in 2.4.X the GC is done more dynamically around an "equilibrium point".
>  Alexey warned about 2.2 code...
> 
>  Snaphot from Linux router. 2.4.10
> 
>  cat /proc/sys/net/ipv4/route/max_size
>  65536
> 
>  rtstat
>  size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot     mc
> 
>  1:st  ipv4_dst_ops.entries. (You see GC happen)
>  2:nd: Warm cache hits -> approx aggregated packet/sec.
>  3:rd: Cache misses    -> approx connections/sec.

unfortunately I cannot move my Check Point boxes to 2.4.x yet.  Maybe this will come 
in the future.

At the end of the day, my patch was not trying to avoid GC, or eliminate it.  It was just 
there to keep the box from going completely dead... it accomplishes exactly that.  I 
have run it now for about a week, and the box has not had to be restarted, where as with
out it, I would have restarted once per day. Even with route/max_size set to 65536,
I had to restart about every two weeks.

I am also not suggesting that GC does not work, it does (for the most part). What I am 
trying to say is that there is a condition (still working on that bit) that keeps the 
.entries counter from decreasing to what it should be.  Something, some process, is 
leaking routes (at least into the counter).  This is where my problem is.  And the patch
works around that, by setting the cache to zero, and starting over. Which, again, is better
than restarting.

Thanks again,
chad
