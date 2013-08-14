From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH 2/3 v4] ipv6: convert the uses of ADBG and remove the superfluous
 parentheses
Date: Wed, 14 Aug 2013 17:07:03 +0800
Message-ID: <520B48B7.8020106@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Joe Perches <joe@perches.com>, Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:34313 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759455Ab3HNJIR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 05:08:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just follow the Joe Perches's opinion, it is a better way to fix the
style errors.

Suggested-by: Joe Perches <joe@perches.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
Cc: Joe Perches <joe@perches.com>
---
 net/ipv6/addrconf.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 7b55464..734724c 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -99,9 +99,9 @@
 #define ACONF_DEBUG 2
 
 #if ACONF_DEBUG >= 3
-#define ADBG(x) printk x
+#define ADBG(fmt, ...) printk(fmt, ##__VA_ARGS__)
 #else
-#define ADBG(x)
+#define ADBG(fmt, ...) do { if (0) printk(fmt, ##__VA_ARGS__); } while (0)
 #endif
 
 #define	INFINITY_LIFE_TIME	0xFFFFFFFF
@@ -369,9 +369,9 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 	dev_hold(dev);
 
 	if (snmp6_alloc_dev(ndev) < 0) {
-		ADBG((KERN_WARNING
+		ADBG(KERN_WARNING
 			"%s: cannot allocate memory for statistics; dev=%s.\n",
-			__func__, dev->name));
+			__func__, dev->name);
 		neigh_parms_release(&nd_tbl, ndev->nd_parms);
 		dev_put(dev);
 		kfree(ndev);
@@ -379,9 +379,9 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 	}
 
 	if (snmp6_register_dev(ndev) < 0) {
-		ADBG((KERN_WARNING
+		ADBG(KERN_WARNING
 			"%s: cannot create /proc/net/dev_snmp6/%s\n",
-			__func__, dev->name));
+			__func__, dev->name);
 		neigh_parms_release(&nd_tbl, ndev->nd_parms);
 		ndev->dead = 1;
 		in6_dev_finish_destroy(ndev);
@@ -844,7 +844,7 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 
 	/* Ignore adding duplicate addresses on an interface */
 	if (ipv6_chk_same_addr(dev_net(idev->dev), addr, idev->dev)) {
-		ADBG(("ipv6_add_addr: already assigned\n"));
+		ADBG("ipv6_add_addr: already assigned\n");
 		err = -EEXIST;
 		goto out;
 	}
@@ -852,7 +852,7 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 	ifa = kzalloc(sizeof(struct inet6_ifaddr), GFP_ATOMIC);
 
 	if (ifa == NULL) {
-		ADBG(("ipv6_add_addr: malloc failed\n"));
+		ADBG("ipv6_add_addr: malloc failed\n");
 		err = -ENOBUFS;
 		goto out;
 	}
@@ -2070,7 +2070,7 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sllao)
 	pinfo = (struct prefix_info *) opt;
 
 	if (len < sizeof(struct prefix_info)) {
-		ADBG(("addrconf: prefix option too short\n"));
+		ADBG("addrconf: prefix option too short\n");
 		return;
 	}
 
@@ -3650,8 +3650,8 @@ restart:
 	if (time_before(next_sched, jiffies + ADDRCONF_TIMER_FUZZ_MAX))
 		next_sched = jiffies + ADDRCONF_TIMER_FUZZ_MAX;
 
-	ADBG((KERN_DEBUG "now = %lu, schedule = %lu, rounded schedule = %lu => %lu\n",
-	      now, next, next_sec, next_sched));
+	ADBG(KERN_DEBUG "now = %lu, schedule = %lu, rounded schedule = %lu => %lu\n",
+	      now, next, next_sec, next_sched);
 
 	addr_chk_timer.expires = next_sched;
 	add_timer(&addr_chk_timer);
-- 
1.8.2.1
