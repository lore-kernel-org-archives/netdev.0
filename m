From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: RE: dst cache overflow 2.2.x; x>=16
Date: Sun, 14 Apr 2002 23:38:30 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <15545.63190.565448.189570@robur.slu.se>
References: <D4CA6B275AA33241AC771F0C0B43A921011BE867@nyc285ex01.nyc.corp.yr.com>
	<Pine.GSO.4.30.0204141644390.10326-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: "Milam, Chad" <Chad_Milam@nyc.yr.com>
In-Reply-To: <Pine.GSO.4.30.0204141644390.10326-100000@shell.cyberus.ca>
List-Id: netdev.vger.kernel.org


jamal writes:
 > 
 > 
 > 
 > If i summarize your problem is that you are building up
 > dst caches faster than they can be garbage collected.
 > 
 > Solution
 > 1. Make the max size large enough to catchup with rate
 > 2. Make sure that every time you go into garbage collection you are
 > successful.
 > - reducing the min interval to 1 might be a little aggressive.
 > But you can tune this later
 > - You wanna make sure you get a large positive "goal" every time
 > play with ip_rt_gc_elasticity (/proc/sys/net/ipv4/route/gc_elasticity)
 > also the rt_hash_log
 > 
 > All the above are configurable via /proc
 > 
 > have to run

 And in in 2.4.X the GC is done more dynamically around an "equilibrium point".
 Alexey warned about 2.2 code...


 Snaphot from Linux router. 2.4.10
 
 cat /proc/sys/net/ipv4/route/max_size 
 65536


 rtstat
 size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot     mc
 9861     24721     131     0     1     0     0     0         2       1      0
10119     25044     128     0     0     0     0     0         2       0      0
 2514     24125    1293     2     0     0     0     0         1       2      0
 3654     24315     591     2     1     1     0     0         0       2      1
 4441     25170     387     0     2     0     0     0         1       3      0
 5060     25000     304     2     1     0     0     0         0       2      0
 5532     25627     230     2     0     0     0     0         0       2      0
 5947     25754     242     2     0     0     0     0         1       3      0
 6379     25602     211     0     1     0     0     0         2       3      0
 6371     25523     235     0     0     0     0     0         1       1      0
 6752     24251     187     1     0     0     0     0         0       1      0
 7077     25310     160     0     0     0     0     0         1       1      0
 6851     24608     222     2     1     0     0     0         1       3      0
 7256     25313     199     1     0     0     0     0         1       2      0
 7086     24656     174     0     0     0     0     0         0       1      0
 7459     24070     180     3     1     0     0     0         1       2      0
 2434     23844    1340     7     1     0     0     0         1       3      0


 1:st  ipv4_dst_ops.entries. (You see GC happen)
 2:nd: Warm cache hits -> approx aggregated packet/sec. 
 3:rd: Cache misses    -> approx connections/sec.


 Cheers.

						--ro
