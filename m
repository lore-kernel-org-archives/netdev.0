From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: net/ipv4/route.c GC patch: is this insane?
Date: Mon, 31 May 2004 14:21:02 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16571.9006.703294.10134@robur.slu.se>
References: <20040530151434.GE24955@fooishbar.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Robert.Olsson@data.slu.se
Return-path: <netdev-bounce@oss.sgi.com>
To: Daniel Stone <daniel@fooishbar.org>
In-Reply-To: <20040530151434.GE24955@fooishbar.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Daniel Stone writes:
 > Hi guys,
 > Attached is a patch to net/ipv4/route.c (against 2.4.23, sorry) to
 > combat the 'dst cache full' issue. Essentially, there's a machine that I
 > have access to (a router) that will report 'dst cache full', and
 > immediately cease dealing with any IPv4 traffic. I found the attached
 > patch against 2.0, and forward-ported it to 2.4. As this issue only
 > crops up randomly every couple of weeks, I can't tell you whether it's
 > worked or not. All I know is that it hasn't eaten my firstborn so far:
 > given a quick spin, it seemed to work OK, but whether or not it solves
 > the problem is a different matter.

 Hello!

 If your traffic is sane and you got dst cache overflow you should 
 probably try to reduce gc_min_interval so your GC can release a 
 higher numbers of dst entries per second. Flushing active entries
 means that they are created again. This decreases your throughput
 maybe just enough not to reach the limit where you reach overflow.


 > +	atomic_set(&ipv4_dst_ops.entries, 0);

 These counters should only be handled by the freeing process rt_free etc.

 Cheers.
						--ro
