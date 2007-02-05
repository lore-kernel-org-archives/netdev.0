From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: [PATCH 2.6.20] misc-wireless: Use ARRAY_SIZE macro when appropriate
Date: Mon, 5 Feb 2007 18:58:29 +0200
Message-ID: <20070205165829.GI3896@Ahmed>
References: <20070205165429.GD3896@Ahmed>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:25383 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751798AbXBEQ6j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 11:58:39 -0500
Received: by ug-out-1314.google.com with SMTP id 44so1350318uga
        for <netdev@vger.kernel.org>; Mon, 05 Feb 2007 08:58:37 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20070205165429.GD3896@Ahmed>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

A patch to use ARRAY_SIZE macro already defined in kernel.h for some
miscellaneous wireless drivers with no specific maintaners.

Signed-off-by: Ahmed S. Darwish <darwish.07@gmail.com>
---
Patch is compile tested.

diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index 44a2270..4ad910b 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -1623,7 +1623,7 @@ static void emmh32_setseed(emmh32_context *context, u8 *pkey, int keylen,
 
 	crypto_cipher_setkey(tfm, pkey, 16);
 	counter = 0;
-	for (i = 0; i < (sizeof(context->coeff)/sizeof(context->coeff[0])); ) {
+	for (i = 0; i < ARRAY_SIZE(context->coeff); ) {
 		aes_counter[15] = (u8)(counter >> 0);
 		aes_counter[14] = (u8)(counter >> 8);
 		aes_counter[13] = (u8)(counter >> 16);
@@ -1632,7 +1632,7 @@ static void emmh32_setseed(emmh32_context *context, u8 *pkey, int keylen,
 		memcpy (plain, aes_counter, 16);
 		crypto_cipher_encrypt_one(tfm, plain, plain);
 		cipher = plain;
-		for (j=0; (j<16) && (i< (sizeof(context->coeff)/sizeof(context->coeff[0]))); ) {
+		for (j = 0; (j < 16) && (i < ARRAY_SIZE(context->coeff)); ) {
 			context->coeff[i++] = ntohl(*(u32 *)&cipher[j]);
 			j += 4;
 		}
diff --git a/drivers/net/wireless/prism54/oid_mgt.c b/drivers/net/wireless/prism54/oid_mgt.c
index e6cf9df..4278032 100644
--- a/drivers/net/wireless/prism54/oid_mgt.c
+++ b/drivers/net/wireless/prism54/oid_mgt.c
@@ -16,6 +16,8 @@
  *
  */
 
+#include <linux/kernel.h>
+
 #include "prismcompat.h"
 #include "islpci_dev.h"
 #include "islpci_mgt.h"
@@ -692,7 +694,7 @@ mgt_update_addr(islpci_private *priv)
 	return ret;
 }
 
-#define VEC_SIZE(a) (sizeof(a)/sizeof(a[0]))
+#define VEC_SIZE(a) ARRAY_SIZE(a)
 
 int
 mgt_commit(islpci_private *priv)



-- 
Ahmed S. Darwish
http://darwish-07.blogspot.com
