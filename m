From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v2 1/3] netdev_features: Fold NETIF_F_ALL_TSO into
 NETIF_F_GSO_SOFTWARE
Date: Wed, 20 Apr 2016 10:49:06 -0400
Message-ID: <20160420144906.3100.22255.stgit@ahduyck-xeon-server>
References: <20160420144720.3100.74116.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net,
	alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33486 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754333AbcDTOtQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 10:49:16 -0400
Received: by mail-pf0-f172.google.com with SMTP id 184so19213556pff.0
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2016 07:49:16 -0700 (PDT)
In-Reply-To: <20160420144720.3100.74116.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch folds NETIF_F_ALL_TSO into the bitmask for NETIF_F_GSO_SOFTWARE.
The idea is to avoid duplication of defines since the only difference
between the two was the GSO_UDP bit.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 include/linux/netdev_features.h |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index 15eb0b12fff9..bc8736266749 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -152,11 +152,6 @@ enum {
 #define NETIF_F_GSO_MASK	(__NETIF_F_BIT(NETIF_F_GSO_LAST + 1) - \
 		__NETIF_F_BIT(NETIF_F_GSO_SHIFT))
 
-/* List of features with software fallbacks. */
-#define NETIF_F_GSO_SOFTWARE	(NETIF_F_TSO | NETIF_F_TSO_ECN | \
-				 NETIF_F_TSO_MANGLEID | \
-				 NETIF_F_TSO6 | NETIF_F_UFO)
-
 /* List of IP checksum features. Note that NETIF_F_ HW_CSUM should not be
  * set in features when NETIF_F_IP_CSUM or NETIF_F_IPV6_CSUM are set--
  * this would be contradictory
@@ -170,6 +165,9 @@ enum {
 #define NETIF_F_ALL_FCOE	(NETIF_F_FCOE_CRC | NETIF_F_FCOE_MTU | \
 				 NETIF_F_FSO)
 
+/* List of features with software fallbacks. */
+#define NETIF_F_GSO_SOFTWARE	(NETIF_F_ALL_TSO | NETIF_F_UFO)
+
 /*
  * If one device supports one of these features, then enable them
  * for all in netdev_increment_features.
