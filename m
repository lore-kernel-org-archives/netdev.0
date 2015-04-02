From: Ed Swierk <eswierk@skyportsystems.com>
Subject: [PATCH] Include SFP serial number and other SFF-8079 fields in EEPROM dump
Date: Wed,  1 Apr 2015 21:33:19 -0700
Message-ID: <1427949199-39650-1-git-send-email-eswierk@skyportsystems.com>
Cc: Ed Swierk <eswierk@skyportsystems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:34538 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751255AbbDBEda (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 00:33:30 -0400
Received: by pdbni2 with SMTP id ni2so76970581pdb.1
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2015 21:33:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ed Swierk <eswierk@skyportsystems.com>
---
 sfpid.c | 39 +++++++++++++++++++++++++++++++++++++++
 1 file changed, 39 insertions(+)

diff --git a/sfpid.c b/sfpid.c
index 4f88aa2..299d593 100644
--- a/sfpid.c
+++ b/sfpid.c
@@ -362,6 +362,40 @@ static void sff8079_show_ascii(const __u8 *id, unsigned int first_reg,
 	printf("\n");
 }
 
+static void sff8079_show_options(const __u8 *id)
+{
+	static const char *pfx =
+		"\tOption                                    :";
+
+	printf("\t%-41s : 0x%02x 0x%02x\n", "Option values", id[64], id[65]);
+	if (id[65] & (1 << 1))
+		printf("%s RX_LOS implemented\n", pfx);
+	if (id[65] & (1 << 2))
+		printf("%s RX_LOS implemented, inverted\n", pfx);
+	if (id[65] & (1 << 3))
+		printf("%s TX_FAULT implemented\n", pfx);
+	if (id[65] & (1 << 4))
+		printf("%s TX_DISABLE implemented\n", pfx);
+	if (id[65] & (1 << 5))
+		printf("%s RATE_SELECT implemented\n", pfx);
+	if (id[65] & (1 << 6))
+		printf("%s Tunable transmitter technology\n", pfx);
+	if (id[65] & (1 << 7))
+		printf("%s Receiver decision threshold implemented\n", pfx);
+	if (id[64] & (1 << 0))
+		printf("%s Linear receiver output implemented\n", pfx);
+	if (id[64] & (1 << 1))
+		printf("%s Power level 2 requirement\n", pfx);
+	if (id[64] & (1 << 2))
+		printf("%s Cooled transceiver implemented\n", pfx);
+	if (id[64] & (1 << 3))
+		printf("%s Retimer or CDR implemented\n", pfx);
+	if (id[64] & (1 << 4))
+		printf("%s Paging implemented\n", pfx);
+	if (id[64] & (1 << 5))
+		printf("%s Power level 3 requirement\n", pfx);
+}
+
 void sff8079_show_all(const __u8 *id)
 {
 	sff8079_show_identifier(id);
@@ -385,5 +419,10 @@ void sff8079_show_all(const __u8 *id)
 		sff8079_show_oui(id);
 		sff8079_show_ascii(id, 40, 55, "Vendor PN");
 		sff8079_show_ascii(id, 56, 59, "Vendor rev");
+		sff8079_show_options(id);
+		sff8079_show_value_with_unit(id, 66, "BR margin, max", 1, "%");
+		sff8079_show_value_with_unit(id, 67, "BR margin, min", 1, "%");
+		sff8079_show_ascii(id, 68, 83, "Vendor SN");
+		sff8079_show_ascii(id, 84, 91, "Date code");
 	}
 }
-- 
1.9.1
