From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/3] etherdevice.h: Add ether_addr_equal_64bits
Date: Wed,  9 May 2012 20:04:03 -0700
Message-ID: <7535e70ceb63f7da56f73cb37d4b269cd7798583.1336618708.git.joe@perches.com>
References: <cover.1336618707.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1336618707.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add an optimized boolean function to check if
2 ethernet addresses are the same.

This is to avoid any confusion about compare_ether_addr_64bits
returning an unsigned, and not being able to use the
compare_ether_addr_64bits function for sorting ala memcmp.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/linux/etherdevice.h |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index f330114..afacf85 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -225,6 +225,26 @@ static inline unsigned compare_ether_addr_64bits(const u8 addr1[6+2],
 }
 
 /**
+ * ether_addr_equal_64bits - Compare two Ethernet addresses
+ * @addr1: Pointer to an array of 8 bytes
+ * @addr2: Pointer to an other array of 8 bytes
+ *
+ * Compare two ethernet addresses, returns true if equal, false otherwise.
+ *
+ * The function doesn't need any conditional branches and possibly uses
+ * word memory accesses on CPU allowing cheap unaligned memory reads.
+ * arrays = { byte1, byte2, byte3, byte4, byte6, byte7, pad1, pad2}
+ *
+ * Please note that alignment of addr1 & addr2 is only guaranted to be 16 bits.
+ */
+
+static inline bool ether_addr_equal_64bits(const u8 addr1[6+2],
+					   const u8 addr2[6+2])
+{
+	return !compare_ether_addr_64bits(addr1, addr2);
+}
+
+/**
  * is_etherdev_addr - Tell if given Ethernet address belongs to the device.
  * @dev: Pointer to a device structure
  * @addr: Pointer to a six-byte array containing the Ethernet address
-- 
1.7.8.111.gad25c.dirty
