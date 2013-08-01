From: Joe Perches <joe@perches.com>
Subject: [PATCH V3 1/3] uapi: Convert some uses of 6 to ETH_ALEN
Date: Thu,  1 Aug 2013 16:17:47 -0700
Message-ID: <87cc4bbcb51cb65dff670cfb6d4bc66b51e319c3.1375398692.git.joe@perches.com>
References: <20130801.143137.331385226409040561.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: wimax@linuxwimax.org, "Michael S. Tsirkin" <mst@redhat.com>,
	linux-kernel@vger.kernel.org,
	Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>,
	linux-wimax@intel.com, Bart De Schuymer <bart.de.schuymer@pandora.be>,
	netfilter-devel@vger.kernel.org, virtualization@lists.linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20130801.143137.331385226409040561.davem@davemloft.net>
In-Reply-To: <cover.1375398692.git.joe@perches.com>
References: <cover.1375398692.git.joe@perches.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Use the #define where appropriate.

Add #include <linux/if_ether.h>
where appropriate too.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/uapi/linux/dn.h                           | 3 ++-
 include/uapi/linux/if_bridge.h                    | 3 ++-
 include/uapi/linux/netfilter_bridge/ebt_802_3.h   | 5 +++--
 include/uapi/linux/netfilter_ipv4/ipt_CLUSTERIP.h | 3 ++-
 include/uapi/linux/virtio_net.h                   | 2 +-
 include/uapi/linux/wimax/i2400m.h                 | 4 ++--
 6 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/include/uapi/linux/dn.h b/include/uapi/linux/dn.h
index 9c50445..5fbdd3d 100644
--- a/include/uapi/linux/dn.h
+++ b/include/uapi/linux/dn.h
@@ -2,6 +2,7 @@
 #define _LINUX_DN_H
 
 #include <linux/types.h>
+#include <linux/if_ether.h>
 
 /*
 
@@ -120,7 +121,7 @@ struct linkinfo_dn {
  * Ethernet address format (for DECnet)
  */
 union etheraddress {
-        __u8 dne_addr[6];             /* Full ethernet address */
+        __u8 dne_addr[ETH_ALEN];      /* Full ethernet address */
   struct {
                 __u8 dne_hiord[4];    /* DECnet HIORD prefix   */
                 __u8 dne_nodeaddr[2]; /* DECnet node address   */
diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
index 2d70d79..39f621a 100644
--- a/include/uapi/linux/if_bridge.h
+++ b/include/uapi/linux/if_bridge.h
@@ -14,6 +14,7 @@
 #define _UAPI_LINUX_IF_BRIDGE_H
 
 #include <linux/types.h>
+#include <linux/if_ether.h>
 
 #define SYSFS_BRIDGE_ATTR	"bridge"
 #define SYSFS_BRIDGE_FDB	"brforward"
@@ -88,7 +89,7 @@ struct __port_info {
 };
 
 struct __fdb_entry {
-	__u8 mac_addr[6];
+	__u8 mac_addr[ETH_ALEN];
 	__u8 port_no;
 	__u8 is_local;
 	__u32 ageing_timer_value;
diff --git a/include/uapi/linux/netfilter_bridge/ebt_802_3.h b/include/uapi/linux/netfilter_bridge/ebt_802_3.h
index 5bf8491..f37522a 100644
--- a/include/uapi/linux/netfilter_bridge/ebt_802_3.h
+++ b/include/uapi/linux/netfilter_bridge/ebt_802_3.h
@@ -2,6 +2,7 @@
 #define _UAPI__LINUX_BRIDGE_EBT_802_3_H
 
 #include <linux/types.h>
+#include <linux/if_ether.h>
 
 #define EBT_802_3_SAP 0x01
 #define EBT_802_3_TYPE 0x02
@@ -42,8 +43,8 @@ struct hdr_ni {
 };
 
 struct ebt_802_3_hdr {
-	__u8  daddr[6];
-	__u8  saddr[6];
+	__u8  daddr[ETH_ALEN];
+	__u8  saddr[ETH_ALEN];
 	__be16 len;
 	union {
 		struct hdr_ui ui;
diff --git a/include/uapi/linux/netfilter_ipv4/ipt_CLUSTERIP.h b/include/uapi/linux/netfilter_ipv4/ipt_CLUSTERIP.h
index c6a204c..eac0f65 100644
--- a/include/uapi/linux/netfilter_ipv4/ipt_CLUSTERIP.h
+++ b/include/uapi/linux/netfilter_ipv4/ipt_CLUSTERIP.h
@@ -2,6 +2,7 @@
 #define _IPT_CLUSTERIP_H_target
 
 #include <linux/types.h>
+#include <linux/if_ether.h>
 
 enum clusterip_hashmode {
     CLUSTERIP_HASHMODE_SIP = 0,
@@ -22,7 +23,7 @@ struct ipt_clusterip_tgt_info {
 	__u32 flags;
 
 	/* only relevant for new ones */
-	__u8 clustermac[6];
+	__u8 clustermac[ETH_ALEN];
 	__u16 num_total_nodes;
 	__u16 num_local_nodes;
 	__u16 local_nodes[CLUSTERIP_MAX_NODES];
diff --git a/include/uapi/linux/virtio_net.h b/include/uapi/linux/virtio_net.h
index 227d4ce..172a7f0 100644
--- a/include/uapi/linux/virtio_net.h
+++ b/include/uapi/linux/virtio_net.h
@@ -60,7 +60,7 @@
 
 struct virtio_net_config {
 	/* The config defining mac address (if VIRTIO_NET_F_MAC) */
-	__u8 mac[6];
+	__u8 mac[ETH_ALEN];
 	/* See VIRTIO_NET_F_STATUS and VIRTIO_NET_S_* above */
 	__u16 status;
 	/* Maximum number of each of transmit and receive queues;
diff --git a/include/uapi/linux/wimax/i2400m.h b/include/uapi/linux/wimax/i2400m.h
index 62d3561..fd198bc 100644
--- a/include/uapi/linux/wimax/i2400m.h
+++ b/include/uapi/linux/wimax/i2400m.h
@@ -122,7 +122,7 @@
 #define __LINUX__WIMAX__I2400M_H__
 
 #include <linux/types.h>
-
+#include <linux/if_ether.h>
 
 /*
  * Host Device Interface (HDI) common to all busses
@@ -487,7 +487,7 @@ struct i2400m_tlv_l4_message_versions {
 struct i2400m_tlv_detailed_device_info {
 	struct i2400m_tlv_hdr hdr;
 	__u8 reserved1[400];
-	__u8 mac_address[6];
+	__u8 mac_address[ETH_ALEN];
 	__u8 reserved2[2];
 } __attribute__((packed));
 
-- 
1.8.1.2.459.gbcd45b4.dirty
