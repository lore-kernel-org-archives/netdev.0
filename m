From: Peter Wu <uwretep@gmail.com>
Subject: [PATCH v2 2/2] realtek: update devices to 3.11
Date: Tue, 23 Jul 2013 20:04:35 +0200
Message-ID: <1886928.4L2eVIU0Ed@al>
References: <3162188.mmLmSZRt9A@al>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:54851 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933842Ab3GWSG6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 14:06:58 -0400
Received: by mail-wi0-f179.google.com with SMTP id hj3so3365689wib.12
        for <netdev@vger.kernel.org>; Tue, 23 Jul 2013 11:06:56 -0700 (PDT)
In-Reply-To: <3162188.mmLmSZRt9A@al>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RTL8168_8111Bb/RTL8168_8111Bef is like RTL8111B/RTL8168B, RTL8100E and RTL8101E
(datasheet revision 1.0 from 26 January 2006). Assume that RTL8101e is also
similar (I may be very wrong at that though...).

Note that the scanning heuristics is the same as the r8169 module: newer devices
with stronger masks come before the others. Perhaps the older 8139 cards should
be appended to the list, after all r8169 chips.

Signed-off-by: Peter Wu <lekensteyn@gmail.com>
---
 realtek.c | 221 +++++++++++++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 177 insertions(+), 44 deletions(-)

