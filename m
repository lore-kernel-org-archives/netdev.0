From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v1 1/1] ISDN: eicon: replace custom hex_asc_lo() / hex_pack_byte()
Date: Fri,  6 May 2016 20:55:23 +0300
Message-ID: <1462557323-102678-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Armin Schindler <mac@melware.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:33829 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755370AbcEFRz2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 May 2016 13:55:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of custom approach re-use generic helpers to convert byte to hex
format.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/isdn/hardware/eicon/message.c | 21 +++++++--------------
 1 file changed, 7 insertions(+), 14 deletions(-)

diff --git a/drivers/isdn/hardware/eicon/message.c b/drivers/isdn/hardware/eicon/message.c
index d7c2866..1a1d997 100644
--- a/drivers/isdn/hardware/eicon/message.c
+++ b/drivers/isdn/hardware/eicon/message.c
@@ -1147,8 +1147,6 @@ static byte test_c_ind_mask_bit(PLCI *plci, word b)
 
 static void dump_c_ind_mask(PLCI *plci)
 {
-	static char hex_digit_table[0x10] =
-		{'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};
 	word i, j, k;
 	dword d;
 	char *p;
@@ -1165,7 +1163,7 @@ static void dump_c_ind_mask(PLCI *plci)
 				d = plci->c_ind_mask_table[i + j];
 				for (k = 0; k < 8; k++)
 				{
-					*(--p) = hex_digit_table[d & 0xf];
+					*(--p) = hex_asc_lo(d);
 					d >>= 4;
 				}
 			}
@@ -10507,7 +10505,6 @@ static void mixer_set_bchannel_id(PLCI *plci, byte *chi)
 
 static void mixer_calculate_coefs(DIVA_CAPI_ADAPTER *a)
 {
-	static char hex_digit_table[0x10] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};
 	word n, i, j;
 	char *p;
 	char hex_line[2 * MIXER_MAX_DUMP_CHANNELS + MIXER_MAX_DUMP_CHANNELS / 8 + 4];
@@ -10690,13 +10687,13 @@ static void mixer_calculate_coefs(DIVA_CAPI_ADAPTER *a)
 	n = li_total_channels;
 	if (n > MIXER_MAX_DUMP_CHANNELS)
 		n = MIXER_MAX_DUMP_CHANNELS;
+
 	p = hex_line;
 	for (j = 0; j < n; j++)
 	{
 		if ((j & 0x7) == 0)
 			*(p++) = ' ';
-		*(p++) = hex_digit_table[li_config_table[j].curchnl >> 4];
-		*(p++) = hex_digit_table[li_config_table[j].curchnl & 0xf];
+		p = hex_byte_pack(p, li_config_table[j].curchnl);
 	}
 	*p = '\0';
 	dbug(1, dprintf("[%06lx] CURRENT %s",
@@ -10706,8 +10703,7 @@ static void mixer_calculate_coefs(DIVA_CAPI_ADAPTER *a)
 	{
 		if ((j & 0x7) == 0)
 			*(p++) = ' ';
-		*(p++) = hex_digit_table[li_config_table[j].channel >> 4];
-		*(p++) = hex_digit_table[li_config_table[j].channel & 0xf];
+		p = hex_byte_pack(p, li_config_table[j].channel);
 	}
 	*p = '\0';
 	dbug(1, dprintf("[%06lx] CHANNEL %s",
@@ -10717,8 +10713,7 @@ static void mixer_calculate_coefs(DIVA_CAPI_ADAPTER *a)
 	{
 		if ((j & 0x7) == 0)
 			*(p++) = ' ';
-		*(p++) = hex_digit_table[li_config_table[j].chflags >> 4];
-		*(p++) = hex_digit_table[li_config_table[j].chflags & 0xf];
+		p = hex_byte_pack(p, li_config_table[j].chflags);
 	}
 	*p = '\0';
 	dbug(1, dprintf("[%06lx] CHFLAG  %s",
@@ -10730,8 +10725,7 @@ static void mixer_calculate_coefs(DIVA_CAPI_ADAPTER *a)
 		{
 			if ((j & 0x7) == 0)
 				*(p++) = ' ';
-			*(p++) = hex_digit_table[li_config_table[i].flag_table[j] >> 4];
-			*(p++) = hex_digit_table[li_config_table[i].flag_table[j] & 0xf];
+			p = hex_byte_pack(p, li_config_table[i].flag_table[j]);
 		}
 		*p = '\0';
 		dbug(1, dprintf("[%06lx] FLAG[%02x]%s",
@@ -10744,8 +10738,7 @@ static void mixer_calculate_coefs(DIVA_CAPI_ADAPTER *a)
 		{
 			if ((j & 0x7) == 0)
 				*(p++) = ' ';
-			*(p++) = hex_digit_table[li_config_table[i].coef_table[j] >> 4];
-			*(p++) = hex_digit_table[li_config_table[i].coef_table[j] & 0xf];
+			p = hex_byte_pack(p, li_config_table[i].coef_table[j]);
 		}
 		*p = '\0';
 		dbug(1, dprintf("[%06lx] COEF[%02x]%s",
-- 
2.8.1
