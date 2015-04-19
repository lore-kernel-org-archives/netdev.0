From: Mateusz Kulikowski <mateusz.kulikowski@gmail.com>
Subject: [PATCH] etherdevice: Add ether_addr_copy_unaligned
Date: Sun, 19 Apr 2015 23:39:37 +0200
Message-ID: <1429479577-3977-1-git-send-email-mateusz.kulikowski@gmail.com>
Cc: Mateusz Kulikowski <mateusz.kulikowski@gmail.com>, joe@perches.com,
	dan.carpenter@oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:35153 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750907AbbDSVkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Apr 2015 17:40:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some drivers require copying unaligned ethernet addresses.
Using memcpy() causes checkpatch warnings and may cause
regressions (someone will "fix" alignment of packed structure)

Signed-off-by: Mateusz Kulikowski <mateusz.kulikowski@gmail.com>
---
 include/linux/etherdevice.h | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index 606563e..681874f 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -244,6 +244,22 @@ static inline void ether_addr_copy(u8 *dst, const u8 *src)
 }
 
 /**
+ * ether_addr_copy_unaligned - Copy unaligned Ethernet address
+ * @dst: Pointer to a six-byte array Ethernet address destination
+ * @src: Pointer to a six-byte array Ethernet address source
+ *
+ * Please note: Use only when any Ethernet address may not be u16 aligned.
+ */
+static inline void ether_addr_copy_unaligned(u8 *dst, const u8 *src)
+{
+#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)
+	ether_addr_copy(dst, src);
+#else
+	memcpy(dst, src, ETH_ALEN);
+#endif
+}
+
+/**
  * eth_hw_addr_inherit - Copy dev_addr from another net_device
  * @dst: pointer to net_device to copy dev_addr to
  * @src: pointer to net_device to copy dev_addr from
-- 
1.8.4.1
