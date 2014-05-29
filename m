From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net v3 2/2] sfc: Restrict PIO to 64-bit architectures
Date: Thu, 29 May 2014 11:20:50 +0100
Message-ID: <53870A02.6020500@solarflare.com>
References: <53870984.6020803@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:29256 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757210AbaE2KUy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 06:20:54 -0400
In-Reply-To: <53870984.6020803@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Cooper <jcooper@solarflare.com>

Enable PIO for x86_64 architecture only.
Not tested on platforms other than x86_64.

Fixes:ee45fd92c739
("sfc: Use TX PIO for sufficiently small packets")

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/io.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/sfc/io.h b/drivers/net/ethernet/sfc/io.h
index 4d3f119..adadcf0 100644
--- a/drivers/net/ethernet/sfc/io.h
+++ b/drivers/net/ethernet/sfc/io.h
@@ -66,10 +66,18 @@
 #define EFX_USE_QWORD_IO 1
 #endif
 
+/* PIO only works on 64-bit architectures */
+#if BITS_PER_LONG == 64
+/* not strictly necessary to restrict to x86 arch, but done for safety
+ * since unusual write combining behaviour can break PIO.
+ */
+#ifdef CONFIG_X86_64
 /* PIO is a win only if write-combining is possible */
 #ifdef ARCH_HAS_IOREMAP_WC
 #define EFX_USE_PIO 1
 #endif
+#endif
+#endif
 
 #ifdef EFX_USE_QWORD_IO
 static inline void _efx_writeq(struct efx_nic *efx, __le64 value,
