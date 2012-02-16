From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 07/19] sfc: Correct MAC filter bitfield definitions
Date: Thu, 16 Feb 2012 00:47:11 +0000
Message-ID: <1329353231.2565.33.camel@bwh-desktop>
References: <1329352938.2565.26.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:27607 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754782Ab2BPAr5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 19:47:57 -0500
In-Reply-To: <1329352938.2565.26.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The RMFT_DEST_MAC and TMFT_SRC_MAC register fields were previously
documented as 44 bits wide, whereas a MAC address has 48 bits.
Thankfully the hardware uses the correct width and the driver has
used separate definitions that divide each of these into 32-bit and
16-bit fields.

Fix the initial definitions for these fields and rewrite the latter
definitions to use them.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/regs.h |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/sfc/regs.h b/drivers/net/ethernet/sfc/regs.h
index cc2c86b..ade4c4d 100644
--- a/drivers/net/ethernet/sfc/regs.h
+++ b/drivers/net/ethernet/sfc/regs.h
@@ -2446,8 +2446,8 @@
 #define	FRF_CZ_RMFT_RXQ_ID_WIDTH 12
 #define	FRF_CZ_RMFT_WILDCARD_MATCH_LBN 60
 #define	FRF_CZ_RMFT_WILDCARD_MATCH_WIDTH 1
-#define	FRF_CZ_RMFT_DEST_MAC_LBN 16
-#define	FRF_CZ_RMFT_DEST_MAC_WIDTH 44
+#define	FRF_CZ_RMFT_DEST_MAC_LBN 12
+#define	FRF_CZ_RMFT_DEST_MAC_WIDTH 48
 #define	FRF_CZ_RMFT_VLAN_ID_LBN 0
 #define	FRF_CZ_RMFT_VLAN_ID_WIDTH 12
 
@@ -2523,8 +2523,8 @@
 #define	FRF_CZ_TMFT_TXQ_ID_WIDTH 12
 #define	FRF_CZ_TMFT_WILDCARD_MATCH_LBN 60
 #define	FRF_CZ_TMFT_WILDCARD_MATCH_WIDTH 1
-#define	FRF_CZ_TMFT_SRC_MAC_LBN 16
-#define	FRF_CZ_TMFT_SRC_MAC_WIDTH 44
+#define	FRF_CZ_TMFT_SRC_MAC_LBN 12
+#define	FRF_CZ_TMFT_SRC_MAC_WIDTH 48
 #define	FRF_CZ_TMFT_VLAN_ID_LBN 0
 #define	FRF_CZ_TMFT_VLAN_ID_WIDTH 12
 
@@ -2895,17 +2895,17 @@
 
 /* RX_MAC_FILTER_TBL0 */
 /* RMFT_DEST_MAC is wider than 32 bits */
-#define FRF_CZ_RMFT_DEST_MAC_LO_LBN 12
+#define FRF_CZ_RMFT_DEST_MAC_LO_LBN FRF_CZ_RMFT_DEST_MAC_LBN
 #define FRF_CZ_RMFT_DEST_MAC_LO_WIDTH 32
-#define FRF_CZ_RMFT_DEST_MAC_HI_LBN 44
-#define FRF_CZ_RMFT_DEST_MAC_HI_WIDTH 16
+#define FRF_CZ_RMFT_DEST_MAC_HI_LBN (FRF_CZ_RMFT_DEST_MAC_LBN + 32)
+#define FRF_CZ_RMFT_DEST_MAC_HI_WIDTH (FRF_CZ_RMFT_DEST_MAC_WIDTH - 32)
 
 /* TX_MAC_FILTER_TBL0 */
 /* TMFT_SRC_MAC is wider than 32 bits */
-#define FRF_CZ_TMFT_SRC_MAC_LO_LBN 12
+#define FRF_CZ_TMFT_SRC_MAC_LO_LBN FRF_CZ_TMFT_SRC_MAC_LBN
 #define FRF_CZ_TMFT_SRC_MAC_LO_WIDTH 32
-#define FRF_CZ_TMFT_SRC_MAC_HI_LBN 44
-#define FRF_CZ_TMFT_SRC_MAC_HI_WIDTH 16
+#define FRF_CZ_TMFT_SRC_MAC_HI_LBN (FRF_CZ_TMFT_SRC_MAC_LBN + 32)
+#define FRF_CZ_TMFT_SRC_MAC_HI_WIDTH (FRF_CZ_TMFT_SRC_MAC_WIDTH - 32)
 
 /* TX_PACE_TBL */
 /* Values >20 are documented as reserved, but will result in a queue going
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
