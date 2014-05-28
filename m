From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net v2 2/2] sfc: Restrict PIO to 64-bit architectures
Date: Wed, 28 May 2014 10:30:24 +0100
Message-ID: <5385ACB0.3060206@solarflare.com>
References: <5385AAF5.7090001@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17176 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752169AbaE1Ja1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 05:30:27 -0400
In-Reply-To: <5385AAF5.7090001@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Cooper <jcooper@solarflare.com>

Enable PIO for x86_64 architecture only.
Not tested on platforms other than x86_64.

Fixes:ee45fd92c739db5b7950163d91dfe5f016af6d24

orig-hg-hash: 53dc43553d9bbe1c5a64c49e580ca571ddc470ae
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
