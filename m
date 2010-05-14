From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.35 10/25] wimax/i2400m: increase the maximum number of payloads per message to 60 [v1]
Date: Fri, 14 May 2010 14:45:09 -0700
Message-ID: <e6dd789af1823908ed3ccda26bf07faf5970bce1.1273708027.git.inaky.perez-gonzalez@intel.com>
References: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Cc: "Prasanna S. Panchamukhi" <prasannax.s.panchamukhi@intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:40976 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759993Ab0ENVtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 17:49:11 -0400
In-Reply-To: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prasanna S. Panchamukhi <prasannax.s.panchamukhi@intel.com>

According to Intel Wimax i3200, i5x50 and i6x50 device specification
documents, the maximum number of payloads per message can be up to 60.

Increasing the number of payloads to 60 per message helps to
accommodate smaller payloads in a single transaction. This patch
increases the maximum number of payloads from 12 to 60 per message.

Signed-off-by: Prasanna S. Panchamukhi <prasannax.s.panchamukhi@intel.com>
---
 drivers/net/wimax/i2400m/tx.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wimax/i2400m/tx.c b/drivers/net/wimax/i2400m/tx.c
index 21909e5..b10c3b7 100644
--- a/drivers/net/wimax/i2400m/tx.c
+++ b/drivers/net/wimax/i2400m/tx.c
@@ -272,7 +272,13 @@ enum {
 	 * at the end there are less, we pad up to the nearest
 	 * multiple of 16.
 	 */
-	I2400M_TX_PLD_MAX = 12,
+	/*
+	 * According to Intel Wimax i3200, i5x50 and i6x50 specification
+	 * documents, the maximum number of payloads per message can be
+	 * up to 60. Increasing the number of payloads to 60 per message
+	 * helps to accommodate smaller payloads in a single transaction.
+	 */
+	I2400M_TX_PLD_MAX = 60,
 	I2400M_TX_PLD_SIZE = sizeof(struct i2400m_msg_hdr)
 	+ I2400M_TX_PLD_MAX * sizeof(struct i2400m_pld),
 	I2400M_TX_SKIP = 0x80000000,
-- 
1.6.6.1

