From: David Decotigny <decot@google.com>
Subject: [PATCH 1/5] ethtool: cosmetics: enforce const-ness in ethtool_cmd_speed
Date: Sat, 16 Apr 2011 17:54:07 -0700
Message-ID: <1303001651-4074-1-git-send-email-decot@google.com>
Cc: David Decotigny <decot@google.com>
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Stanislaw Gruszka <sgruszka@redh
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:14690 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751518Ab1DQAyo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2011 20:54:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 'ep' argument of ethtool_cmd_speed is not altered: advertise it in
protoype. +Indentation fix. Also add comments to advise using the
ethtool_cmd_speed API to get/set the link speed.

Signed-off-by: David Decotigny <decot@google.com>
---
 include/linux/ethtool.h |   14 ++++++++++----
 1 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 9de3127..170439e 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -24,7 +24,10 @@ struct ethtool_cmd {
 	__u32	cmd;
 	__u32	supported;	/* Features this interface supports */
 	__u32	advertising;	/* Features this interface advertises */
-	__u16	speed;		/* The forced speed, 10Mb, 100Mb, gigabit */
+	__u16	speed;	        /* The forced speed (lower bits): see
+				 * SPEED_ macros below. Please use
+				 * ethtool_cmd_speed()/_set() to
+				 * access it */
 	__u8	duplex;		/* Duplex, half or full */
 	__u8	port;		/* Which connector port */
 	__u8	phy_address;
@@ -33,7 +36,10 @@ struct ethtool_cmd {
 	__u8	mdio_support;
 	__u32	maxtxpkt;	/* Tx pkts before generating tx int */
 	__u32	maxrxpkt;	/* Rx pkts before generating rx int */
-	__u16	speed_hi;
+	__u16	speed_hi;       /* The forced speed (upper
+				 * bits). Please use
+				 * ethtool_cmd_speed()/_set() to
+				 * access it */
 	__u8	eth_tp_mdix;
 	__u8	reserved2;
 	__u32	lp_advertising;	/* Features the link partner advertises */
@@ -41,14 +47,14 @@ struct ethtool_cmd {
 };
 
 static inline void ethtool_cmd_speed_set(struct ethtool_cmd *ep,
-						__u32 speed)
+					 __u32 speed)
 {
 
 	ep->speed = (__u16)speed;
 	ep->speed_hi = (__u16)(speed >> 16);
 }
 
-static inline __u32 ethtool_cmd_speed(struct ethtool_cmd *ep)
+static inline __u32 ethtool_cmd_speed(const struct ethtool_cmd *ep)
 {
 	return (ep->speed_hi << 16) | ep->speed;
 }
-- 
1.7.3.1

