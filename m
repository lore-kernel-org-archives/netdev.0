From: Peter Wu <lekensteyn@gmail.com>
Subject: [PATCH v3 2/2] realtek: update devices to 3.11
Date: Thu, 25 Jul 2013 15:36:31 +0200
Message-ID: <1374759391-16916-3-git-send-email-lekensteyn@gmail.com>
References: <1374759391-16916-1-git-send-email-lekensteyn@gmail.com>
Cc: lekensteyn@gmail.com, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:64963 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755666Ab3GYNgr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 09:36:47 -0400
Received: by mail-wg0-f45.google.com with SMTP id x12so1694762wgg.24
        for <netdev@vger.kernel.org>; Thu, 25 Jul 2013 06:36:45 -0700 (PDT)
In-Reply-To: <1374759391-16916-1-git-send-email-lekensteyn@gmail.com>
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
index 6365a96..997b53c 100644
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
 	[RTL8101] =		"8101",
 
 	/* chips not handled by 8139too/8139cp module */
-	[RTL8169] =		"8169",
-	[RTL8169S] =		"8169S",
-	[RTL8110S] =		"8110S",
-	[RTL8169_8110SB] =	"8169/8110SB",
-	[RTL8169_8110SCd] =	"8169/8110SCd",
-	[RTL8169_8110SCe] =	"8169/8110SCe",
-	[RTL8168_8111Bb] =	"8168/8111Bb",
-	[RTL8168_8111Bef] =	"8168/8111Bef",
-	[RTL8101Ebc] =		"8101Ebc",
-	[RTL8100E1] =		"8100E(1)",
-	[RTL8100E2] =		"8100E(2)",
+	[RTL_GIGA_MAC_VER_01] = "8169",
+	[RTL_GIGA_MAC_VER_02] = "8169s",
+	[RTL_GIGA_MAC_VER_03] = "8110s",
+	[RTL_GIGA_MAC_VER_04] = "8169sb/8110sb",
+	[RTL_GIGA_MAC_VER_05] = "8169sc/8110sc",
+	[RTL_GIGA_MAC_VER_06] = "8169sc/8110sc",
+	[RTL_GIGA_MAC_VER_07] = "8102e",
+	[RTL_GIGA_MAC_VER_08] = "8102e",
+	[RTL_GIGA_MAC_VER_09] = "8102e",
+	[RTL_GIGA_MAC_VER_10] = "8101e",
+	[RTL_GIGA_MAC_VER_11] = "8168b/8111b",
+	[RTL_GIGA_MAC_VER_12] = "8168b/8111b",
+	[RTL_GIGA_MAC_VER_13] = "8101e",
+	[RTL_GIGA_MAC_VER_14] = "8100e",
+	[RTL_GIGA_MAC_VER_15] = "8100e",
+	[RTL_GIGA_MAC_VER_16] = "8101e",
+	[RTL_GIGA_MAC_VER_17] = "8168b/8111b",
+	[RTL_GIGA_MAC_VER_18] = "8168cp/8111cp",
+	[RTL_GIGA_MAC_VER_19] = "8168c/8111c",
+	[RTL_GIGA_MAC_VER_20] = "8168c/8111c",
+	[RTL_GIGA_MAC_VER_21] = "8168c/8111c",
+	[RTL_GIGA_MAC_VER_22] = "8168c/8111c",
+	[RTL_GIGA_MAC_VER_23] = "8168cp/8111cp",
+	[RTL_GIGA_MAC_VER_24] = "8168cp/8111cp",
+	[RTL_GIGA_MAC_VER_25] = "8168d/8111d",
+	[RTL_GIGA_MAC_VER_26] = "8168d/8111d",
+	[RTL_GIGA_MAC_VER_27] = "8168dp/8111dp",
+	[RTL_GIGA_MAC_VER_28] = "8168dp/8111dp",
+	[RTL_GIGA_MAC_VER_29] = "8105e",
+	[RTL_GIGA_MAC_VER_30] = "8105e",
+	[RTL_GIGA_MAC_VER_31] = "8168dp/8111dp",
+	[RTL_GIGA_MAC_VER_32] = "8168e/8111e",
+	[RTL_GIGA_MAC_VER_33] = "8168e/8111e",
+	[RTL_GIGA_MAC_VER_34] = "8168evl/8111evl",
+	[RTL_GIGA_MAC_VER_35] = "8168f/8111f",
+	[RTL_GIGA_MAC_VER_36] = "8168f/8111f",
+	[RTL_GIGA_MAC_VER_37] = "8402",
+	[RTL_GIGA_MAC_VER_38] = "8411",
+	[RTL_GIGA_MAC_VER_39] = "8106e",
+	[RTL_GIGA_MAC_VER_40] = "8168g/8111g",
+	[RTL_GIGA_MAC_VER_41] = "8168g/8111g",
+	[RTL_GIGA_MAC_VER_42] = "8168g/8111g",
+	[RTL_GIGA_MAC_VER_43] = "8106e",
+	[RTL_GIGA_MAC_VER_44] = "8411",
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
