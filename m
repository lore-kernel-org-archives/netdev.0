From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] atm/lanai.c:sram_test_word() must be __devinit
Date: Tue, 10 Jul 2007 14:44:40 +0200
Message-ID: <20070710124440.GU3492@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:56641 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754692AbXGJMoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2007 08:44:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes the following section mismatch:

<--  snip  -->

...
  MODPOST vmlinux
WARNING: drivers/built-in.o(.text+0x62e4f7): Section mismatch: reference to .init.text:sram_test_word (between 'sram_test_pass' and 'sram_test_and_clear')
...

<--  snip  -->

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---
--- linux-2.6.22-rc6-mm1/drivers/atm/lanai.c.old	2007-07-10 04:14:40.000000000 +0200
+++ linux-2.6.22-rc6-mm1/drivers/atm/lanai.c	2007-07-10 04:15:20.000000000 +0200
@@ -553,8 +553,8 @@
 	writel(val, sram_addr(lanai, offset));
 }
 
-static int __init sram_test_word(
-	const struct lanai_dev *lanai, int offset, u32 pattern)
+static int __devinit sram_test_word(const struct lanai_dev *lanai,
+				    int offset, u32 pattern)
 {
 	u32 readback;
 	sram_write(lanai, pattern, offset);

