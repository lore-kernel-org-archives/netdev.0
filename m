From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [RFCv2 PATCH net-next 2/3] net: add MACsec netdevice priv_flags and helper
Date: Tue,  2 Feb 2016 14:29:20 +0100
Message-ID: <18853ebce2187b633362be24bcec4567d75ab1ef.1454404823.git.sd@queasysnail.net>
References: <cover.1454404823.git.sd@queasysnail.net>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Paolo Abeni <pabeni@redhat.com>,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48799 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755276AbcBBN3k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 08:29:40 -0500
In-Reply-To: <cover.1454404823.git.sd@queasysnail.net>
In-Reply-To: <cover.1454404823.git.sd@queasysnail.net>
References: <cover.1454404823.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
v2: add kerneldoc comment, detected by kbuild robot

 include/linux/netdevice.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 289c2314d766..440892f1a1d1 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1291,6 +1291,7 @@ struct net_device_ops {
  * @IFF_OPENVSWITCH: device is a Open vSwitch master
  * @IFF_L3MDEV_SLAVE: device is enslaved to an L3 master device
  * @IFF_TEAM: device is a team device
+ * @IFF_MACSEC: device is a MACsec device
  */
 enum netdev_priv_flags {
 	IFF_802_1Q_VLAN			= 1<<0,
@@ -1318,6 +1319,7 @@ enum netdev_priv_flags {
 	IFF_OPENVSWITCH			= 1<<22,
 	IFF_L3MDEV_SLAVE		= 1<<23,
 	IFF_TEAM			= 1<<24,
+	IFF_MACSEC			= 1<<25,
 };
 
 #define IFF_802_1Q_VLAN			IFF_802_1Q_VLAN
@@ -1345,6 +1347,7 @@ enum netdev_priv_flags {
 #define IFF_OPENVSWITCH			IFF_OPENVSWITCH
 #define IFF_L3MDEV_SLAVE		IFF_L3MDEV_SLAVE
 #define IFF_TEAM			IFF_TEAM
+#define IFF_MACSEC			IFF_MACSEC
 
 /**
  *	struct net_device - The DEVICE structure.
@@ -3965,6 +3968,11 @@ static inline void skb_gso_error_unwind(struct sk_buff *skb, __be16 protocol,
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
2.7.0
