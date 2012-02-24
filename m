From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/16] net: Support RXFCS feature flag.
Date: Fri, 24 Feb 2012 02:12:54 -0800
Message-ID: <1330078389-8203-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1330078389-8203-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:34282 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753520Ab2BXKNO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Feb 2012 05:13:14 -0500
In-Reply-To: <1330078389-8203-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

When set on hardware that supports the feature,
this causes the Ethernet FCS to be appended
to the end of the skb.

Useful for sniffing packets.

Signed-off-by: Ben Greear <greearb@candelatech.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 Documentation/networking/netdev-features.txt |    6 ++++++
 include/linux/netdev_features.h              |    2 ++
 net/core/ethtool.c                           |    1 +
 3 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/netdev-features.txt b/Documentation/networking/netdev-features.txt
index 4b1c0dc..7d27812 100644
--- a/Documentation/networking/netdev-features.txt
+++ b/Documentation/networking/netdev-features.txt
@@ -152,3 +152,9 @@ NETIF_F_VLAN_CHALLENGED should be set for devices which can't cope with VLAN
 headers. Some drivers set this because the cards can't handle the bigger MTU.
 [FIXME: Those cases could be fixed in VLAN code by allowing only reduced-MTU
 VLANs. This may be not useful, though.]
+
+*  rx-fcs
+
+This requests that the NIC append the Ethernet Frame Checksum (FCS)
+to the end of the skb data.  This allows sniffers and other tools to
+read the CRC recorded by the NIC on receipt of the packet.
diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index 77f5202..d133186 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -54,6 +54,7 @@ enum {
 	NETIF_F_RXCSUM_BIT,		/* Receive checksumming offload */
 	NETIF_F_NOCACHE_COPY_BIT,	/* Use no-cache copyfromuser */
 	NETIF_F_LOOPBACK_BIT,		/* Enable loopback */
+	NETIF_F_RXFCS_BIT,		/* Append FCS to skb pkt data */
 
 	/*
 	 * Add your fresh new feature above and remember to update
@@ -98,6 +99,7 @@ enum {
 #define NETIF_F_TSO		__NETIF_F(TSO)
 #define NETIF_F_UFO		__NETIF_F(UFO)
 #define NETIF_F_VLAN_CHALLENGED	__NETIF_F(VLAN_CHALLENGED)
+#define NETIF_F_RXFCS		__NETIF_F(RXFCS)
 
 /* Features valid for ethtool to change */
 /* = all defined minus driver/device-class-related */
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 3f79db1..0801619 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -73,6 +73,7 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_RXCSUM_BIT] =           "rx-checksum",
 	[NETIF_F_NOCACHE_COPY_BIT] =     "tx-nocache-copy",
 	[NETIF_F_LOOPBACK_BIT] =         "loopback",
+	[NETIF_F_RXFCS_BIT] =            "rx-fcs",
 };
 
 static int ethtool_get_features(struct net_device *dev, void __user *useraddr)
-- 
1.7.7.6
