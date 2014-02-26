From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: [PATCH v2 1/2] net: kdoc struct net_device flags and priv_flags
Date: Tue, 25 Feb 2014 17:15:12 -0800
Message-ID: <1393377313-28695-2-git-send-email-mcgrof@do-not-panic.com>
References: <1393377313-28695-1-git-send-email-mcgrof@do-not-panic.com>
Cc: f.fainelli@gmail.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@suse.com>
To: ben@decadent.org.uk, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393377313-28695-1-git-send-email-mcgrof@do-not-panic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Luis R. Rodriguez" <mcgrof@suse.com>

We have documentation for these flags but they're scattered
all over the place. #defines don't allow documentation to be
written easily so to help to start bringing some documentation
together use the enums kdoc practice but keep the defines to
allow userspace to be able to #ifdef them.

I've verified the same values are assigned before and after
with a simple userspace test program [0] and checksumming the
output.

[0] http://drvbp1.linux-foundation.org/~mcgrof/kdoc/netdev_flags/

mcgrof@gnat ~/tmp $ ./check-flags | sha1sum
0ec5b6b1840aa3bb9ce464e61c564820871c92c3  -

Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: Ben Hutchings <ben@decadent.org.uk>
Cc: Florian Fainelli <f.fainelli@gmail.com>
Cc: David Miller <davem@davemloft.net>
Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>
---
 include/uapi/linux/if.h | 213 ++++++++++++++++++++++++++++++++++++------------
 1 file changed, 161 insertions(+), 52 deletions(-)

diff --git a/include/uapi/linux/if.h b/include/uapi/linux/if.h
index d758163..42ec879 100644
--- a/include/uapi/linux/if.h
+++ b/include/uapi/linux/if.h
@@ -27,64 +27,173 @@
 #define	IFALIASZ	256
 #include <linux/hdlc/ioctl.h>
 
-/* Standard interface flags (netdevice->flags). */
-#define	IFF_UP		0x1		/* interface is up		*/
-#define	IFF_BROADCAST	0x2		/* broadcast address valid	*/
-#define	IFF_DEBUG	0x4		/* turn on debugging		*/
-#define	IFF_LOOPBACK	0x8		/* is a loopback net		*/
-#define	IFF_POINTOPOINT	0x10		/* interface is has p-p link	*/
-#define	IFF_NOTRAILERS	0x20		/* avoid use of trailers	*/
-#define	IFF_RUNNING	0x40		/* interface RFC2863 OPER_UP	*/
-#define	IFF_NOARP	0x80		/* no ARP protocol		*/
-#define	IFF_PROMISC	0x100		/* receive all packets		*/
-#define	IFF_ALLMULTI	0x200		/* receive all multicast packets*/
-
-#define IFF_MASTER	0x400		/* master of a load balancer 	*/
-#define IFF_SLAVE	0x800		/* slave of a load balancer	*/
-
-#define IFF_MULTICAST	0x1000		/* Supports multicast		*/
-
-#define IFF_PORTSEL	0x2000          /* can set media type		*/
-#define IFF_AUTOMEDIA	0x4000		/* auto media select active	*/
-#define IFF_DYNAMIC	0x8000		/* dialup device with changing addresses*/
-
-#define IFF_LOWER_UP	0x10000		/* driver signals L1 up		*/
-#define IFF_DORMANT	0x20000		/* driver signals dormant	*/
+/**
+ * enum net_device_flags - &struct net_device flags
+ *
+ * These are the &struct net_device flags, they can be set by drivers, the
+ * kernel and some can be triggered by userspace. Userspace can query and
+ * set these flags using userspace utilities but there is also a sysfs
+ * entry available for all dev flags which can be queried and set. These flags
+ * are shared for all types of net_devices. The sysfs entries are available
+ * via /sys/class/net/<dev>/flags. Flags which can be toggled through sysfs
+ * are annotated below, note that only a few flags can be toggled and some
+ * other flags are always always preserved from the original net_device flags
+ * even if you try to set them via sysfs. Flags which are always preserved
+ * are kept under the flag grouping @IFF_VOLATILE. Flags which are volatile
+ * are annotated below as such.
+ *
+ * You should have a pretty good reason to be extending these flags.
+ *
+ * @IFF_UP: interface is up. Can be toggled through sysfs.
+ * @IFF_BROADCAST: broadcast address valid. Volatile.
+ * @IFF_DEBUG: turn on debugging. Can be toggled through sysfs.
+ * @IFF_LOOPBACK: is a loopback net. Volatile.
+ * @IFF_POINTOPOINT: interface is has p-p link. Volatile.
+ * @IFF_NOTRAILERS: avoid use of trailers. Can be toggled through sysfs.
+ *	Volatile.
+ * @IFF_RUNNING: interface RFC2863 OPER_UP. Volatile.
+ * @IFF_NOARP: no ARP protocol. Can be toggled through sysfs. Volatile.
+ * @IFF_PROMISC: receive all packets. Can be toggled through sysfs.
+ * @IFF_ALLMULTI: receive all multicast packets. Can be toggled through
+ *	sysfs.
+ * @IFF_MASTER: master of a load balancer. Volatile.
+ * @IFF_SLAVE: slave of a load balancer. Volatile.
+ * @IFF_MULTICAST: Supports multicast. Can be toggled through sysfs.
+ * @IFF_PORTSEL: can set media type. Can be toggled through sysfs.
+ * @IFF_AUTOMEDIA: auto media select active. Can be toggled through sysfs.
+ * @IFF_DYNAMIC: dialup device with changing addresses. Can be toggled
+ *	through sysfs.
+ * @IFF_LOWER_UP: driver signals L1 up. Volatile.
+ * @IFF_DORMANT: driver signals dormant. Volatile.
+ * @IFF_ECHO: echo sent packets. Volatile.
+ */
+enum net_device_flags {
+	IFF_UP				= 1<<0,  /* sysfs */
+	IFF_BROADCAST			= 1<<1,  /* volatile */
+	IFF_DEBUG			= 1<<2,  /* sysfs */
+	IFF_LOOPBACK			= 1<<3,  /* volatile */
+	IFF_POINTOPOINT			= 1<<4,  /* volatile */
+	IFF_NOTRAILERS			= 1<<5,  /* sysfs */
+	IFF_RUNNING			= 1<<6,  /* volatile */
+	IFF_NOARP			= 1<<7,  /* sysfs */
+	IFF_PROMISC			= 1<<8,  /* sysfs */
+	IFF_ALLMULTI			= 1<<9,  /* sysfs */
+	IFF_MASTER			= 1<<10, /* volatile */
+	IFF_SLAVE			= 1<<11, /* volatile */
+	IFF_MULTICAST			= 1<<12, /* sysfs */
+	IFF_PORTSEL			= 1<<13, /* sysfs */
+	IFF_AUTOMEDIA			= 1<<14, /* sysfs */
+	IFF_DYNAMIC			= 1<<15, /* sysfs */
+	IFF_LOWER_UP			= 1<<16, /* volatile */
+	IFF_DORMANT			= 1<<17, /* volatile */
+	IFF_ECHO			= 1<<18, /* volatile */
+};
 
