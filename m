From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: dst cache overflow errors
Date: Sat, 17 Jul 2004 12:08:07 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16632.64135.856238.115334@robur.slu.se>
References: <40E69930.1080402@outblaze.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Robert.Olsson@data.slu.se
Return-path: <netdev-bounce@oss.sgi.com>
To: Christopher Chan <cchan@outblaze.com>
In-Reply-To: <40E69930.1080402@outblaze.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Christopher Chan writes:

 > Recently, the Intel chaps wanted to have NAPI permanently enabled for 
 > their e100 driver. However, i still get network connectivity problems if 
 > I enable NAPI in e100 for 2.6.7. Severe cases result in the kernel not 
 > logging clear messages about its bug traps...due to the messages being 
 > obfuscated beyond understanding.
 > 
 > I wonder then whether the cause/problem, that makes the kernel log dst 
 > cache overflows and its BUG_TRAPs in the logs, has been identified?

 Hello!

 dst cache overflow most like indicates you have higher throughput and
 you should tune your hash tunings accordingly. So it might not be a bug.

 Verify this by monitoring the routing stats. rtstat is a utility for this. 
 You probably most interested in three first columns.

 size   IN: hit     tot
 8060     34009     271

 This means we have 34 kpps of hits to existent hash entries. While 271 new
 were created per sec. The ratio will be different for you as you reach dst 
 overflow but compare your two cases. There is now an option to set 
 rhash_entries= at boot which is probably how you how to tune it.

 rtstat is in iproute2 package but also in:
 ftp://robur.slu.se/pub/Linux/net-development/rt_cache_stat/rtstat.c

 Cheers.
						--ro

 
