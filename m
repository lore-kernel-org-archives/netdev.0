From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] etherdevice: introduce eth_broadcast_addr
Date: Tue, 10 Jul 2012 18:18:44 +0200
Message-ID: <1341937124.4475.27.camel@jlt3.sipsolutions.net>
References: <1341310587.5131.2.camel@jlt3.sipsolutions.net>
	 <20120708.235808.1602900783296556684.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:39063 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754030Ab2GJQSs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 12:18:48 -0400
In-Reply-To: <20120708.235808.1602900783296556684.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

A lot of code has either the memset or an inefficient copy
from a static array that contains the all-ones broadcast
address. Introduce eth_broadcast_addr() to fill an address
with all ones, making the code clearer and allowing us to
get rid of some constant arrays.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 include/linux/etherdevice.h |   11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index 3d406e0..98a27cc 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -138,6 +138,17 @@ static inline void random_ether_addr(u8 *addr)
 }
 
 /**
+ * eth_broadcast_addr - Assign broadcast address
+ * @addr: Pointer to a six-byte array containing the Ethernet address
+ *
+ * Assign the broadcast address to the given address array.
+ */
+static inline void eth_broadcast_addr(u8 *addr)
+{
+	memset(addr, 0xff, ETH_ALEN);
+}
+
+/**
  * eth_hw_addr_random - Generate software assigned random Ethernet and
  * set device flag
  * @dev: pointer to net_device structure
-- 
1.7.10.4
