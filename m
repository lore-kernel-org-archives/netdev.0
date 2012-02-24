From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/16] net: Support RX-ALL feature flag.
Date: Fri, 24 Feb 2012 02:12:58 -0800
Message-ID: <1330078389-8203-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1330078389-8203-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:41098 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756162Ab2BXKNP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Feb 2012 05:13:15 -0500
In-Reply-To: <1330078389-8203-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This flag requests that network devices pass all
received frames up the stack, even ones with errors
such as invalid FCS (frame check sum).  This will
allow sniffers to see bad packets and perhaps
give the user some idea how to fix the problem.

Signed-off-by: Ben Greear <greearb@candelatech.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 Documentation/networking/netdev-features.txt |    7 +++++++
 include/linux/netdev_features.h              |    2 ++
 net/core/ethtool.c                           |    1 +
 3 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/netdev-features.txt b/Documentation/networking/netdev-features.txt
index 7d27812..4164f5c 100644
--- a/Documentation/networking/netdev-features.txt
+++ b/Documentation/networking/netdev-features.txt
@@ -158,3 +158,10 @@ VLANs. This may be not useful, though.]
 This requests that the NIC append the Ethernet Frame Checksum (FCS)
 to the end of the skb data.  This allows sniffers and other tools to
 read the CRC recorded by the NIC on receipt of the packet.
+
+*  rx-all
+
+This requests that the NIC receive all possible frames, including errored
+frames (such as bad FCS, etc).  This can be helpful when sniffing a link with
+bad packets on it.  Some NICs may receive more packets if also put into normal
+PROMISC mdoe.
diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index d133186..5ac3212 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -55,6 +55,7 @@ enum {
 	NETIF_F_NOCACHE_COPY_BIT,	/* Use no-cache copyfromuser */
 	NETIF_F_LOOPBACK_BIT,		/* Enable loopback */
 	NETIF_F_RXFCS_BIT,		/* Append FCS to skb pkt data */
+	NETIF_F_RXALL_BIT,		/* Receive errored frames too */
 
 	/*
 	 * Add your fresh new feature above and remember to update
@@ -100,6 +101,7 @@ enum {
 #define NETIF_F_UFO		__NETIF_F(UFO)
 #define NETIF_F_VLAN_CHALLENGED	__NETIF_F(VLAN_CHALLENGED)
 #define NETIF_F_RXFCS		__NETIF_F(RXFCS)
+#define NETIF_F_RXALL		__NETIF_F(RXALL)
 
 /* Features valid for ethtool to change */
 /* = all defined minus driver/device-class-related */
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 0801619..6d6d7d2 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -74,6 +74,7 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_NOCACHE_COPY_BIT] =     "tx-nocache-copy",
 	[NETIF_F_LOOPBACK_BIT] =         "loopback",
 	[NETIF_F_RXFCS_BIT] =            "rx-fcs",
+	[NETIF_F_RXALL_BIT] =            "rx-all",
 };
 
 static int ethtool_get_features(struct net_device *dev, void __user *useraddr)
-- 
1.7.7.6
