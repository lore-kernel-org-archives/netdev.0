From: Joe Perches <joe@perches.com>
Subject: [PATCH 01/13] etherdevice.h: Add ether_addr_equal
Date: Tue,  8 May 2012 21:56:45 -0700
Message-ID: <3796a3dd31e7a7d48430c257d75f67194f389ffc.1336538938.git.joe@perches.com>
References: <cover.1336538937.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1336538937.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a boolean function to check if 2 ethernet addresses
are the same.

This is to avoid any confusion about compare_ether_addr
returning an unsigned, and not being able to use the
compare_ether_addr function for sorting ala memcmp.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/linux/etherdevice.h |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index c47631f..f330114 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -171,6 +171,18 @@ static inline unsigned compare_ether_addr(const u8 *addr1, const u8 *addr2)
 	return ((a[0] ^ b[0]) | (a[1] ^ b[1]) | (a[2] ^ b[2])) != 0;
 }
 
+/**
+ * ether_addr_equal - Compare two Ethernet addresses
+ * @addr1: Pointer to a six-byte array containing the Ethernet address
+ * @addr2: Pointer other six-byte array containing the Ethernet address
+ *
+ * Compare two ethernet addresses, returns true if equal
+ */
+static inline bool ether_addr_equal(const u8 *addr1, const u8 *addr2)
+{
+	return !compare_ether_addr(addr1, addr2);
+}
+
 static inline unsigned long zap_last_2bytes(unsigned long value)
 {
 #ifdef __BIG_ENDIAN
-- 
1.7.8.111.gad25c.dirty
