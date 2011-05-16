From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH V5 2/6 net-next] netdevice.h: Add zero-copy flag in
 netdevice
Date: Mon, 16 May 2011 12:28:48 -0700
Message-ID: <1305574128.3456.23.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, mst@redhat.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Shirley Ma <xma@us.ibm.com>
---

 include/linux/netdevice.h |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a134d80..2646251 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1066,6 +1066,16 @@ struct net_device {
 #define NETIF_F_NOCACHE_COPY	(1 << 30) /* Use no-cache copyfromuser */
 #define NETIF_F_LOOPBACK	(1 << 31) /* Enable loopback */
 
+/*
+ * Bit 31 is for device to map userspace buffers -- zerocopy
+ * Device can set this flag when it supports HIGHDMA.
+ * Device can't recycle this kind of skb buffers.
+ * There are 256 bytes copied, the rest of buffers are mapped.
+ * The userspace callback should only be called when last reference to this skb
+ * is gone.
+ */
+#define NETIF_F_ZEROCOPY	(1 << 31)
+
 	/* Segmentation offload features */
 #define NETIF_F_GSO_SHIFT	16
 #define NETIF_F_GSO_MASK	0x00ff0000
