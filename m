From: Parav Pandit <parav.pandit@emulex.com>
Subject: [PATCH] net: added support for 40GbE link.
Date: Mon, 18 Jun 2012 18:14:49 +0530
Message-ID: <0c7c97b0-bfe1-4143-a562-2019f86912fc@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <bhutchings@solarflare.com>, Parav Pandit <parav.pandit@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:11584 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752607Ab2FRIjh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2012 04:39:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. link speed of 40GbE and #4 KR4, CR4, SR4, LR4 modes defined.
2. removed code replication for tov calculation for 1G, 10G and
made is common for 1G, 10G, 40G.

Port cost calculation changes for bridging for 40G will be done once have more clarify from 802.1d spec in coming days.

Signed-off-by: Parav Pandit <parav.pandit@emulex.com>
---
 include/linux/ethtool.h |   11 ++++++++++-
 net/packet/af_packet.c  |    8 +++-----
 2 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 297370a..1ebfa6e 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -1153,6 +1153,10 @@ struct ethtool_ops {
 #define SUPPORTED_10000baseR_FEC	(1 << 20)
 #define SUPPORTED_20000baseMLD2_Full	(1 << 21)
 #define SUPPORTED_20000baseKR2_Full	(1 << 22)
+#define SUPPORTED_40000baseKR4_Full	(1 << 23)
+#define SUPPORTED_40000baseCR4_Full	(1 << 24)
+#define SUPPORTED_40000baseSR4_Full	(1 << 25)
+#define SUPPORTED_40000baseLR4_Full	(1 << 26)
 
 /* Indicates what features are advertised by the interface. */
 #define ADVERTISED_10baseT_Half		(1 << 0)
@@ -1178,6 +1182,10 @@ struct ethtool_ops {
 #define ADVERTISED_10000baseR_FEC	(1 << 20)
 #define ADVERTISED_20000baseMLD2_Full	(1 << 21)
 #define ADVERTISED_20000baseKR2_Full	(1 << 22)
+#define ADVERTISED_40000baseKR4_Full	(1 << 23)
+#define ADVERTISED_40000baseCR4_Full	(1 << 24)
+#define ADVERTISED_40000baseSR4_Full	(1 << 25)
+#define ADVERTISED_40000baseLR4_Full	(1 << 26)
 
 /* The following are all involved in forcing a particular link
  * mode for the device for setting things.  When getting the
@@ -1185,12 +1193,13 @@ struct ethtool_ops {
  * it was forced up into this mode or autonegotiated.
  */
 
-/* The forced speed, 10Mb, 100Mb, gigabit, 2.5Gb, 10GbE. */
+/* The forced speed, 10Mb, 100Mb, gigabit, 2.5Gb, 10GbE, 40GbE. */
 #define SPEED_10		10
 #define SPEED_100		100
 #define SPEED_1000		1000
 #define SPEED_2500		2500
 #define SPEED_10000		10000
+#define SPEED_40000		40000
 #define SPEED_UNKNOWN		-1
 
 /* Duplex, half or full. */
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 8a10d5b..dd0e503 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -542,13 +542,11 @@ static int prb_calc_retire_blk_tmo(struct packet_sock *po,
 	rtnl_unlock();
 	if (!err) {
 		switch (ecmd.speed) {
-		case SPEED_10000:
-			msec = 1;
-			div = 10000/1000;
-			break;
 		case SPEED_1000:
+		case SPEED_10000:
+		case SPEED_40000:
 			msec = 1;
-			div = 1000/1000;
+			div = ecmd.speed / 1000;
 			break;
 		/*
 		 * If the link speed is so slow you don't really
-- 
1.6.0.2
