From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 1/8] etherdevice: Rename random_ether_addr to eth_random_addr
Date: Thu, 12 Jul 2012 22:33:05 -0700
Message-ID: <de8d9911e9aca6ddd34efcb89c87fc6e33a9cd43.1342157022.git.joe@perches.com>
References: <1341968967.13724.23.camel@joe2Laptop>
Cc: Johannes Berg <johannes@sipsolutions.net>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1341968967.13724.23.camel@joe2Laptop>
In-Reply-To: <cover.1342157022.git.joe@perches.com>
References: <cover.1342157022.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add some API symmetry to eth_broadcast_addr and
add a #define to the old name for backward compatibility.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/linux/etherdevice.h |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index 98a27cc..d426336 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -124,19 +124,21 @@ static inline bool is_valid_ether_addr(const u8 *addr)
 }
 
 /**
- * random_ether_addr - Generate software assigned random Ethernet address
+ * eth_random_addr - Generate software assigned random Ethernet address
  * @addr: Pointer to a six-byte array containing the Ethernet address
  *
  * Generate a random Ethernet address (MAC) that is not multicast
  * and has the local assigned bit set.
  */
-static inline void random_ether_addr(u8 *addr)
+static inline void eth_random_addr(u8 *addr)
 {
-	get_random_bytes (addr, ETH_ALEN);
-	addr [0] &= 0xfe;	/* clear multicast bit */
-	addr [0] |= 0x02;	/* set local assignment bit (IEEE802) */
+	get_random_bytes(addr, ETH_ALEN);
+	addr[0] &= 0xfe;	/* clear multicast bit */
+	addr[0] |= 0x02;	/* set local assignment bit (IEEE802) */
 }
 
+#define random_ether_addr(addr) eth_random_addr(addr)
+
 /**
  * eth_broadcast_addr - Assign broadcast address
  * @addr: Pointer to a six-byte array containing the Ethernet address
@@ -160,7 +162,7 @@ static inline void eth_broadcast_addr(u8 *addr)
 static inline void eth_hw_addr_random(struct net_device *dev)
 {
 	dev->addr_assign_type |= NET_ADDR_RANDOM;
-	random_ether_addr(dev->dev_addr);
+	eth_random_addr(dev->dev_addr);
 }
 
 /**
-- 
1.7.8.111.gad25c.dirty
