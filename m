From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: 2.6.0-test11: dst_cache_overflow causing unresponsive box
Date: Tue, 2 Dec 2003 11:44:31 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16332.27919.502097.988522@robur.slu.se>
References: <072501c3b874$2542ae70$15fea8c0@fortress>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Francois Baligant" <francois@baligant.net>
In-Reply-To: <072501c3b874$2542ae70$15fea8c0@fortress>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Francois Baligant writes:
 > We have a problem with a box running 2.6.0-test11-mjb1 and supporting around 90k simultaneous TCP connection. After a few hours/days of running,
 > when a lots of clients connects/disconnects, the console will start to display:
 > 
 > dst cache overflow
 > NET: 1860 messages suppressed.
 > 
 > >From there, the box is completely unresponsive, apparently eating all its CPU in trying to shrink the routing cache. Only solution is reboot.

 > Current sysctl:
 > net.ipv4.route.max_size = 655360 # I know we shouldn't rise it that high but it's only cure for now.. it lasts a bit longer like this

 >  size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot     mc GC: tot ignored goal_miss ovrf HASH: in_search out_search
 > 139566     12393     123     0     0     0     0     0       184      21      0     143     142         0    0           26039        375


 >   OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME                   
 > 142340 142296  99%    0.38K  14234       10     56936K ip_dst_cache
 > 
 > Are we tuning the rt_cache in a wrong way ?

No experience with 90k TCP-flows but it seems GC is not able to free some 
the dst-entries for some reason. This will slowly kill your box with 
symptoms you describe. We have ask TCP-experts for timer settings to avoid
pending sessions etc. Also check slab for any other objects growing as 
dst cache overflow is most likely secondary effect in your case. rtstat 
looks sane expect for the high number of dst-entries. Tuning is another 
story.

Cheers.
						--ro
