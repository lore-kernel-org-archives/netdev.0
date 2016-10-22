From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v1 1/1] ISDN: eicon: replace custom hex_dump_to_buffer()
Date: Sat, 22 Oct 2016 20:37:05 +0300
Message-ID: <20161022173705.170520-1-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Armin Schindler <mac@melware.de>, netdev@vger.kernel.org,
        Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:57982 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S964798AbcJVRiJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 22 Oct 2016 13:38:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of custom approach re-use generic helper to convert bytes to hex
format.

The output is slightly changed, namely string starts from the first dword
value.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/isdn/hardware/eicon/message.c | 34 ++++------------------------------
 1 file changed, 4 insertions(+), 30 deletions(-)

diff --git a/drivers/isdn/hardware/eicon/message.c b/drivers/isdn/hardware/eicon/message.c
index 1a1d997..8684899 100644
--- a/drivers/isdn/hardware/eicon/message.c
+++ b/drivers/isdn/hardware/eicon/message.c
@@ -1147,45 +1147,19 @@ static byte test_c_ind_mask_bit(PLCI *plci, word b)
 
 static void dump_c_ind_mask(PLCI *plci)
 {
-	word i, j, k;
-	dword d;
-	char *p;
+	word i, j;
 	char buf[40];
 
 	for (i = 0; i < C_IND_MASK_DWORDS; i += 4)
 	{
-		p = buf + 36;
-		*p = '\0';
-		for (j = 0; j < 4; j++)
-		{
-			if (i + j < C_IND_MASK_DWORDS)
-			{
-				d = plci->c_ind_mask_table[i + j];
-				for (k = 0; k < 8; k++)
-				{
-					*(--p) = hex_asc_lo(d);
-					d >>= 4;
-				}
-			}
-			else if (i != 0)
-			{
-				for (k = 0; k < 8; k++)
-					*(--p) = ' ';
-			}
-			*(--p) = ' ';
-		}
-		dbug(1, dprintf("c_ind_mask =%s", (char *) p));
+		j = min_t(word, C_IND_MASK_DWORDS - i, 4) * 4;
+		hex_dump_to_buffer(plci->c_ind_mask_table[i], j, 16, 4, buf, sizeof(buf), false);
+		dbug(1, dprintf("c_ind_mask =%s", buf));
 	}
 }
 
-
-
-
-
 #define dump_plcis(a)
 
-
-
 /*------------------------------------------------------------------*/
 /* translation function for each message                            */
 /*------------------------------------------------------------------*/
-- 
2.9.3
