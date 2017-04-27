From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v1 1/3] bnx2x: Replace custom scnprintf()
Date: Thu, 27 Apr 2017 16:36:59 +0300
Message-ID: <20170427133701.72701-1-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andy.shevchenko@gmail.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>,
        Ariel Elior <ariel.elior@cavium.com>,
        everest-linux-l2@cavium.com,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:17339 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751294AbdD0NhF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 09:37:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andy.shevchenko@gmail.com>

Use scnprintf() when printing version instead of custom open coded variants.

Signed-off-by: Andy Shevchenko <andy.shevchenko@gmail.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c | 79 +++---------------------
 1 file changed, 9 insertions(+), 70 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index b209b7f6093e..2acc4f081818 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -6163,94 +6163,33 @@ static void bnx2x_link_int_ack(struct link_params *params,
 
 static int bnx2x_format_ver(u32 num, u8 *str, u16 *len)
 {
-	u8 *str_ptr = str;
-	u32 mask = 0xf0000000;
-	u8 shift = 8*4;
-	u8 digit;
-	u8 remove_leading_zeros = 1;
+	u16 ret;
+
 	if (*len < 10) {
 		/* Need more than 10chars for this format */
-		*str_ptr = '\0';
+		*str = '\0';
 		(*len)--;
 		return -EINVAL;
 	}
-	while (shift > 0) {
 
-		shift -= 4;
-		digit = ((num & mask) >> shift);
-		if (digit == 0 && remove_leading_zeros) {
-			*str_ptr = '0';
-		} else {
-			if (digit < 0xa)
-				*str_ptr = digit + '0';
-			else
-				*str_ptr = digit - 0xa + 'a';
-
-			remove_leading_zeros = 0;
-			str_ptr++;
-			(*len)--;
-		}
-		mask = mask >> 4;
-		if (shift == 4*4) {
-			if (remove_leading_zeros) {
-				str_ptr++;
-				(*len)--;
-			}
-			*str_ptr = '.';
-			str_ptr++;
-			(*len)--;
-			remove_leading_zeros = 1;
-		}
-	}
-	if (remove_leading_zeros)
-		(*len)--;
+	ret = scnprintf(str, *len, "%hx.%hx", num >> 16, num);
+	*len -= ret;
 	return 0;
 }
 
 static int bnx2x_3_seq_format_ver(u32 num, u8 *str, u16 *len)
 {
-	u8 *str_ptr = str;
-	u32 mask = 0x00f00000;
-	u8 shift = 8*3;
-	u8 digit;
-	u8 remove_leading_zeros = 1;
+	u16 ret;
 
 	if (*len < 10) {
 		/* Need more than 10chars for this format */
-		*str_ptr = '\0';
+		*str = '\0';
 		(*len)--;
 		return -EINVAL;
 	}
 
-	while (shift > 0) {
-		shift -= 4;
-		digit = ((num & mask) >> shift);
-		if (digit == 0 && remove_leading_zeros) {
-			*str_ptr = '0';
-		} else {
-			if (digit < 0xa)
-				*str_ptr = digit + '0';
-			else
-				*str_ptr = digit - 0xa + 'a';
-
-			remove_leading_zeros = 0;
-			str_ptr++;
-			(*len)--;
-		}
-		mask = mask >> 4;
-		if ((shift == 4*4) || (shift == 4*2)) {
-			if (remove_leading_zeros) {
-				str_ptr++;
-				(*len)--;
-			}
-			*str_ptr = '.';
-			str_ptr++;
-			(*len)--;
-			remove_leading_zeros = 1;
-		}
-	}
-	if (remove_leading_zeros)
-		(*len)--;
+	ret = scnprintf(str, *len, "%hhx.%hhx.%hhx", num >> 16, num >> 8, num);
+	*len -= ret;
 	return 0;
 }
 
-- 
2.11.0
