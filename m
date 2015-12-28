From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [RFC PATCH net-next 2/3] net: add MACsec netdevice priv_flags and helper
Date: Mon, 28 Dec 2015 13:38:29 +0100
Message-ID: <4f179497d02f9d186559e0416e6fac74b575db95.1450964358.git.sd@queasysnail.net>
References: <cover.1450964358.git.sd@queasysnail.net>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42716 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751719AbbL1Mjx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Dec 2015 07:39:53 -0500
In-Reply-To: <cover.1450964358.git.sd@queasysnail.net>
In-Reply-To: <cover.1450964358.git.sd@queasysnail.net>
References: <cover.1450964358.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/linux/netdevice.h | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c20b814e46a0..4f80f621ecf9 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1319,6 +1319,7 @@ enum netdev_priv_flags {
 	IFF_OPENVSWITCH			= 1<<22,
 	IFF_L3MDEV_SLAVE		= 1<<23,
 	IFF_TEAM			= 1<<24,
+	IFF_MACSEC			= 1<<25,
 };
 
 #define IFF_802_1Q_VLAN			IFF_802_1Q_VLAN
@@ -1346,6 +1347,7 @@ enum netdev_priv_flags {
 #define IFF_OPENVSWITCH			IFF_OPENVSWITCH
 #define IFF_L3MDEV_SLAVE		IFF_L3MDEV_SLAVE
 #define IFF_TEAM			IFF_TEAM
+#define IFF_MACSEC			IFF_MACSEC
 
 /**
  *	struct net_device - The DEVICE structure.
@@ -3964,6 +3966,11 @@ static inline void skb_gso_error_unwind(struct sk_buff *skb, __be16 protocol,
 	skb->mac_len = mac_len;
 }
 
+static inline bool netif_is_macsec(const struct net_device *dev)
+{
+	return dev->priv_flags & IFF_MACSEC;
+}
+
 static inline bool netif_is_macvlan(const struct net_device *dev)
 {
 	return dev->priv_flags & IFF_MACVLAN;
-- 
2.6.4
