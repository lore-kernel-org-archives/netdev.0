From: yalin wang <yalin.wang2010@gmail.com>
Subject: [PATCH] isdn:remove reverse_bits(), use revbit8()
Date: Mon, 10 Aug 2015 17:15:57 +0800
Message-ID: <48EEE6BC-BAFE-4545-A860-237FBD1E279B@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: isdn@linux-pingi.de, netdev@vger.kernel.org,
	open list <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This change isdn driver, remove reverse_bits() function,
use the generic revbit8() function instead.

Signed-off-by: yalin wang <yalin.wang2010@gmail.com>
---
 drivers/isdn/mISDN/dsp_audio.c | 22 +++++-----------------
 1 file changed, 5 insertions(+), 17 deletions(-)

diff --git a/drivers/isdn/mISDN/dsp_audio.c b/drivers/isdn/mISDN/dsp_audio.c
index 0602295..bbef98e 100644
--- a/drivers/isdn/mISDN/dsp_audio.c
+++ b/drivers/isdn/mISDN/dsp_audio.c
@@ -13,6 +13,7 @@
 #include <linux/mISDNif.h>
 #include <linux/mISDNdsp.h>
 #include <linux/export.h>
+#include <linux/bitrev.h>
 #include "core.h"
 #include "dsp.h"
 
@@ -137,27 +138,14 @@ static unsigned char linear2ulaw(short sample)
 	return ulawbyte;
 }
 
-static int reverse_bits(int i)
-{
-	int z, j;
-	z = 0;
-
-	for (j = 0; j < 8; j++) {
-		if ((i & (1 << j)) != 0)
-			z |= 1 << (7 - j);
-	}
-	return z;
-}
-
-
 void dsp_audio_generate_law_tables(void)
 {
 	int i;
 	for (i = 0; i < 256; i++)
-		dsp_audio_alaw_to_s32[i] = alaw2linear(reverse_bits(i));
+		dsp_audio_alaw_to_s32[i] = alaw2linear(bitrev8((u8)i));
 
 	for (i = 0; i < 256; i++)
-		dsp_audio_ulaw_to_s32[i] = ulaw2linear(reverse_bits(i));
+		dsp_audio_ulaw_to_s32[i] = ulaw2linear(bitrev8((u8)i));
 
 	for (i = 0; i < 256; i++) {
 		dsp_audio_alaw_to_ulaw[i] =
@@ -176,13 +164,13 @@ dsp_audio_generate_s2law_table(void)
 		/* generating ulaw-table */
 		for (i = -32768; i < 32768; i++) {
 			dsp_audio_s16_to_law[i & 0xffff] =
-				reverse_bits(linear2ulaw(i));
+				bitrev8(linear2ulaw(i));
 		}
 	} else {
 		/* generating alaw-table */
 		for (i = -32768; i < 32768; i++) {
 			dsp_audio_s16_to_law[i & 0xffff] =
-				reverse_bits(linear2alaw(i));
+				bitrev8(linear2alaw(i));
 		}
 	}
 }
-- 
1.9.1
