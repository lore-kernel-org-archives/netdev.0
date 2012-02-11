From: greearb@candelatech.com
Subject: [PATCH v3 07/16] net:  Support RX-ALL feature flag.
Date: Fri, 10 Feb 2012 17:04:25 -0800
Message-ID: <1328922274-23993-8-git-send-email-greearb@candelatech.com>
References: <1328922274-23993-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:55862 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761219Ab2BKBFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 20:05:50 -0500
In-Reply-To: <1328922274-23993-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This flag requests that network devices pass all
received frames up the stack, even ones with errors
such as invalid FCS (frame check sum).  This will
allow sniffers to see bad packets and perhaps
give the user some idea how to fix the problem.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 7d27812... 4164f5c... M	Documentation/networking/netdev-features.txt
:100644 100644 d133186... 5ac3212... M	include/linux/netdev_features.h
:100644 100644 0801619... 6d6d7d2... M	net/core/ethtool.c
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
1.7.3.4
