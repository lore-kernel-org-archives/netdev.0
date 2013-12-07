From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: [PATCH net-next 2/2] ipv6: Add checks for 6LOWPAN ARP type
Date: Sat,  7 Dec 2013 20:08:57 +0200
Message-ID: <1386439737-14894-3-git-send-email-jukka.rissanen@linux.intel.com>
References: <1386439737-14894-1-git-send-email-jukka.rissanen@linux.intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:55153 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758417Ab3LGSJF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Dec 2013 13:09:05 -0500
In-Reply-To: <1386439737-14894-1-git-send-email-jukka.rissanen@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jukka Rissanen <jukka.rissanen@linux.intel.com>
---
 net/ipv6/addrconf.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 5087cc5..b3d78ad 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1816,6 +1816,7 @@ static int ipv6_generate_eui64(u8 *eui, struct net_device *dev)
 		return addrconf_ifid_sit(eui, dev);
 	case ARPHRD_IPGRE:
 		return addrconf_ifid_gre(eui, dev);
+	case ARPHRD_6LOWPAN:
 	case ARPHRD_IEEE802154:
 		return addrconf_ifid_eui64(eui, dev);
 	case ARPHRD_IEEE1394:
@@ -2670,7 +2671,8 @@ static void addrconf_dev_config(struct net_device *dev)
 	    (dev->type != ARPHRD_INFINIBAND) &&
 	    (dev->type != ARPHRD_IEEE802154) &&
 	    (dev->type != ARPHRD_IEEE1394) &&
-	    (dev->type != ARPHRD_TUNNEL6)) {
+	    (dev->type != ARPHRD_TUNNEL6) &&
+	    (dev->type != ARPHRD_6LOWPAN)) {
 		/* Alas, we support only Ethernet autoconfiguration. */
 		return;
 	}
-- 
1.8.3.1
