From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: [PATCH 2/2] ipv6: Add checks for RAWIP ARP type
Date: Wed, 30 Oct 2013 11:11:11 +0200
Message-ID: <1383124271-15290-3-git-send-email-jukka.rissanen@linux.intel.com>
References: <1383124271-15290-1-git-send-email-jukka.rissanen@linux.intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:32073 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751897Ab3J3JLQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Oct 2013 05:11:16 -0400
In-Reply-To: <1383124271-15290-1-git-send-email-jukka.rissanen@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jukka Rissanen <jukka.rissanen@linux.intel.com>
---
 net/ipv6/addrconf.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index d6ff126..60bf947 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1783,6 +1783,15 @@ static int addrconf_ifid_ip6tnl(u8 *eui, struct net_device *dev)
 	return 0;
 }
 
+static int addrconf_ifid_rawip(u8 *eui, struct net_device *dev)
+{
+	if (dev->addr_len != 8)
+		return -1;
+	memcpy(eui, dev->dev_addr, 8);
+	eui[0] ^= 2;
+	return 0;
+}
+
 static int ipv6_generate_eui64(u8 *eui, struct net_device *dev)
 {
 	switch (dev->type) {
@@ -1803,6 +1812,8 @@ static int ipv6_generate_eui64(u8 *eui, struct net_device *dev)
 		return addrconf_ifid_ieee1394(eui, dev);
 	case ARPHRD_TUNNEL6:
 		return addrconf_ifid_ip6tnl(eui, dev);
+	case ARPHRD_RAWIP:
+		return addrconf_ifid_rawip(eui, dev);
 	}
 	return -1;
 }
@@ -2681,7 +2692,8 @@ static void addrconf_dev_config(struct net_device *dev)
 	    (dev->type != ARPHRD_INFINIBAND) &&
 	    (dev->type != ARPHRD_IEEE802154) &&
 	    (dev->type != ARPHRD_IEEE1394) &&
-	    (dev->type != ARPHRD_TUNNEL6)) {
+	    (dev->type != ARPHRD_TUNNEL6) &&
+	    (dev->type != ARPHRD_RAWIP)) {
 		/* Alas, we support only Ethernet autoconfiguration. */
 		return;
 	}
-- 
1.7.11.7
