From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: [PATCH v2 2/2] net: move net_device priv_flags out from UAPI
Date: Tue, 25 Feb 2014 17:15:13 -0800
Message-ID: <1393377313-28695-3-git-send-email-mcgrof@do-not-panic.com>
References: <1393377313-28695-1-git-send-email-mcgrof@do-not-panic.com>
Cc: f.fainelli@gmail.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@suse.com>
To: ben@decadent.org.uk, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:54781 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751959AbaBZBP3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 20:15:29 -0500
In-Reply-To: <1393377313-28695-1-git-send-email-mcgrof@do-not-panic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Luis R. Rodriguez" <mcgrof@suse.com>

These are private to userspace, and they're unstable
anyway and can be shuffled at will (see 080e4130b1fb)
so any userspace application relying on them is on crack.

Test compiled with allyesconfig.

mcgrof@drvbp1 /pub/mem/mcgrof/net-next (git::master)$ make allyesconfig
mcgrof@drvbp1 /pub/mem/mcgrof/net-next (git::master)$ time make -j 20
...
  BUILD   arch/x86/boot/bzImage
Setup is 16992 bytes (padded to 17408 bytes).
System is 56153 kB
CRC 721d2751
Kernel: arch/x86/boot/bzImage is ready  (#1)
real    19m35.744s
user    280m37.984s
sys     27m54.104s

Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: Ben Hutchings <ben@decadent.org.uk>
Cc: Florian Fainelli <f.fainelli@gmail.com>
Cc: David Miller <davem@davemloft.net>
Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>
---
 include/linux/netdevice.h | 83 +++++++++++++++++++++++++++++++++++++++++++++++
 include/uapi/linux/if.h   | 83 -----------------------------------------------
 2 files changed, 83 insertions(+), 83 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5e47565..8c4a364 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1147,6 +1147,89 @@ struct net_device_ops {
 							void *priv);
 };
 
