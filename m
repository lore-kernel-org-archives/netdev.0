From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] man: Collect names of man pages automatically
Date: Tue, 27 Jun 2017 21:00:25 +0200
Message-ID: <20170627190025.450-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:44827 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752311AbdF0TAe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 27 Jun 2017 15:00:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As it turned out, forgetting to add a man page to the respective
Makefile when introducing it is a common mistake. Overcome this once and
for all by using $(wildcard) function in Makefiles.

Fixes: 7124942942e53 ("genl: add manpage")
Fixes: 958cd210942c8 ("ifcfg: add manpage")
Fixes: e1b7f883e50de ("man: add documentation for IPv6 SR commands")
Fixes: 1949f82cdf62c ("Introduce ip vrf command")
Fixes: 535194a172d23 ("tipc: add peer remove functionality")
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man3/Makefile |  2 +-
 man/man7/Makefile |  2 +-
 man/man8/Makefile | 21 +--------------------
 3 files changed, 3 insertions(+), 22 deletions(-)

diff --git a/man/man3/Makefile b/man/man3/Makefile
index bf55658c96746..a98741de29262 100644
--- a/man/man3/Makefile
+++ b/man/man3/Makefile
@@ -1,4 +1,4 @@
-MAN3PAGES=libnetlink.3
+MAN3PAGES = $(wildcard *.3)
 
 all:
 
diff --git a/man/man7/Makefile b/man/man7/Makefile
index ccfd8398c5f29..689fc713b6729 100644
--- a/man/man7/Makefile
+++ b/man/man7/Makefile
@@ -1,4 +1,4 @@
-MAN7PAGES = tc-hfsc.7
+MAN7PAGES = $(wildcard *.7)
 
 all:
 
diff --git a/man/man8/Makefile b/man/man8/Makefile
index f33186446819e..12af66be4bc73 100644
--- a/man/man8/Makefile
+++ b/man/man8/Makefile
@@ -1,25 +1,6 @@
 TARGETS = ip-address.8 ip-link.8 ip-route.8
 
-MAN8PAGES = $(TARGETS) ip.8 arpd.8 lnstat.8 routel.8 rtacct.8 rtmon.8 rtpr.8 ss.8 \
-	tc.8 tc-bfifo.8 tc-bpf.8 tc-cbq.8 tc-cbq-details.8 tc-choke.8 tc-codel.8 \
-	tc-fq.8 \
-	tc-drr.8 tc-ematch.8 tc-fq_codel.8 tc-hfsc.8 tc-htb.8 tc-pie.8 \
-	tc-mqprio.8 tc-netem.8 tc-pfifo.8 tc-pfifo_fast.8 tc-prio.8 tc-red.8 \
-	tc-sfb.8 tc-sfq.8 tc-stab.8 tc-tbf.8 \
-	bridge.8 rtstat.8 ctstat.8 nstat.8 routef.8 \
-	ip-addrlabel.8 ip-fou.8 ip-gue.8 ip-l2tp.8 ip-macsec.8 \
-	ip-maddress.8 ip-monitor.8 ip-mroute.8 ip-neighbour.8 \
-	ip-netns.8 ip-ntable.8 ip-rule.8 ip-tunnel.8 ip-xfrm.8 \
-	ip-tcp_metrics.8 ip-netconf.8 ip-token.8 \
-	tipc.8 tipc-bearer.8 tipc-link.8 tipc-media.8 tipc-nametable.8 \
-	tipc-node.8 tipc-socket.8 \
-	tc-basic.8 tc-cgroup.8 tc-flow.8 tc-flower.8 tc-fw.8 tc-route.8 \
-	tc-tcindex.8 tc-u32.8 tc-matchall.8 \
-	tc-connmark.8 tc-csum.8 tc-mirred.8 tc-nat.8 tc-pedit.8 tc-police.8 \
-	tc-simple.8 tc-skbedit.8 tc-vlan.8 tc-xt.8 tc-skbmod.8 tc-ife.8 \
-	tc-tunnel_key.8 tc-sample.8 \
-	devlink.8 devlink-dev.8 devlink-monitor.8 devlink-port.8 devlink-sb.8 \
-	ifstat.8
+MAN8PAGES = $(TARGETS) $(filter-out $(TARGETS),$(wildcard *.8))
 
 all: $(TARGETS)
 
-- 
2.13.1
