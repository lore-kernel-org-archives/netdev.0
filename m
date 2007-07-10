From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] fore200e_param_bs_queue() must be __devinit
Date: Tue, 10 Jul 2007 14:44:38 +0200
Message-ID: <20070710124438.GT3492@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:56640 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754288AbXGJMoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2007 08:44:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes the following section mismatch:

<--  snip  -->

...
  MODPOST vmlinux
WARNING: drivers/built-in.o(.text+0x6203bb): Section mismatch: reference to .init.text:fore200e_param_bs_queue (between 'fore200e_initialize' and 'fore200e_monitor_putc')
...

<--  snip  -->

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---
--- linux-2.6.22-rc6-mm1/drivers/atm/fore200e.c.old	2007-07-10 04:11:43.000000000 +0200
+++ linux-2.6.22-rc6-mm1/drivers/atm/fore200e.c	2007-07-10 04:12:48.000000000 +0200
@@ -2435,7 +2435,7 @@
 }
 
 
-static void __init
+static void __devinit
 fore200e_param_bs_queue(struct fore200e* fore200e,
 			enum buffer_scheme scheme, enum buffer_magn magn,
 			int queue_length, int pool_size, int supply_blksize)

