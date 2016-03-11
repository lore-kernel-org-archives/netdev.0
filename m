From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net-next v2 2/3] net: add MACsec netdevice priv_flags and helper
Date: Fri, 11 Mar 2016 18:07:32 +0100
Message-ID: <d01a06224f4153ace1bd7fa5e2312aa107978349.1457714618.git.sd@queasysnail.net>
References: <cover.1457714618.git.sd@queasysnail.net>
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Paolo Abeni <pabeni@redhat.com>, stephen@networkplumber.org,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47059 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932970AbcCKRIl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2016 12:08:41 -0500
In-Reply-To: <cover.1457714618.git.sd@queasysnail.net>
In-Reply-To: <cover.1457714618.git.sd@queasysnail.net>
References: <cover.1457714618.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
v2: no change
v1: rebase
RFCv2: add kerneldoc comment, detected by kbuild robot
---
 include/linux/netdevice.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 41df0b450757..be693b34662f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1328,6 +1328,7 @@ struct net_device_ops {
  * @IFF_RXFH_CONFIGURED: device has had Rx Flow indirection table configured
  * @IFF_PHONY_HEADROOM: the headroom value is controlled by an external
  *	entity (i.e. the master device for bridged veth)
+ * @IFF_MACSEC: device is a MACsec device
  */
 enum netdev_priv_flags {
 	IFF_802_1Q_VLAN			= 1<<0,
@@ -1357,6 +1358,7 @@ enum netdev_priv_flags {
 	IFF_TEAM			= 1<<24,
 	IFF_RXFH_CONFIGURED		= 1<<25,
 	IFF_PHONY_HEADROOM		= 1<<26,
+	IFF_MACSEC			= 1<<27,
 };
 
 #define IFF_802_1Q_VLAN			IFF_802_1Q_VLAN
@@ -1385,6 +1387,7 @@ enum netdev_priv_flags {
 #define IFF_L3MDEV_SLAVE		IFF_L3MDEV_SLAVE
 #define IFF_TEAM			IFF_TEAM
 #define IFF_RXFH_CONFIGURED		IFF_RXFH_CONFIGURED
+#define IFF_MACSEC			IFF_MACSEC
 
 /**
  *	struct net_device - The DEVICE structure.
@@ -4045,6 +4048,11 @@ static inline void skb_gso_error_unwind(struct sk_buff *skb, __be16 protocol,
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
2.7.2
