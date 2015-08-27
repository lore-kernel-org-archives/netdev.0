From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 4/6] net: kill long time unused bonding private flags
Date: Thu, 27 Aug 2015 09:31:21 +0200
Message-ID: <1440660683-20086-5-git-send-email-jiri@resnulli.us>
References: <1440660683-20086-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, simon.horman@netronome.com,
	f.fainelli@gmail.com, Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:37208 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751656AbbH0Hbb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 03:31:31 -0400
Received: by widdq5 with SMTP id dq5so35777409wid.0
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 00:31:30 -0700 (PDT)
In-Reply-To: <1440660683-20086-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

We don't use them for years, just kill them now.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
v1->v2:
- no change
---
 include/linux/netdevice.h | 57 +++++++++++++++++------------------------------
 1 file changed, 21 insertions(+), 36 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 6656a43..88a0069 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1240,13 +1240,8 @@ struct net_device_ops {
  *
  * @IFF_802_1Q_VLAN: 802.1Q VLAN device
  * @IFF_EBRIDGE: Ethernet bridging device
- * @IFF_SLAVE_INACTIVE: bonding slave not the curr. active
- * @IFF_MASTER_8023AD: bonding master, 802.3ad
- * @IFF_MASTER_ALB: bonding master, balance-alb
  * @IFF_BONDING: bonding master or slave
- * @IFF_SLAVE_NEEDARP: need ARPs for validation
  * @IFF_ISATAP: ISATAP interface (RFC4214)
- * @IFF_MASTER_ARPMON: bonding master, ARP mon in use
  * @IFF_WAN_HDLC: WAN HDLC device
  * @IFF_XMIT_DST_RELEASE: dev_hard_start_xmit() is allowed to
  *	release skb->dst
@@ -1269,43 +1264,33 @@ struct net_device_ops {
 enum netdev_priv_flags {
 	IFF_802_1Q_VLAN			= 1<<0,
 	IFF_EBRIDGE			= 1<<1,
-	IFF_SLAVE_INACTIVE		= 1<<2,
-	IFF_MASTER_8023AD		= 1<<3,
-	IFF_MASTER_ALB			= 1<<4,
-	IFF_BONDING			= 1<<5,
-	IFF_SLAVE_NEEDARP		= 1<<6,
-	IFF_ISATAP			= 1<<7,
-	IFF_MASTER_ARPMON		= 1<<8,
-	IFF_WAN_HDLC			= 1<<9,
-	IFF_XMIT_DST_RELEASE		= 1<<10,
-	IFF_DONT_BRIDGE			= 1<<11,
-	IFF_DISABLE_NETPOLL		= 1<<12,
-	IFF_MACVLAN_PORT		= 1<<13,
-	IFF_BRIDGE_PORT			= 1<<14,
-	IFF_OVS_DATAPATH		= 1<<15,
-	IFF_TX_SKB_SHARING		= 1<<16,
-	IFF_UNICAST_FLT			= 1<<17,
-	IFF_TEAM_PORT			= 1<<18,
-	IFF_SUPP_NOFCS			= 1<<19,
-	IFF_LIVE_ADDR_CHANGE		= 1<<20,
-	IFF_MACVLAN			= 1<<21,
-	IFF_XMIT_DST_RELEASE_PERM	= 1<<22,
-	IFF_IPVLAN_MASTER		= 1<<23,
-	IFF_IPVLAN_SLAVE		= 1<<24,
-	IFF_VRF_MASTER			= 1<<25,
-	IFF_NO_QUEUE			= 1<<26,
-	IFF_OPENVSWITCH			= 1<<27,
+	IFF_BONDING			= 1<<2,
+	IFF_ISATAP			= 1<<3,
+	IFF_WAN_HDLC			= 1<<4,
+	IFF_XMIT_DST_RELEASE		= 1<<5,
+	IFF_DONT_BRIDGE			= 1<<6,
+	IFF_DISABLE_NETPOLL		= 1<<7,
+	IFF_MACVLAN_PORT		= 1<<8,
+	IFF_BRIDGE_PORT			= 1<<9,
+	IFF_OVS_DATAPATH		= 1<<10,
+	IFF_TX_SKB_SHARING		= 1<<11,
+	IFF_UNICAST_FLT			= 1<<12,
+	IFF_TEAM_PORT			= 1<<13,
+	IFF_SUPP_NOFCS			= 1<<14,
+	IFF_LIVE_ADDR_CHANGE		= 1<<15,
+	IFF_MACVLAN			= 1<<16,
+	IFF_XMIT_DST_RELEASE_PERM	= 1<<17,
+	IFF_IPVLAN_MASTER		= 1<<18,
+	IFF_IPVLAN_SLAVE		= 1<<19,
+	IFF_VRF_MASTER			= 1<<20,
+	IFF_NO_QUEUE			= 1<<21,
+	IFF_OPENVSWITCH			= 1<<22,
 };
 
 #define IFF_802_1Q_VLAN			IFF_802_1Q_VLAN
 #define IFF_EBRIDGE			IFF_EBRIDGE
-#define IFF_SLAVE_INACTIVE		IFF_SLAVE_INACTIVE
-#define IFF_MASTER_8023AD		IFF_MASTER_8023AD
-#define IFF_MASTER_ALB			IFF_MASTER_ALB
 #define IFF_BONDING			IFF_BONDING
-#define IFF_SLAVE_NEEDARP		IFF_SLAVE_NEEDARP
 #define IFF_ISATAP			IFF_ISATAP
-#define IFF_MASTER_ARPMON		IFF_MASTER_ARPMON
 #define IFF_WAN_HDLC			IFF_WAN_HDLC
 #define IFF_XMIT_DST_RELEASE		IFF_XMIT_DST_RELEASE
 #define IFF_DONT_BRIDGE			IFF_DONT_BRIDGE
-- 
1.9.3
