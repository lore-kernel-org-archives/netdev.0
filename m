From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 01/14] etherdevice: Add eth_<foo>_addr CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS code
Date: Mon,  2 Mar 2015 19:54:46 -0800
Message-ID: <cccde434d9a32d1b9fb3d7604083c05a2ef1fe0e.1425354528.git.joe@perches.com>
References: <cover.1425354527.git.joe@perches.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0252.hostedemail.com ([216.40.44.252]:42661 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754192AbbCCDzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 22:55:52 -0500
In-Reply-To: <cover.1425354527.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the memset possibly more efficient with the appropriate
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS #ifdef

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/linux/etherdevice.h | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index 606563e..22ad94a 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -192,7 +192,12 @@ static inline void eth_random_addr(u8 *addr)
  */
 static inline void eth_broadcast_addr(u8 *addr)
 {
+#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)
+	*(u32 *)addr = 0xffffffff;
+	*(u16 *)(addr + 4) = 0xffff;
+#else
 	memset(addr, 0xff, ETH_ALEN);
+#endif
 }
 
 /**
@@ -203,7 +208,12 @@ static inline void eth_broadcast_addr(u8 *addr)
  */
 static inline void eth_zero_addr(u8 *addr)
 {
-	memset(addr, 0x00, ETH_ALEN);
+#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)
+	*(u32 *)addr = 0;
+	*(u16 *)(addr + 4) = 0;
+#else
+	memset(addr, 0, ETH_ALEN);
+#endif
 }
 
 /**
-- 
2.1.2
