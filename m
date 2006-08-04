From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCHSET] Multiple IPV6 Routing Tables & Policy Routing
Date: Fri, 04 Aug 2006 12:23:08 +0200
Message-ID: <20060804102308.711837665@postel.suug.ch>
Cc: vnuorval@tcs.hut.fi, usagi-core@linux-ipv6.org,
	yoshfuji@linux-ipv6.org, davem@davemloft.net, anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:38874 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1161135AbWHDK1H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2006 06:27:07 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

This patchset implements multiple IPv6 routing tables and
policy routing. Even though the code is almost rewritten
entirely the work is based on the MIPL patch found on
mobile-ipv6.org which is being jointly developed by Helsinki
University of Technology (HUT) and the USAGI/WIDE Project.

Reference counting on routing tables was removed to decrease
the number of required atomic operations during route lookup.

The tables are now organized in a hashtable to prepare for
the change in supporting more than 255 tables.

Matching sources address in policy rules is no longer dependant
on CONFIG_SUBTREES.

Git tree with changes:
master.kernel.org:/pub/scm/linux/kernel/git/tgraf/net-2.6.19-mrt.git

 include/linux/fib_rules.h |   60 ++++
 include/linux/rtnetlink.h |    2 
 include/net/fib_rules.h   |   90 +++++++
 include/net/ip6_fib.h     |   46 +++
 include/net/ip6_route.h   |    8 +
 include/net/ip_fib.h      |   14 +
 net/Kconfig               |    3 
 net/core/Makefile         |    1 
 net/core/fib_rules.c      |  416 +++++++++++++++++++++++++++++++
 net/core/rtnetlink.c      |    9 +
 net/ipv4/Kconfig          |    1 
 net/ipv4/devinet.c        |    4 
 net/ipv4/fib_frontend.c   |    2 
 net/ipv4/fib_rules.c      |  613 ++++++++++++++++++---------------------------
 net/ipv6/Kconfig          |    7 +
 net/ipv6/Makefile         |    1 
 net/ipv6/addrconf.c       |    7 -
 net/ipv6/fib6_rules.c     |  251 ++++++++++++++++++
 net/ipv6/ip6_fib.c        |  143 ++++++++++
 net/ipv6/route.c          |  442 +++++++++++++++++++++++---------
 20 files changed, 1597 insertions(+), 523 deletions(-