-#define IFF_ECHO	0x40000		/* echo sent packets		*/
+#define IFF_UP				IFF_UP
+#define IFF_BROADCAST			IFF_BROADCAST
+#define IFF_DEBUG			IFF_DEBUG
+#define IFF_LOOPBACK			IFF_LOOPBACK
+#define IFF_POINTOPOINT			IFF_POINTOPOINT
+#define IFF_NOTRAILERS			IFF_NOTRAILERS
+#define IFF_RUNNING			IFF_RUNNING
+#define IFF_NOARP			IFF_NOARP
+#define IFF_PROMISC			IFF_PROMISC
+#define IFF_ALLMULTI			IFF_ALLMULTI
+#define IFF_MASTER			IFF_MASTER
+#define IFF_SLAVE			IFF_SLAVE
+#define IFF_MULTICAST			IFF_MULTICAST
+#define IFF_PORTSEL			IFF_PORTSEL
+#define IFF_AUTOMEDIA			IFF_AUTOMEDIA
+#define IFF_DYNAMIC			IFF_DYNAMIC
+#define IFF_LOWER_UP			IFF_LOWER_UP
+#define IFF_DORMANT			IFF_DORMANT
+#define IFF_ECHO			IFF_ECHO
 
 #define IFF_VOLATILE	(IFF_LOOPBACK|IFF_POINTOPOINT|IFF_BROADCAST|IFF_ECHO|\
 		IFF_MASTER|IFF_SLAVE|IFF_RUNNING|IFF_LOWER_UP|IFF_DORMANT)
 
-/* Private (from user) interface flags (netdevice->priv_flags). */
-#define IFF_802_1Q_VLAN 0x1             /* 802.1Q VLAN device.          */
-#define IFF_EBRIDGE	0x2		/* Ethernet bridging device.	*/
-#define IFF_SLAVE_INACTIVE	0x4	/* bonding slave not the curr. active */
-#define IFF_MASTER_8023AD	0x8	/* bonding master, 802.3ad. 	*/
-#define IFF_MASTER_ALB	0x10		/* bonding master, balance-alb.	*/
-#define IFF_BONDING	0x20		/* bonding master or slave	*/
-#define IFF_SLAVE_NEEDARP 0x40		/* need ARPs for validation	*/
-#define IFF_ISATAP	0x80		/* ISATAP interface (RFC4214)	*/
-#define IFF_MASTER_ARPMON 0x100		/* bonding master, ARP mon in use */
-#define IFF_WAN_HDLC	0x200		/* WAN HDLC device		*/
-#define IFF_XMIT_DST_RELEASE 0x400	/* dev_hard_start_xmit() is allowed to
-					 * release skb->dst
-					 */
-#define IFF_DONT_BRIDGE 0x800		/* disallow bridging this ether dev */
-#define IFF_DISABLE_NETPOLL	0x1000	/* disable netpoll at run-time */
-#define IFF_MACVLAN_PORT	0x2000	/* device used as macvlan port */
-#define IFF_BRIDGE_PORT	0x4000		/* device used as bridge port */
-#define IFF_OVS_DATAPATH	0x8000	/* device used as Open vSwitch
-					 * datapath port */
-#define IFF_TX_SKB_SHARING	0x10000	/* The interface supports sharing
-					 * skbs on transmit */
-#define IFF_UNICAST_FLT	0x20000		/* Supports unicast filtering	*/
-#define IFF_TEAM_PORT	0x40000		/* device used as team port */
-#define IFF_SUPP_NOFCS	0x80000		/* device supports sending custom FCS */
-#define IFF_LIVE_ADDR_CHANGE 0x100000	/* device supports hardware address
-					 * change when it's running */
-#define IFF_MACVLAN 0x200000		/* Macvlan device */
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
 
 #define IF_GET_IFACE	0x0001		/* for querying only */
 #define IF_GET_PROTO	0x0002
-- 
1.8.5.3
