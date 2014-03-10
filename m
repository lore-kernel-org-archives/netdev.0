From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 1/5] vxlan: Make VXLAN default UDP port number available for others
Date: Mon, 10 Mar 2014 12:48:58 -0400
Message-ID: <1394470142-13992-2-git-send-email-shahed.shaikh@qlogic.com>
References: <1394470142-13992-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:55696 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754234AbaCJRZG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 13:25:06 -0400
In-Reply-To: <1394470142-13992-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Although vxlan module has capability to notify udp ports to
other interested net devices using .ndo_add_rx_vxlan_port and
.ndo_del_rx_vxlan_port, there could be some devices which support
vxlan offload but not interested in updating udp port numbers.
This may be because some hardware do not support programming multiple
udp ports and their drivers may decide to program only default udp port
into adapter. So that adapter, at least, can do offloading for
default udp port number.

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/vxlan.c | 6 +-----
 include/net/vxlan.h | 6 ++++++
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index eb59b14..ace758f 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -71,11 +71,7 @@ struct vxlanhdr {
 	__be32 vx_vni;
 };
 
-/* UDP port for VXLAN traffic.
- * The IANA assigned port is 4789, but the Linux default is 8472
- * for compatibility with early adopters.
- */
-static unsigned short vxlan_port __read_mostly = 8472;
+static unsigned short vxlan_port __read_mostly = VXLAN_DEFAULT_PORT;
 module_param_named(udp_port, vxlan_port, ushort, 0444);
 MODULE_PARM_DESC(udp_port, "Destination UDP port");
 
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 5deef1a..4c16629 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -8,6 +8,12 @@
 #define VNI_HASH_BITS	10
 #define VNI_HASH_SIZE	(1<<VNI_HASH_BITS)
 
+/* UDP port for VXLAN traffic.
+ * The IANA assigned port is 4789, but the Linux default is 8472
+ * for compatibility with early adopters.
+ */
+#define VXLAN_DEFAULT_PORT 8472
+
 struct vxlan_sock;
 typedef void (vxlan_rcv_t)(struct vxlan_sock *vh, struct sk_buff *skb, __be32 key);
 
-- 
1.8.3.1