diff --git a/realtek.c b/realtek.c
index 5a1fba7..a4bc680 100644
--- a/realtek.c
+++ b/realtek.c
@@ -19,17 +19,50 @@ enum chip_type {
 	RTL8101,
 
 	/* chips not handled by 8139too/8139cp module */
-	RTL8169,
-	RTL8169S,
-	RTL8110S,
-	RTL8169_8110SB,
-	RTL8169_8110SCd,
-	RTL8169_8110SCe,
-	RTL8168_8111Bb,
-	RTL8168_8111Bef,
-	RTL8101Ebc,
-	RTL8100E1,
-	RTL8100E2,
+	RTL_GIGA_MAC_VER_01,
+	RTL_GIGA_MAC_VER_02,
+	RTL_GIGA_MAC_VER_03,
+	RTL_GIGA_MAC_VER_04,
+	RTL_GIGA_MAC_VER_05,
+	RTL_GIGA_MAC_VER_06,
+	RTL_GIGA_MAC_VER_07,
+	RTL_GIGA_MAC_VER_08,
+	RTL_GIGA_MAC_VER_09,
+	RTL_GIGA_MAC_VER_10,
+	RTL_GIGA_MAC_VER_11,
+	RTL_GIGA_MAC_VER_12,
+	RTL_GIGA_MAC_VER_13,
+	RTL_GIGA_MAC_VER_14,
+	RTL_GIGA_MAC_VER_15,
+	RTL_GIGA_MAC_VER_16,
+	RTL_GIGA_MAC_VER_17,
+	RTL_GIGA_MAC_VER_18,
+	RTL_GIGA_MAC_VER_19,
+	RTL_GIGA_MAC_VER_20,
+	RTL_GIGA_MAC_VER_21,
+	RTL_GIGA_MAC_VER_22,
+	RTL_GIGA_MAC_VER_23,
+	RTL_GIGA_MAC_VER_24,
+	RTL_GIGA_MAC_VER_25,
+	RTL_GIGA_MAC_VER_26,
+	RTL_GIGA_MAC_VER_27,
+	RTL_GIGA_MAC_VER_28,
+	RTL_GIGA_MAC_VER_29,
+	RTL_GIGA_MAC_VER_30,
+	RTL_GIGA_MAC_VER_31,
+	RTL_GIGA_MAC_VER_32,
+	RTL_GIGA_MAC_VER_33,
+	RTL_GIGA_MAC_VER_34,
+	RTL_GIGA_MAC_VER_35,
+	RTL_GIGA_MAC_VER_36,
+	RTL_GIGA_MAC_VER_37,
+	RTL_GIGA_MAC_VER_38,
+	RTL_GIGA_MAC_VER_39,
+	RTL_GIGA_MAC_VER_40,
+	RTL_GIGA_MAC_VER_41,
+	RTL_GIGA_MAC_VER_42,
+	RTL_GIGA_MAC_VER_43,
+	RTL_GIGA_MAC_VER_44,
 };
 
 static const char * const chip_names[] = {
@@ -46,17 +79,50 @@ static const char * const chip_names[] = {
 	[RTL8101] = "RTL-8101",
 
 	/* chips not handled by 8139too/8139cp module */
-	[RTL8169] = "RTL-8169",
-	[RTL8169S] = "RTL-8169S",
-	[RTL8110S] = "RTL-8110S",
-	[RTL8169_8110SB] = "RTL-8169/8110SB",
-	[RTL8169_8110SCd] = "RTL-8169/8110SCd",
-	[RTL8169_8110SCe] = "RTL-8169/8110SCe",
-	[RTL8168_8111Bb] = "RTL-8168/8111Bb",
-	[RTL8168_8111Bef] = "RTL-8168/8111Bef",
-	[RTL8101Ebc] = "RTL-8101Ebc",
-	[RTL8100E1] = "RTL-8100E(1)",
-	[RTL8100E2] = "RTL-8100E(2)",
+	[RTL_GIGA_MAC_VER_01] = "RTL8169",
+	[RTL_GIGA_MAC_VER_02] = "RTL8169s",
+	[RTL_GIGA_MAC_VER_03] = "RTL8110s",
+	[RTL_GIGA_MAC_VER_04] = "RTL8169sb/8110sb",
+	[RTL_GIGA_MAC_VER_05] = "RTL8169sc/8110sc",
+	[RTL_GIGA_MAC_VER_06] = "RTL8169sc/8110sc",
+	[RTL_GIGA_MAC_VER_07] = "RTL8102e",
+	[RTL_GIGA_MAC_VER_08] = "RTL8102e",
+	[RTL_GIGA_MAC_VER_09] = "RTL8102e",
+	[RTL_GIGA_MAC_VER_10] = "RTL8101e",
+	[RTL_GIGA_MAC_VER_11] = "RTL8168b/8111b",
+	[RTL_GIGA_MAC_VER_12] = "RTL8168b/8111b",
+	[RTL_GIGA_MAC_VER_13] = "RTL8101e",
+	[RTL_GIGA_MAC_VER_14] = "RTL8100e",
+	[RTL_GIGA_MAC_VER_15] = "RTL8100e",
+	[RTL_GIGA_MAC_VER_16] = "RTL8101e",
+	[RTL_GIGA_MAC_VER_17] = "RTL8168b/8111b",
+	[RTL_GIGA_MAC_VER_18] = "RTL8168cp/8111cp",
+	[RTL_GIGA_MAC_VER_19] = "RTL8168c/8111c",
+	[RTL_GIGA_MAC_VER_20] = "RTL8168c/8111c",
+	[RTL_GIGA_MAC_VER_21] = "RTL8168c/8111c",
+	[RTL_GIGA_MAC_VER_22] = "RTL8168c/8111c",
+	[RTL_GIGA_MAC_VER_23] = "RTL8168cp/8111cp",
+	[RTL_GIGA_MAC_VER_24] = "RTL8168cp/8111cp",
+	[RTL_GIGA_MAC_VER_25] = "RTL8168d/8111d",
+	[RTL_GIGA_MAC_VER_26] = "RTL8168d/8111d",
+	[RTL_GIGA_MAC_VER_27] = "RTL8168dp/8111dp",
+	[RTL_GIGA_MAC_VER_28] = "RTL8168dp/8111dp",
+	[RTL_GIGA_MAC_VER_29] = "RTL8105e",
+	[RTL_GIGA_MAC_VER_30] = "RTL8105e",
+	[RTL_GIGA_MAC_VER_31] = "RTL8168dp/8111dp",
+	[RTL_GIGA_MAC_VER_32] = "RTL8168e/8111e",
+	[RTL_GIGA_MAC_VER_33] = "RTL8168e/8111e",
+	[RTL_GIGA_MAC_VER_34] = "RTL8168evl/8111evl",
+	[RTL_GIGA_MAC_VER_35] = "RTL8168f/8111f",
+	[RTL_GIGA_MAC_VER_36] = "RTL8168f/8111f",
+	[RTL_GIGA_MAC_VER_37] = "RTL8402",
+	[RTL_GIGA_MAC_VER_38] = "RTL8411",
+	[RTL_GIGA_MAC_VER_39] = "RTL8106e",
+	[RTL_GIGA_MAC_VER_40] = "RTL8168g/8111g",
+	[RTL_GIGA_MAC_VER_41] = "RTL8168g/8111g",
+	[RTL_GIGA_MAC_VER_42] = "RTL8168g/8111g",
+	[RTL_GIGA_MAC_VER_43] = "RTL8106e",
+	[RTL_GIGA_MAC_VER_44] = "RTL8411",
 };
 
 static struct chip_info {
@@ -77,17 +143,82 @@ static struct chip_info {
 	{ 0xfcc00000, 0x74c00000,	RTL8101 },
 
 	/* chips not handled by 8139too/8139cp module */
-	{ 0xfcc00000, 0x00000000,	RTL8169 },
-	{ 0xfcc00000, 0x00800000,	RTL8169S },
-	{ 0xfcc00000, 0x04000000,	RTL8110S },
-	{ 0xfcc00000, 0x10000000,	RTL8169_8110SB },
-	{ 0xfcc00000, 0x18000000,	RTL8169_8110SCd },
-	{ 0xfcc00000, 0x68000000,	RTL8169_8110SCe },
-	{ 0xfcc00000, 0x30000000,	RTL8168_8111Bb },
-	{ 0xfcc00000, 0x38000000,	RTL8168_8111Bef },
-	{ 0xfcc00000, 0x34000000,	RTL8101Ebc },
-	{ 0xfcc00000, 0x30800000,	RTL8100E1 },
-	{ 0xfcc00000, 0x38800000,	RTL8100E2 },
+	/* 8168G family. */
+	{ 0x7cf00000, 0x5c800000,	RTL_GIGA_MAC_VER_44 },
+	{ 0x7cf00000, 0x50900000,	RTL_GIGA_MAC_VER_42 },
+	{ 0x7cf00000, 0x4c100000,	RTL_GIGA_MAC_VER_41 },
+	{ 0x7cf00000, 0x4c000000,	RTL_GIGA_MAC_VER_40 },
+
+	/* 8168F family. */
+	{ 0x7c800000, 0x48800000,	RTL_GIGA_MAC_VER_38 },
+	{ 0x7cf00000, 0x48100000,	RTL_GIGA_MAC_VER_36 },
+	{ 0x7cf00000, 0x48000000,	RTL_GIGA_MAC_VER_35 },
+
+	/* 8168E family. */
+	{ 0x7c800000, 0x2c800000,	RTL_GIGA_MAC_VER_34 },
+	{ 0x7cf00000, 0x2c200000,	RTL_GIGA_MAC_VER_33 },
+	{ 0x7cf00000, 0x2c100000,	RTL_GIGA_MAC_VER_32 },
+	{ 0x7c800000, 0x2c000000,	RTL_GIGA_MAC_VER_33 },
+
+	/* 8168D family. */
+	{ 0x7cf00000, 0x28300000,	RTL_GIGA_MAC_VER_26 },
+	{ 0x7cf00000, 0x28100000,	RTL_GIGA_MAC_VER_25 },
+	{ 0x7c800000, 0x28000000,	RTL_GIGA_MAC_VER_26 },
+
+	/* 8168DP family. */
+	{ 0x7cf00000, 0x28800000,	RTL_GIGA_MAC_VER_27 },
+	{ 0x7cf00000, 0x28a00000,	RTL_GIGA_MAC_VER_28 },
+	{ 0x7cf00000, 0x28b00000,	RTL_GIGA_MAC_VER_31 },
+
+	/* 8168C family. */
+	{ 0x7cf00000, 0x3cb00000,	RTL_GIGA_MAC_VER_24 },
+	{ 0x7cf00000, 0x3c900000,	RTL_GIGA_MAC_VER_23 },
+	{ 0x7cf00000, 0x3c800000,	RTL_GIGA_MAC_VER_18 },
+	{ 0x7c800000, 0x3c800000,	RTL_GIGA_MAC_VER_24 },
+	{ 0x7cf00000, 0x3c000000,	RTL_GIGA_MAC_VER_19 },
+	{ 0x7cf00000, 0x3c200000,	RTL_GIGA_MAC_VER_20 },
+	{ 0x7cf00000, 0x3c300000,	RTL_GIGA_MAC_VER_21 },
+	{ 0x7cf00000, 0x3c400000,	RTL_GIGA_MAC_VER_22 },
+	{ 0x7c800000, 0x3c000000,	RTL_GIGA_MAC_VER_22 },
+
+	/* 8168B family. */
+	{ 0x7cf00000, 0x38000000,	RTL_GIGA_MAC_VER_12 },
+	{ 0x7cf00000, 0x38500000,	RTL_GIGA_MAC_VER_17 },
+	{ 0x7c800000, 0x38000000,	RTL_GIGA_MAC_VER_17 },
+	{ 0x7c800000, 0x30000000,	RTL_GIGA_MAC_VER_11 },
+
+	/* 8101 family. */
+	{ 0x7cf00000, 0x44900000,	RTL_GIGA_MAC_VER_39 },
+	{ 0x7c800000, 0x44800000,	RTL_GIGA_MAC_VER_39 },
+	{ 0x7c800000, 0x44000000,	RTL_GIGA_MAC_VER_37 },
+	{ 0x7cf00000, 0x40b00000,	RTL_GIGA_MAC_VER_30 },
+	{ 0x7cf00000, 0x40a00000,	RTL_GIGA_MAC_VER_30 },
+	{ 0x7cf00000, 0x40900000,	RTL_GIGA_MAC_VER_29 },
+	{ 0x7c800000, 0x40800000,	RTL_GIGA_MAC_VER_30 },
+	{ 0x7cf00000, 0x34a00000,	RTL_GIGA_MAC_VER_09 },
+	{ 0x7cf00000, 0x24a00000,	RTL_GIGA_MAC_VER_09 },
+	{ 0x7cf00000, 0x34900000,	RTL_GIGA_MAC_VER_08 },
+	{ 0x7cf00000, 0x24900000,	RTL_GIGA_MAC_VER_08 },
+	{ 0x7cf00000, 0x34800000,	RTL_GIGA_MAC_VER_07 },
+	{ 0x7cf00000, 0x24800000,	RTL_GIGA_MAC_VER_07 },
+	{ 0x7cf00000, 0x34000000,	RTL_GIGA_MAC_VER_13 },
+	{ 0x7cf00000, 0x34300000,	RTL_GIGA_MAC_VER_10 },
+	{ 0x7cf00000, 0x34200000,	RTL_GIGA_MAC_VER_16 },
+	{ 0x7c800000, 0x34800000,	RTL_GIGA_MAC_VER_09 },
+	{ 0x7c800000, 0x24800000,	RTL_GIGA_MAC_VER_09 },
+	{ 0x7c800000, 0x34000000,	RTL_GIGA_MAC_VER_16 },
+	/* FIXME: where did these entries come from ? -- FR */
+	{ 0xfc800000, 0x38800000,	RTL_GIGA_MAC_VER_15 },
+	{ 0xfc800000, 0x30800000,	RTL_GIGA_MAC_VER_14 },
+
+	/* 8110 family. */
+	{ 0xfc800000, 0x98000000,	RTL_GIGA_MAC_VER_06 },
+	{ 0xfc800000, 0x18000000,	RTL_GIGA_MAC_VER_05 },
+	{ 0xfc800000, 0x10000000,	RTL_GIGA_MAC_VER_04 },
+	{ 0xfc800000, 0x04000000,	RTL_GIGA_MAC_VER_03 },
+	{ 0xfc800000, 0x00800000,	RTL_GIGA_MAC_VER_02 },
+	{ 0xfc800000, 0x00000000,	RTL_GIGA_MAC_VER_01 },
+
 	{ }
 };
 
@@ -151,7 +282,7 @@ realtek_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 		data[0x08 >> 2],
 		data[0x0c >> 2]);
 
-	if (board_type == RTL8139Cp || board_type >= RTL8169) {
+	if (board_type == RTL8139Cp || board_type >= RTL_GIGA_MAC_VER_01) {
 	fprintf(stdout,
 		"0x10: Dump Tally Counter Command   0x%08x 0x%08x\n",
 		data[0x10 >> 2],
@@ -187,8 +318,9 @@ realtek_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 		data[0x2C >> 2]);
 	}
 
-	if (board_type != RTL8168_8111Bb && board_type != RTL8168_8111Bef) {
-	if (board_type >= RTL8169) {
+	if (board_type < RTL_GIGA_MAC_VER_11 ||
+		board_type > RTL_GIGA_MAC_VER_17) {
+	if (board_type >= RTL_GIGA_MAC_VER_01) {
 	fprintf(stdout,
 		"0x30: Flash memory read/write                 0x%08x\n",
 		data[0x30 >> 2]);
@@ -224,7 +356,7 @@ realtek_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 		v & (1 << 2) ? "on" : "off",
 		v & (1 << 4) ? ", RESET" : "");
 
-	if (board_type < RTL8169) {
+	if (board_type < RTL_GIGA_MAC_VER_01) {
 	fprintf(stdout,
 		"0x38: Current Address of Packet Read (C mode)     0x%04x\n"
 		"0x3A: Current Rx buffer address (C mode)          0x%04x\n",
@@ -259,7 +391,7 @@ realtek_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 		data8[0x51],
 		data8[0x52]);
 
-	if (board_type >= RTL8169) {
+	if (board_type >= RTL_GIGA_MAC_VER_01) {
 	fprintf(stdout,
 		"0x53: Config 2                                      0x%02x\n"
 		"0x54: Config 3                                      0x%02x\n"
@@ -298,12 +430,13 @@ realtek_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 		"0x5C: Multiple Interrupt Select                   0x%04x\n",
 		data[0x5c >> 2] & 0xffff);
 
-	if (board_type >= RTL8169) {
+	if (board_type >= RTL_GIGA_MAC_VER_01) {
 	fprintf(stdout,
 		"0x60: PHY access                              0x%08x\n",
 		data[0x60 >> 2]);
 
-	if (board_type != RTL8168_8111Bb && board_type != RTL8168_8111Bef) {
+	if (board_type < RTL_GIGA_MAC_VER_11 ||
+		board_type > RTL_GIGA_MAC_VER_17) {
 	fprintf(stdout,
 		"0x64: TBI control and status                  0x%08x\n",
 		data[0x64 >> 2]);
@@ -492,7 +625,7 @@ realtek_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 	}
 	}
 
-	if (board_type == RTL8139Cp || board_type >= RTL8169) {
+	if (board_type == RTL8139Cp || board_type >= RTL_GIGA_MAC_VER_01) {
 	v = data[0xE0 >> 2] & 0xffff;
 	fprintf(stdout,
 		"0xE0: C+ Command                                  0x%04x\n",
@@ -536,9 +669,9 @@ realtek_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 	fprintf(stdout,
 		"0xFC: External MII register                   0x%08x\n",
 		data[0xFC >> 2]);
-	} else if (board_type >= RTL8169 &&
-		   board_type != RTL8168_8111Bb &&
-		   board_type != RTL8168_8111Bef) {
+	} else if (board_type >= RTL_GIGA_MAC_VER_01 &&
+		(board_type < RTL_GIGA_MAC_VER_11 ||
+		board_type > RTL_GIGA_MAC_VER_17)) {
 	fprintf(stdout,
 		"0xF0: Func Event                              0x%08x\n"
 		"0xF4: Func Event Mask                         0x%08x\n"
-- 
1.8.3.3
