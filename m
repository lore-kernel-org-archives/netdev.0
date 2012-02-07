From: greearb@candelatech.com
Subject: [RFC 1/2] net:  Support RX-ALL feature flag.
Date: Tue,  7 Feb 2012 15:07:42 -0800
Message-ID: <1328656063-13129-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:41855 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755661Ab2BGXHt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 18:07:49 -0500
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
:100644 100644 0bc0d37... 127acee... M	Documentation/networking/netdev-features.txt
:100644 100644 3bae320... ad963d0... M	include/linux/netdev_features.h
:100644 100644 cf81ccf... 68eff5a... M	net/core/ethtool.c
 Documentation/networking/netdev-features.txt |    6 ++++++
 include/linux/netdev_features.h              |    2 ++
 net/core/ethtool.c                           |    1 +
 3 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/netdev-features.txt b/Documentation/networking/netdev-features.txt
index 0bc0d37..127acee 100644
--- a/Documentation/networking/netdev-features.txt
+++ b/Documentation/networking/netdev-features.txt
@@ -167,3 +167,9 @@ for packets flagged to use this feature.  Instead, the NIC will use the last
 with custom (including mal-formed) Ethernet FCS.  Probably most useful for
 sniffers.  Note that in addition to enabling this device flag, a socket option
 or similar must be used to flag specific SKBs as wanting to use this behaviour.
+
+*  rx-all
+
+This requests that the NIC receive all possible frames, including errored
+frames (such as bad FCS, etc).  This can be helpful when sniffing a link with
+bad packets on it.
diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index 3bae320..ad963d0 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -56,6 +56,7 @@ enum {
 	NETIF_F_LOOPBACK_BIT,		/* Enable loopback */
 	NETIF_F_RXFCS_BIT,		/* Append FCS to skb pkt data */
 	NETIF_F_NOFCS_BIT,		/* Use last 4 bytes of skb as tx FCS */
+	NETIF_F_RXALL_BIT,		/* Receive errored frames too */
 
 	/*
 	 * Add your fresh new feature above and remember to update
@@ -102,6 +103,7 @@ enum {
 #define NETIF_F_VLAN_CHALLENGED	__NETIF_F(VLAN_CHALLENGED)
 #define NETIF_F_RXFCS		__NETIF_F(RXFCS)
 #define NETIF_F_NOFCS		__NETIF_F(NOFCS)
+#define NETIF_F_RXALL		__NETIF_F(RXALL)
 
 /* Features valid for ethtool to change */
 /* = all defined minus driver/device-class-related */
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index cf81ccf..68eff5a 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -75,6 +75,7 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_LOOPBACK_BIT] =         "loopback",
 	[NETIF_F_RXFCS_BIT] =            "rx-fcs",
 	[NETIF_F_NOFCS_BIT] =            "no-fcs",
+	[NETIF_F_RXALL_BIT] =            "rx-all",
 };
 
 static int ethtool_get_features(struct net_device *dev, void __user *useraddr)
-- 
1.7.3.4
