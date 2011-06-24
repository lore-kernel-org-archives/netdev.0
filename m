From: greearb@candelatech.com
Subject: [RFC v2 1/2] net:  Support RXFCS feature flag.
Date: Fri, 24 Jun 2011 12:06:10 -0700
Message-ID: <1308942371-12748-2-git-send-email-greearb@candelatech.com>
References: <1308942371-12748-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:53300 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756304Ab1FXTGZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 15:06:25 -0400
In-Reply-To: <1308942371-12748-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

When set, this causes the Ethernet FCS to be appended
to the end of the skb.

Useful for sniffing packets.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 d0ab610... 55f359e... M	include/linux/netdev_features.h
:100644 100644 80b88fe... 62f15e9... M	net/core/ethtool.c
 include/linux/netdev_features.h |    2 ++
 net/core/ethtool.c              |    1 +
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index d0ab610..55f359e 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -54,6 +54,7 @@ enum {
 	NETIF_F_RXCSUM_BIT,		/* Receive checksumming offload */
 	NETIF_F_NOCACHE_COPY_BIT,	/* Use no-cache copyfromuser */
 	NETIF_F_LOOPBACK_BIT,		/* Enable loopback */
+	NETIF_F_RXFCS_BIT,		/* Append FCS to skb */
 
 	/*
 	 * Add your fresh new feature above and remember to update
@@ -98,6 +99,7 @@ enum {
 #define NETIF_F_RXCSUM		__NETIF_F(RXCSUM)
 #define NETIF_F_NOCACHE_COPY	__NETIF_F(NOCACHE_COPY)
 #define NETIF_F_LOOPBACK	__NETIF_F(LOOPBACK)
+#define NETIF_F_RXFCS		__NETIF_F(RXFCS)
 
 /* Features valid for ethtool to change */
 /* = all defined minus driver/device-class-related */
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 80b88fe..62f15e9 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -74,6 +74,7 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_RXCSUM_BIT] =           "rx-checksum",
 	[NETIF_F_NOCACHE_COPY_BIT] =     "tx-nocache-copy",
 	[NETIF_F_LOOPBACK_BIT] =         "loopback",
+	[NETIF_F_RXFCS_BIT] =            "rx-fcs",
 };
 
 static int ethtool_get_features(struct net_device *dev, void __user *useraddr)
-- 
1.7.3.4

