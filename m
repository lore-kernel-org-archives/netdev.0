From: Duan Jiong <djduanjiong@gmail.com>
Subject: [PATCH net-next] etherdevice: introduce help function eth_zero_addr()
Date: Sun, 09 Sep 2012 10:32:28 +0800
Message-ID: <504BFFBC.9070209@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:61683 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751670Ab2IICcf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Sep 2012 22:32:35 -0400
Received: by ieje11 with SMTP id e11so1135297iej.19
        for <netdev@vger.kernel.org>; Sat, 08 Sep 2012 19:32:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

a lot of code has either the memset or an inefficient copy
from a static array that contains the all-zeros Ethernet address.
Introduce help function eth_zero_addr() to fill an address with
all zeros, making the code clearer and allowing us to get rid of
some constant arrays.

Signed-off-by: Duan Jiong <djduanjiong@gmail.com>
---
 include/linux/etherdevice.h | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index d426336..b006ba0 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -151,6 +151,17 @@ static inline void eth_broadcast_addr(u8 *addr)
 }
 
 /**
+ * eth_zero_addr - Assign zero address
+ * @addr: Pointer to a six-byte array containing the Ethernet address
+ *
+ * Assign the zero address to the given address array.
+ */
+static inline void eth_zero_addr(u8 *addr)
+{
+	memset(addr, 0x00, ETH_ALEN);
+}
+
+/**
  * eth_hw_addr_random - Generate software assigned random Ethernet and
  * set device flag
  * @dev: pointer to net_device structure
-- 
1.7.11.4
