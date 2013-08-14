From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH 3/3 v4] ipv6: fix checkpatch errors in net/ipv6/addrconf.c
Date: Wed, 14 Aug 2013 17:07:07 +0800
Message-ID: <520B48BB.1010902@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:35805 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759537Ab3HNJHh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 05:07:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ERROR: code indent should use tabs where possible: fix 2.
ERROR: do not use assignment in if condition: fix 5.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 net/ipv6/addrconf.c | 24 ++++++++++++++----------
 1 file changed, 14 insertions(+), 10 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 734724c..00e3fdc 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1105,8 +1105,8 @@ retry:
 	spin_unlock_bh(&ifp->lock);
 
 	regen_advance = idev->cnf.regen_max_retry *
-	                idev->cnf.dad_transmits *
-	                idev->nd_parms->retrans_time / HZ;
+			idev->cnf.dad_transmits *
+			idev->nd_parms->retrans_time / HZ;
 	write_unlock(&idev->lock);
 
 	/* A temporary address is created only if this calculated Preferred
@@ -2514,7 +2514,8 @@ static int inet6_addr_del(struct net *net, int ifindex, const struct in6_addr *p
 	if (!dev)
 		return -ENODEV;
 
-	if ((idev = __in6_dev_get(dev)) == NULL)
+	idev = __in6_dev_get(dev);
+	if (!idev)
 		return -ENXIO;
 
 	read_lock_bh(&idev->lock);
@@ -2653,7 +2654,8 @@ static void init_loopback(struct net_device *dev)
 
 	ASSERT_RTNL();
 
-	if ((idev = ipv6_find_idev(dev)) == NULL) {
+	idev = ipv6_find_idev(dev);
+	if (!idev) {
 		pr_debug("%s: add_dev failed\n", __func__);
 		return;
 	}
@@ -2751,7 +2753,8 @@ static void addrconf_sit_config(struct net_device *dev)
 	 * our v4 addrs in the tunnel
 	 */
 
-	if ((idev = ipv6_find_idev(dev)) == NULL) {
+	idev = ipv6_find_idev(dev);
+	if (!idev) {
 		pr_debug("%s: add_dev failed\n", __func__);
 		return;
 	}
@@ -2783,7 +2786,8 @@ static void addrconf_gre_config(struct net_device *dev)
 
 	ASSERT_RTNL();
 
-	if ((idev = ipv6_find_idev(dev)) == NULL) {
+	idev = ipv6_find_idev(dev);
+	if (!idev) {
 		pr_debug("%s: add_dev failed\n", __func__);
 		return;
 	}
@@ -2814,11 +2818,11 @@ static void ip6_tnl_add_linklocal(struct inet6_dev *idev)
 	struct net *net = dev_net(idev->dev);
 
 	/* first try to inherit the link-local address from the link device */
-	if (idev->dev->iflink &&
-	    (link_dev = __dev_get_by_index(net, idev->dev->iflink))) {
-		if (!ipv6_inherit_linklocal(idev, link_dev))
+	if (idev->dev->iflink)
+		link_dev = __dev_get_by_index(net, idev->dev->iflink);
+		if (link_dev && !ipv6_inherit_linklocal(idev, link_dev))
 			return;
-	}
+
 	/* then try to inherit it from any device */
 	for_each_netdev(net, link_dev) {
 		if (!ipv6_inherit_linklocal(idev, link_dev))
-- 
1.8.2.1
