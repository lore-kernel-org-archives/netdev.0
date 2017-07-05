From: David Miller <davem@davemloft.net>
Subject: [PATCH RFC 08/12] net: Remove references to NETIF_F_UFO in
 netdev_fix_features().
Date: Wed, 05 Jul 2017 16:05:47 +0100 (WEST)
Message-ID: <20170705.160547.2078029218633531306.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42602 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751685AbdGEPFx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 11:05:53 -0400
Received: from localhost (unknown [193.136.225.129])
        (using TLSv1 with cipher AES256-SHA (256/256 bits))
        (Client did not present a certificate)
        (Authenticated sender: davem-davemloft)
        by shards.monkeyblade.net (Postfix) with ESMTPSA id 5E25B126C97F3
        for <netdev@vger.kernel.org>; Wed,  5 Jul 2017 08:05:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It is going away.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/dev.c | 18 ------------------
 1 file changed, 18 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 7098fba..8495ded 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7234,24 +7234,6 @@ static netdev_features_t netdev_fix_features(struct net_device *dev,
 		features &= ~NETIF_F_GSO;
 	}
 
-	/* UFO needs SG and checksumming */
-	if (features & NETIF_F_UFO) {
-		/* maybe split UFO into V4 and V6? */
-		if (!(features & NETIF_F_HW_CSUM) &&
-		    ((features & (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM)) !=
-		     (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM))) {
-			netdev_dbg(dev,
-				"Dropping NETIF_F_UFO since no checksum offload features.\n");
-			features &= ~NETIF_F_UFO;
-		}
-
-		if (!(features & NETIF_F_SG)) {
-			netdev_dbg(dev,
-				"Dropping NETIF_F_UFO since no NETIF_F_SG feature.\n");
-			features &= ~NETIF_F_UFO;
-		}
-	}
-
 	/* GSO partial features require GSO partial be set */
 	if ((features & dev->gso_partial_features) &&
 	    !(features & NETIF_F_GSO_PARTIAL)) {
-- 
2.9.4