+/**
+ * enum net_device_priv_flags - &struct net_device priv_flags
+ *
+ * These are the &struct net_device, they are only set internally
+ * by drivers and used in the kernel. These flags are invisible to
+ * userspace, this means that the order of these flags can change
+ * during any kernel release.
+ *
+ * You should have a pretty good reason to be extending these flags.
+ *
+ * @IFF_802_1Q_VLAN: 802.1Q VLAN device
+ * @IFF_EBRIDGE: Ethernet bridging device
+ * @IFF_SLAVE_INACTIVE: bonding slave not the curr. active
+ * @IFF_MASTER_8023AD: bonding master, 802.3ad
+ * @IFF_MASTER_ALB: bonding master, balance-alb
+ * @IFF_BONDING: bonding master or slave
+ * @IFF_SLAVE_NEEDARP: need ARPs for validation
+ * @IFF_ISATAP: ISATAP interface (RFC4214)
+ * @IFF_MASTER_ARPMON: bonding master, ARP mon in use
+ * @IFF_WAN_HDLC: WAN HDLC device
+ * @IFF_XMIT_DST_RELEASE: dev_hard_start_xmit() is allowed to
+ *	release skb->dst
+ * @IFF_DONT_BRIDGE: disallow bridging this ether dev
+ * @IFF_DISABLE_NETPOLL: disable netpoll at run-time
+ * @IFF_MACVLAN_PORT: device used as macvlan port
+ * @IFF_BRIDGE_PORT: device used as bridge port
+ * @IFF_OVS_DATAPATH: device used as Open vSwitch datapath port
+ * @IFF_TX_SKB_SHARING: The interface supports sharing skbs on transmit
+ * @IFF_UNICAST_FLT: Supports unicast filtering
+ * @IFF_TEAM_PORT: device used as team port
+ * @IFF_SUPP_NOFCS: device supports sending custom FCS
+ * @IFF_LIVE_ADDR_CHANGE: device supports hardware address
+ *	change when it's running
+ * @IFF_MACVLAN: Macvlan device
+ */
+enum netdev_priv_flags {
+	IFF_802_1Q_VLAN			= 1<<0,
+	IFF_EBRIDGE			= 1<<1,
+	IFF_SLAVE_INACTIVE		= 1<<2,
+	IFF_MASTER_8023AD		= 1<<3,
+	IFF_MASTER_ALB			= 1<<4,
+	IFF_BONDING			= 1<<5,
+	IFF_SLAVE_NEEDARP		= 1<<6,
+	IFF_ISATAP			= 1<<7,
+	IFF_MASTER_ARPMON		= 1<<8,
+	IFF_WAN_HDLC			= 1<<9,
+	IFF_XMIT_DST_RELEASE		= 1<<10,
+	IFF_DONT_BRIDGE			= 1<<11,
+	IFF_DISABLE_NETPOLL		= 1<<12,
+	IFF_MACVLAN_PORT		= 1<<13,
+	IFF_BRIDGE_PORT			= 1<<14,
+	IFF_OVS_DATAPATH		= 1<<15,
+	IFF_TX_SKB_SHARING		= 1<<16,
+	IFF_UNICAST_FLT			= 1<<17,
+	IFF_TEAM_PORT			= 1<<18,
+	IFF_SUPP_NOFCS			= 1<<19,
+	IFF_LIVE_ADDR_CHANGE		= 1<<20,
+	IFF_MACVLAN			= 1<<21,
+};
+
+#define IFF_802_1Q_VLAN			IFF_802_1Q_VLAN
+#define IFF_EBRIDGE			IFF_EBRIDGE
+#define IFF_SLAVE_INACTIVE		IFF_SLAVE_INACTIVE
+#define IFF_MASTER_8023AD		IFF_MASTER_8023AD
+#define IFF_MASTER_ALB			IFF_MASTER_ALB
+#define IFF_BONDING			IFF_BONDING
+#define IFF_SLAVE_NEEDARP		IFF_SLAVE_NEEDARP
+#define IFF_ISATAP			IFF_ISATAP
+#define IFF_MASTER_ARPMON		IFF_MASTER_ARPMON
+#define IFF_WAN_HDLC			IFF_WAN_HDLC
+#define IFF_XMIT_DST_RELEASE		IFF_XMIT_DST_RELEASE
+#define IFF_DONT_BRIDGE			IFF_DONT_BRIDGE
+#define IFF_DISABLE_NETPOLL		IFF_DISABLE_NETPOLL
+#define IFF_MACVLAN_PORT		IFF_MACVLAN_PORT
+#define IFF_BRIDGE_PORT			IFF_BRIDGE_PORT
+#define IFF_OVS_DATAPATH		IFF_OVS_DATAPATH
+#define IFF_TX_SKB_SHARING		IFF_TX_SKB_SHARING
+#define IFF_UNICAST_FLT			IFF_UNICAST_FLT
+#define IFF_TEAM_PORT			IFF_TEAM_PORT
+#define IFF_SUPP_NOFCS			IFF_SUPP_NOFCS
+#define IFF_LIVE_ADDR_CHANGE		IFF_LIVE_ADDR_CHANGE
+#define IFF_MACVLAN			IFF_MACVLAN
+
 /*
  *	The DEVICE structure.
  *	Actually, this whole structure is a big mistake.  It mixes I/O
diff --git a/include/uapi/linux/if.h b/include/uapi/linux/if.h
index 42ec879..9cf2394 100644
--- a/include/uapi/linux/if.h
+++ b/include/uapi/linux/if.h
@@ -112,89 +112,6 @@ enum net_device_flags {
 #define IFF_VOLATILE	(IFF_LOOPBACK|IFF_POINTOPOINT|IFF_BROADCAST|IFF_ECHO|\
 		IFF_MASTER|IFF_SLAVE|IFF_RUNNING|IFF_LOWER_UP|IFF_DORMANT)
 
-/**
- * enum net_device_priv_flags - &struct net_device priv_flags
- *
- * These are the &struct net_device, they are only set internally
- * by drivers and used in the kernel. These flags are invisible to
- * userspace, this means that the order of these flags can change
- * during any kernel release.
- *
- * You should have a pretty good reason to be extending these flags.
- *
- * @IFF_802_1Q_VLAN: 802.1Q VLAN device
- * @IFF_EBRIDGE: Ethernet bridging device
- * @IFF_SLAVE_INACTIVE: bonding slave not the curr. active
- * @IFF_MASTER_8023AD: bonding master, 802.3ad
- * @IFF_MASTER_ALB: bonding master, balance-alb
- * @IFF_BONDING: bonding master or slave
- * @IFF_SLAVE_NEEDARP: need ARPs for validation
- * @IFF_ISATAP: ISATAP interface (RFC4214)
- * @IFF_MASTER_ARPMON: bonding master, ARP mon in use
- * @IFF_WAN_HDLC: WAN HDLC device
- * @IFF_XMIT_DST_RELEASE: dev_hard_start_xmit() is allowed to
- *	release skb->dst
- * @IFF_DONT_BRIDGE: disallow bridging this ether dev
- * @IFF_DISABLE_NETPOLL: disable netpoll at run-time
- * @IFF_MACVLAN_PORT: device used as macvlan port
- * @IFF_BRIDGE_PORT: device used as bridge port
- * @IFF_OVS_DATAPATH: device used as Open vSwitch datapath port
- * @IFF_TX_SKB_SHARING: The interface supports sharing skbs on transmit
- * @IFF_UNICAST_FLT: Supports unicast filtering
- * @IFF_TEAM_PORT: device used as team port
- * @IFF_SUPP_NOFCS: device supports sending custom FCS
- * @IFF_LIVE_ADDR_CHANGE: device supports hardware address
- *	change when it's running
- * @IFF_MACVLAN: Macvlan device
- */
-enum netdev_priv_flags {
-	IFF_802_1Q_VLAN			= 1<<0,
-	IFF_EBRIDGE			= 1<<1,
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
-};
-
-#define IFF_802_1Q_VLAN			IFF_802_1Q_VLAN
-#define IFF_EBRIDGE			IFF_EBRIDGE
-#define IFF_SLAVE_INACTIVE		IFF_SLAVE_INACTIVE
-#define IFF_MASTER_8023AD		IFF_MASTER_8023AD
-#define IFF_MASTER_ALB			IFF_MASTER_ALB
-#define IFF_BONDING			IFF_BONDING
-#define IFF_SLAVE_NEEDARP		IFF_SLAVE_NEEDARP
-#define IFF_ISATAP			IFF_ISATAP
-#define IFF_MASTER_ARPMON		IFF_MASTER_ARPMON
-#define IFF_WAN_HDLC			IFF_WAN_HDLC
-#define IFF_XMIT_DST_RELEASE		IFF_XMIT_DST_RELEASE
-#define IFF_DONT_BRIDGE			IFF_DONT_BRIDGE
-#define IFF_DISABLE_NETPOLL		IFF_DISABLE_NETPOLL
-#define IFF_MACVLAN_PORT		IFF_MACVLAN_PORT
-#define IFF_BRIDGE_PORT			IFF_BRIDGE_PORT
-#define IFF_OVS_DATAPATH		IFF_OVS_DATAPATH
-#define IFF_TX_SKB_SHARING		IFF_TX_SKB_SHARING
-#define IFF_UNICAST_FLT			IFF_UNICAST_FLT
-#define IFF_TEAM_PORT			IFF_TEAM_PORT
-#define IFF_SUPP_NOFCS			IFF_SUPP_NOFCS
-#define IFF_LIVE_ADDR_CHANGE		IFF_LIVE_ADDR_CHANGE
-#define IFF_MACVLAN			IFF_MACVLAN
-
 #define IF_GET_IFACE	0x0001		/* for querying only */
 #define IF_GET_PROTO	0x0002
 
-- 
1.8.5.3
