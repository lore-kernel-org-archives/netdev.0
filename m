From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH 1/5] tc35815: Disable StripCRC
Date: Thu,  6 Aug 2009 23:41:45 +0900
Message-ID: <1249569709-21403-1-git-send-email-anemo@mba.ocn.ne.jp>
Cc: David Miller <davem@davemloft.net>,
	Ralf Roesch <ralf.roesch@rw-gmbh.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.28.14.163]:56600 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753662AbZHFPbT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Aug 2009 11:31:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems Rx_StripCRC cause trouble on recovering from the BLEx (Buffer
List Exhaust) or FDAEx (Free Descriptor Area Exhaust) condition.
Do not use it.

Also bump version number up.

Reported-by: Ralf Roesch <ralf.roesch@rw-gmbh.de>
Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
---
 drivers/net/tc35815.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index d737f6b..c903a68 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -23,9 +23,9 @@
  */
 
 #ifdef TC35815_NAPI
-#define DRV_VERSION	"1.37-NAPI"
+#define DRV_VERSION	"1.38-NAPI"
 #else
-#define DRV_VERSION	"1.37"
+#define DRV_VERSION	"1.38"
 #endif
 static const char *version = "tc35815.c:v" DRV_VERSION "\n";
 #define MODNAME			"tc35815"
@@ -341,8 +341,9 @@ struct BDesc {
 	Tx_EnExColl | Tx_EnLCarr | Tx_EnExDefer | Tx_EnUnder | \
 	Tx_En)	/* maybe  0x7b01 */
 #endif
+/* Do not use Rx_StripCRC -- it causes trouble on BLEx/FDAEx condition */
 #define RX_CTL_CMD	(Rx_EnGood | Rx_EnRxPar | Rx_EnLongErr | Rx_EnOver \
-	| Rx_EnCRCErr | Rx_EnAlign | Rx_StripCRC | Rx_RxEn) /* maybe 0x6f11 */
+	| Rx_EnCRCErr | Rx_EnAlign | Rx_RxEn) /* maybe 0x6f01 */
 #define INT_EN_CMD  (Int_NRAbtEn | \
 	Int_DmParErrEn | Int_DParDEn | Int_DParErrEn | \
 	Int_SSysErrEn  | Int_RMasAbtEn | Int_RTargAbtEn | \
-- 
1.5.6.5

