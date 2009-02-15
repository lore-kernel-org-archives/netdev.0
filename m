From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] ATM: misplaced parentheses?
Date: Sun, 15 Feb 2009 17:07:12 +0100
Message-ID: <49983DB0.6040008@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
To: chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:44697 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752654AbZBOQHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2009 11:07:14 -0500
Received: by nf-out-0910.google.com with SMTP id d21so174495nfb.21
        for <netdev@vger.kernel.org>; Sun, 15 Feb 2009 08:07:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think below is what was intended? otherwise we could as well have written:

tmp = (lanai->conf1 & ~CONFIG1_PROMDATA) ||
	(data & i) ? CONFIG1_PROMDATA : 0;

Does this fix the parsing of the EEPROM?

please review.
-------------------------->8------------------8<---------------------------
Fix misplaced parentheses

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/atm/lanai.c b/drivers/atm/lanai.c
index 144a49f..317fb5a 100644
--- a/drivers/atm/lanai.c
+++ b/drivers/atm/lanai.c
@@ -901,7 +901,7 @@ static int __devinit eeprom_read(struct lanai_dev *lanai)
 		clock_l(); udelay(5);
 		for (i = 128; i != 0; i >>= 1) {   /* write command out */
 			tmp = (lanai->conf1 & ~CONFIG1_PROMDATA) |
-			    (data & i) ? CONFIG1_PROMDATA : 0;
+			    (data & i ? CONFIG1_PROMDATA : 0);
 			if (lanai->conf1 != tmp) {
 				set_config1(tmp);
 				udelay(5);	/* Let new data settle */
