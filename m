From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] etherdevice: introduce broadcast_ether_addr
Date: Tue, 03 Jul 2012 12:16:27 +0200
Message-ID: <1341310587.5131.2.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:37522 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752604Ab2GCKQa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 06:16:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

A lot of code has either the memset or an
inefficient copy from a static array that
contains the all-ones broadcast address.
Introduce broadcast_ether_addr() to fill
an address with all ones, making the code
clearer and allowing us to get rid of the
various constant arrays.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 include/linux/etherdevice.h |   11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index 3d406e0..6da05bb 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -138,6 +138,17 @@ static inline void random_ether_addr(u8 *addr)
 }
 
 /**
+ * broadcast_ether_addr - Assign broadcast address
+ * @addr: Pointer to a six-byte array containing the Ethernet address
+ *
+ * Assign the broadcast address to the given address array.
+ */
+static inline void broadcast_ether_addr(u8 *addr)
+{
+	memset(addr, 0xff, ETH_ALEN);
+}
+
+/**
  * eth_hw_addr_random - Generate software assigned random Ethernet and
  * set device flag
  * @dev: pointer to net_device structure
-- 
1.7.10
