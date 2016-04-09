From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 1/6] net: Make vxlan/geneve default udp ports public
Date: Sat, 9 Apr 2016 09:17:00 -0400
Message-ID: <1460207825-3622-2-git-send-email-manish.chopra@qlogic.com>
References: <1460207825-3622-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:24434 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753010AbcDIN6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 09:58:34 -0400
In-Reply-To: <1460207825-3622-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch defines default UDP ports for vxlan and geneve
in their respective header files to be accessed by the driver.

Rationale behind this change is that with some OVS configuration
UDP ports doesn't get notified to the driver using
.ndo_[add|del]_vxlan_port. So for the driver to work with
these specific ports in that environment we need to have them configured
on adapter by default for the required hardware offload support.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/geneve.c | 4 +---
 drivers/net/vxlan.c  | 2 +-
 include/net/geneve.h | 1 +
 include/net/vxlan.h  | 2 ++
 4 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index a9fbf17..4f8a1bb 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -23,8 +23,6 @@
 
 #define GENEVE_NETDEV_VER	"0.6"
 
-#define GENEVE_UDP_PORT		6081
-
 #define GENEVE_N_VID		(1u << 24)
 #define GENEVE_VID_MASK		(GENEVE_N_VID - 1)
 
@@ -1361,7 +1359,7 @@ static int geneve_configure(struct net *net, struct net_device *dev,
 static int geneve_newlink(struct net *net, struct net_device *dev,
 			  struct nlattr *tb[], struct nlattr *data[])
 {
-	__be16 dst_port = htons(GENEVE_UDP_PORT);
+	__be16 dst_port = htons(GENEVE_DEF_UDP_PORT);
 	__u8 ttl = 0, tos = 0;
 	bool metadata = false;
 	union geneve_addr remote = geneve_remote_unspec;
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 9f36340..1d7af21 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -62,7 +62,7 @@
  * The IANA assigned port is 4789, but the Linux default is 8472
  * for compatibility with early adopters.
  */
-static unsigned short vxlan_port __read_mostly = 8472;
+static unsigned short vxlan_port __read_mostly = VXLAN_DEF_UDP_PORT;
 module_param_named(udp_port, vxlan_port, ushort, 0444);
 MODULE_PARM_DESC(udp_port, "Destination UDP port");
 
diff --git a/include/net/geneve.h b/include/net/geneve.h
index e6c23dc..3c3ee4a 100644
--- a/include/net/geneve.h
+++ b/include/net/geneve.h
@@ -5,6 +5,7 @@
 #include <net/udp_tunnel.h>
 #endif
 
+#define GENEVE_DEF_UDP_PORT 6081
 
 /* Geneve Header:
  *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 2f168f0..5d1b27f 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -9,6 +9,8 @@
 #include <linux/udp.h>
 #include <net/dst_metadata.h>
 
+#define VXLAN_DEF_UDP_PORT 8472
+
 /* VXLAN protocol (RFC 7348) header:
  * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  * |R|R|R|R|I|R|R|R|               Reserved                        |
-- 
2.7.2
