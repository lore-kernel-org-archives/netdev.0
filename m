From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] ipv6: remove a useless NULL check
Date: Mon, 29 Oct 2012 11:43:53 +0800
Message-ID: <1351482233-10712-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33484 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751780Ab2J2DoH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Oct 2012 23:44:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In dev_forward_change(), it is useless to check if idev->dev
is NULL, it is always non-NULL here.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 8f0b12a..c9b1cf3 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -607,7 +607,7 @@ static void dev_forward_change(struct inet6_dev *idev)
 	dev = idev->dev;
 	if (idev->cnf.forwarding)
 		dev_disable_lro(dev);
-	if (dev && (dev->flags & IFF_MULTICAST)) {
+	if (dev->flags & IFF_MULTICAST) {
 		if (idev->cnf.forwarding)
 			ipv6_dev_mc_inc(dev, &in6addr_linklocal_allrouters);
 		else
