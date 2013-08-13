From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH 2/3 v2] ipv6: rename ADBG() to pr_xxx()
Date: Tue, 13 Aug 2013 15:57:28 +0800
Message-ID: <5209E6E8.1030702@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:61242 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752098Ab3HMIGt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 04:06:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According to Joe Perches opinions, the ADBG() was tedious and it is
better to remove the KERN_<LEVEL>s and use the pr_xxx() instead of ADBG().

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
Cc: Joe Perches <joe@perches.com>
---
 net/ipv6/addrconf.c | 29 +++++++++--------------------
 1 file changed, 9 insertions(+), 20 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 72911fd..2333fa7 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -95,15 +95,6 @@
 #include <linux/seq_file.h>
 #include <linux/export.h>
 
-/* Set to 3 to get tracing... */
-#define ACONF_DEBUG 2
-
-#if ACONF_DEBUG >= 3
-#define ADBG(x) printk x
-#else
-#define ADBG(x)
-#endif
-
 #define	INFINITY_LIFE_TIME	0xFFFFFFFF
 
 static inline u32 cstamp_delta(unsigned long cstamp)
@@ -369,9 +360,8 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 	dev_hold(dev);
 
 	if (snmp6_alloc_dev(ndev) < 0) {
-		ADBG((KERN_WARNING
-			"%s: cannot allocate memory for statistics; dev=%s.\n",
-			__func__, dev->name));
+		pr_warning("%s: cannot allocate memory for statistics; dev=%s.\n",
+			__func__, dev->name);
 		neigh_parms_release(&nd_tbl, ndev->nd_parms);
 		dev_put(dev);
 		kfree(ndev);
@@ -379,9 +369,8 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 	}
 
 	if (snmp6_register_dev(ndev) < 0) {
-		ADBG((KERN_WARNING
-			"%s: cannot create /proc/net/dev_snmp6/%s\n",
-			__func__, dev->name));
+		pr_warning("%s: cannot create /proc/net/dev_snmp6/%s\n",
+			__func__, dev->name);
 		neigh_parms_release(&nd_tbl, ndev->nd_parms);
 		ndev->dead = 1;
 		in6_dev_finish_destroy(ndev);
@@ -844,7 +833,7 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 
 	/* Ignore adding duplicate addresses on an interface */
 	if (ipv6_chk_same_addr(dev_net(idev->dev), addr, idev->dev)) {
-		ADBG(("ipv6_add_addr: already assigned\n"));
+		pr_err("ipv6_add_addr: already assigned\n");
 		err = -EEXIST;
 		goto out;
 	}
@@ -852,7 +841,7 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 	ifa = kzalloc(sizeof(struct inet6_ifaddr), GFP_ATOMIC);
 
 	if (ifa == NULL) {
-		ADBG(("ipv6_add_addr: malloc failed\n"));
+		pr_err("ipv6_add_addr: malloc failed\n");
 		err = -ENOBUFS;
 		goto out;
 	}
@@ -2069,7 +2058,7 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sllao)
 	pinfo = (struct prefix_info *) opt;
 
 	if (len < sizeof(struct prefix_info)) {
-		ADBG(("addrconf: prefix option too short\n"));
+		pr_err("addrconf: prefix option too short\n");
 		return;
 	}
 
@@ -3649,8 +3638,8 @@ restart:
 	if (time_before(next_sched, jiffies + ADDRCONF_TIMER_FUZZ_MAX))
 		next_sched = jiffies + ADDRCONF_TIMER_FUZZ_MAX;
 
-	ADBG((KERN_DEBUG "now = %lu, schedule = %lu, rounded schedule = %lu => %lu\n",
-	      now, next, next_sec, next_sched));
+	pr_debug("now = %lu, schedule = %lu, rounded schedule = %lu => %lu\n",
+	      now, next, next_sec, next_sched);
 
 	addr_chk_timer.expires = next_sched;
 	add_timer(&addr_chk_timer);
-- 
1.8.2.1
