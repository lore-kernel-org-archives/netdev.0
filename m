From: Petr Baudis <pasky@xs26.net>
Subject: Linux problems with hundreds of interfaces/routes
Date: Fri, 27 Sep 2002 13:43:09 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020927114309.GR2655@pasky.ji.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roque@di.fc.ul.pt, pekkas@netcore.fi, netdev@oss.sgi.com,
   xs26-dev@xs26.net
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  Hello,

  as you probably remember, I'm running XS26 Point of Presence, currently on
linux 2.4.19-pre5. It has currently around 2185 v6 routes and 591 interfaces.
The problem is that lately, some magic threshold was crossed and suddenly
routes started to act mysteriously and fail - sometimes, zebra says something
like:

2002/09/27 11:11:03 ZEBRA: netlink-listen error: No buffer space available, type=RTM_NEWROUTE(24), seq=426, pid=0

  (but not always), and random routes start and stop working, like:

12:38:53.607852 3ffe:80ed:100:201::1 > 3ffe:80ef:100::: icmp6: echo request
12:38:54.646534 3ffe:80ed:100:201::1 > 3ffe:80ef:100::: icmp6: echo request
12:38:55.619879 3ffe:80ed:100:201::1 > 3ffe:80ef:100::: icmp6: echo request
12:38:56.623530 3ffe:80ed:100:201::1 > 3ffe:80ef:100::: icmp6: echo request
12:38:56.625014 3ffe:80ef:100:: > 3ffe:80ed:100:201::1: icmp6: echo reply
12:38:57.635249 3ffe:80ed:100:201::1 > 3ffe:80ef:100::: icmp6: echo request
12:38:57.635291 3ffe:80ef:100:: > 3ffe:80ed:100:201::1: icmp6: echo reply
12:38:58.643860 3ffe:80ed:100:201::1 > 3ffe:80ef:100::: icmp6: echo request

  (3ffe:80ef:100:: is address of a local interface). Apparently bgpd removed
some route at that moment and route for this came into game. I think that
there's some bug/limit in kernel regarding the routing table size, causing that
some routes aren't ever used (altough they are listed). Have you please any
idea about this problem?

  I discovered few sysctls - net.ipv6.route.max_size which was 4096, so I
increased it to 8192 and then to 65536, but it had no effect at all. Then I
noticed net.core.rmem_max and net.core.wmem_max, so I increased it from 65535
to 1M, but it had no effect at all as well.

  Thanks in advance for any hint,

-- 
 
				Petr "Pasky" Baudis
 
* ELinks maintainer                * IPv6 guy (XS26 co-coordinator)
* IRCnet operator                  * FreeCiv AI occassional hacker
.
<Beeth> Girls are like internet domain names, the ones I like are already taken.
<honx> Well, you can still get one from a strange country :-P
.
Public PGP key && geekcode && homepage: http://pasky.ji.cz/~pasky/
