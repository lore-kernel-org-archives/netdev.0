From: Yi Zou <yi.zou@intel.com>
Subject: [PATCH 03/11] net: define feature flags for FCoE offloads
Date: Fri, 27 Feb 2009 14:06:49 -0800
Message-ID: <20090227220648.4987.19977.stgit.yi.zou@intel.com>
References: <20090227220034.4987.50755.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: yi.zou@intel.com
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:7974 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756426AbZB0XO0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Feb 2009 18:14:26 -0500
In-Reply-To: <20090227220034.4987.50755.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Leech <christopher.leech@intel.com>

Define feature flags for FCoE offloads.

Signed-off-by: Chris Leech <christopher.leech@intel.com>
Signed-off-by: Yi Zou <yi.zou@intel.com>
---

 include/linux/netdevice.h |    3 +++
 include/linux/skbuff.h    |    2 ++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c8238d9..5c40557 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -650,6 +650,8 @@ struct net_device
 #define NETIF_F_GRO		16384	/* Generic receive offload */
 #define NETIF_F_LRO		32768	/* large receive offload */
 
+#define NETIF_F_FCOE_CRC	(1 << 24) /* FCoE CRC32 */
+
 	/* Segmentation offload features */
 #define NETIF_F_GSO_SHIFT	16
 #define NETIF_F_GSO_MASK	0x00ff0000
@@ -658,6 +660,7 @@ struct net_device
 #define NETIF_F_GSO_ROBUST	(SKB_GSO_DODGY << NETIF_F_GSO_SHIFT)
 #define NETIF_F_TSO_ECN		(SKB_GSO_TCP_ECN << NETIF_F_GSO_SHIFT)
 #define NETIF_F_TSO6		(SKB_GSO_TCPV6 << NETIF_F_GSO_SHIFT)
+#define NETIF_F_FSO		(SKB_GSO_FCOE << NETIF_F_GSO_SHIFT)
 
 	/* List of features with software fallbacks. */
 #define NETIF_F_GSO_SOFTWARE	(NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6)
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 9dcf956..02adea2 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -188,6 +188,8 @@ enum {
 	SKB_GSO_TCP_ECN = 1 << 3,
 
 	SKB_GSO_TCPV6 = 1 << 4,
+
+	SKB_GSO_FCOE = 1 << 5,
 };
 
 #if BITS_PER_LONG > 32

