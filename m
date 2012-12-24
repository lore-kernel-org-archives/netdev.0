From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH 24/29] net/ipv6: rename net_random() to prandom_u32()
Date: Mon, 24 Dec 2012 11:14:11 +0900
Message-ID: <1356315256-6572-25-git-send-email-akinobu.mita@gmail.com>
References: <1356315256-6572-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:45271 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753000Ab2LXCPX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Dec 2012 21:15:23 -0500
In-Reply-To: <1356315256-6572-1-git-send-email-akinobu.mita@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use more preferable function name which implies using a pseudo-random
number generator.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: netdev@vger.kernel.org
---
 net/ipv6/addrconf.c      | 4 ++--
 net/ipv6/ip6_flowlabel.c | 2 +-
 net/ipv6/mcast.c         | 8 ++++----
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 408cac4a..314b134 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3038,7 +3038,7 @@ static void addrconf_dad_kick(struct inet6_ifaddr *ifp)
 	if (ifp->flags & IFA_F_OPTIMISTIC)
 		rand_num = 0;
 	else
-		rand_num = net_random() % (idev->cnf.rtr_solicit_delay ? : 1);
+		rand_num = prandom_u32() % (idev->cnf.rtr_solicit_delay ? : 1);
 
 	ifp->probes = idev->cnf.dad_transmits;
 	addrconf_mod_timer(ifp, AC_DAD, rand_num);
@@ -3051,7 +3051,7 @@ static void addrconf_dad_start(struct inet6_ifaddr *ifp)
 
 	addrconf_join_solict(dev, &ifp->addr);
 
-	net_srandom(ifp->addr.s6_addr32[3]);
+	prandom_seed((__force u32)ifp->addr.s6_addr32[3]);
 
 	read_lock_bh(&idev->lock);
 	spin_lock(&ifp->lock);
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 29124b7..313f8bf 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -191,7 +191,7 @@ static struct ip6_flowlabel *fl_intern(struct net *net,
 	write_lock_bh(&ip6_fl_lock);
 	if (label == 0) {
 		for (;;) {
-			fl->label = htonl(net_random())&IPV6_FLOWLABEL_MASK;
+			fl->label = htonl(prandom_u32()) & IPV6_FLOWLABEL_MASK;
 			if (fl->label) {
 				lfl = __fl_lookup(net, fl->label);
 				if (lfl == NULL)
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 28dfa5f..71af892 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1006,7 +1006,7 @@ bool ipv6_chk_mcast_addr(struct net_device *dev, const struct in6_addr *group,
 
 static void mld_gq_start_timer(struct inet6_dev *idev)
 {
-	int tv = net_random() % idev->mc_maxdelay;
+	int tv = prandom_u32() % idev->mc_maxdelay;
 
 	idev->mc_gq_running = 1;
 	if (!mod_timer(&idev->mc_gq_timer, jiffies+tv+2))
@@ -1015,7 +1015,7 @@ static void mld_gq_start_timer(struct inet6_dev *idev)
 
 static void mld_ifc_start_timer(struct inet6_dev *idev, int delay)
 {
-	int tv = net_random() % delay;
+	int tv = prandom_u32() % delay;
 
 	if (!mod_timer(&idev->mc_ifc_timer, jiffies+tv+2))
 		in6_dev_hold(idev);
@@ -1041,7 +1041,7 @@ static void igmp6_group_queried(struct ifmcaddr6 *ma, unsigned long resptime)
 
 	if (delay >= resptime) {
 		if (resptime)
-			delay = net_random() % resptime;
+			delay = prandom_u32() % resptime;
 		else
 			delay = 1;
 	}
@@ -2102,7 +2102,7 @@ static void igmp6_join_group(struct ifmcaddr6 *ma)
 
 	igmp6_send(&ma->mca_addr, ma->idev->dev, ICMPV6_MGM_REPORT);
 
-	delay = net_random() % IGMP6_UNSOLICITED_IVAL;
+	delay = prandom_u32() % IGMP6_UNSOLICITED_IVAL;
 
 	spin_lock_bh(&ma->mca_lock);
 	if (del_timer(&ma->mca_timer)) {
-- 
1.7.11.7
