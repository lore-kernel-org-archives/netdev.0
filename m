From: Samuel Ortiz <samuel@sortiz.org>
Subject: [PATCH net-next 3/5] irda: Test index before read in stir421x_patch_device()
Date: Mon, 11 Oct 2010 02:25:00 +0200
Message-ID: <3b06dbbeadb6488cd00999b61b080bb6f0218503.1286756123.git.sameo@linux.intel.com>
References: <cover.1286756123.git.sameo@linux.intel.com>
Cc: netdev@vger.kernel.org, Roel Kluin <roel.kluin@gmail.com>,
	Samuel Ortiz <samuel@sortiz.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:54297 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751042Ab0JKAZ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Oct 2010 20:25:58 -0400
In-Reply-To: <cover.1286756123.git.sameo@linux.intel.com>
In-Reply-To: <cover.1286756123.git.sameo@linux.intel.com>
References: <cover.1286756123.git.sameo@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>

Test whether index exceeds fw->size before reading the element

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
Signed-off-by: Samuel Ortiz <samuel@sortiz.org>
---
 drivers/net/irda/irda-usb.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/irda/irda-usb.c b/drivers/net/irda/irda-usb.c
index cce82f1..e4ea619 100644
--- a/drivers/net/irda/irda-usb.c
+++ b/drivers/net/irda/irda-usb.c
@@ -1124,11 +1124,11 @@ static int stir421x_patch_device(struct irda_usb_cb *self)
                  * The actual image starts after the "STMP" keyword
                  * so forward to the firmware header tag
                  */
-                for (i = 0; (fw->data[i] != STIR421X_PATCH_END_OF_HDR_TAG) &&
-			     (i < fw->size); i++) ;
+                for (i = 0; i < fw->size && fw->data[i] !=
+			     STIR421X_PATCH_END_OF_HDR_TAG; i++) ;
                 /* here we check for the out of buffer case */
-                if ((STIR421X_PATCH_END_OF_HDR_TAG == fw->data[i]) &&
-                    (i < STIR421X_PATCH_CODE_OFFSET)) {
+                if (i < STIR421X_PATCH_CODE_OFFSET && i < fw->size &&
+				STIR421X_PATCH_END_OF_HDR_TAG == fw->data[i]) {
                         if (!memcmp(fw->data + i + 1, STIR421X_PATCH_STMP_TAG,
                                     sizeof(STIR421X_PATCH_STMP_TAG) - 1)) {
 
-- 
1.7.1

