From: Ben Greear <greearb@candelatech.com>
Subject: [PATCH 2/3] rx_all_headers patch
Date: Mon, 24 Nov 2003 23:54:48 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FC30AC8.3080600@candelatech.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010906000305060703090904"
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010906000305060703090904
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


--------------010906000305060703090904
Content-Type: text/plain;
 name="rx_all_headers.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="rx_all_headers.patch"

--- linux-2.4.22/include/linux/netdevice.h	2003-11-24 23:14:20.000000000 -0800
+++ linux-2.4.22.p4s/include/linux/netdevice.h	2003-11-24 19:57:08.000000000 -0800
@@ -310,7 +310,9 @@
 
 	unsigned short		flags;	/* interface flags (a la BSD)	*/
 	unsigned short		gflags;
-        unsigned short          priv_flags; /* Like 'flags' but invisible to userspace. */
+        unsigned short          priv_flags; /* Like 'flags' but invisible to userspace,
+                                             * see: if.h for flag definitions.
+                                             */
         unsigned short          unused_alignment_fixer; /* Because we need priv_flags,
                                                          * and we want to be 32-bit aligned.
                                                          */
@@ -381,8 +383,14 @@
 #define NETIF_F_HW_VLAN_RX	256	/* Receive VLAN hw acceleration */
 #define NETIF_F_HW_VLAN_FILTER	512	/* Receive filtering on VLAN */
 #define NETIF_F_VLAN_CHALLENGED	1024	/* Device cannot handle VLAN packets */
+#define NETIF_F_RX_ALL            2048    /* Can be configured to receive all packets, even
+                                           * ones with busted CRC.  May disable VLAN filtering
+                                           * in the NIC, users should NOT enable this feature
+                                           * unless they understand the consequences. */
+#define NETIF_F_SAVE_CRC          4096    /* Can save FCS in skb, last 4 bytes for ethernet */
 
+  
 	/* Called after device is detached from network. */
 	void			(*uninit)(struct net_device *dev);
 	/* Called after last user reference disappears. */
--- linux-2.4.22/include/linux/if.h	2003-11-24 23:14:20.000000000 -0800
+++ linux-2.4.22.p4s/include/linux/if.h	2003-11-24 19:15:27.000000000 -0800
@@ -50,6 +50,18 @@
 
 /* Private (from user) interface flags (netdevice->priv_flags). */
 #define IFF_802_1Q_VLAN 0x1             /* 802.1Q VLAN device.          */
+#define IFF_PKTGEN_RCV  0x2             /* Registered to receive & consume  Pktgen skbs */
+#define IFF_ACCEPT_LOCAL_ADDRS 0x4      /**  Accept pkts even if they come from a local
+                                         * address.  This lets use send pkts to ourselves
+                                         * over external interfaces (when used in conjunction
+                                         * with SO_BINDTODEVICE
+                                         */
+#define IFF_ACCEPT_ALL_FRAMES  0x8      /** Accept all frames, even ones with bad CRCs.
+                                         * Should only be used in debugging/testing situations
+                                         * Do NOT enable this unless you understand the
+                                         * consequences! */
+#define IFF_SAVE_FCS          0x10      /** Save the Frame Check Sum (FCS) on receive, if
+                                         * possible. */
 
 
 #define IF_GET_IFACE	0x0001		/* for querying only */

--------------010906000305060703090904--
