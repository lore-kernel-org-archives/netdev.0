From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] rrunner.c:rr_init() must be __devinit
Date: Tue, 10 Jul 2007 14:44:47 +0200
Message-ID: <20070710124447.GY3492@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:56652 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755964AbXGJMoO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2007 08:44:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes the following section mismatch:

<--  snip  -->

...
  MODPOST vmlinux
WARNING: drivers/built-in.o(.text+0x26e3f2): Section mismatch: reference to .init.text:rr_init (between 'rr_init_one' and 'rr_remove_one')
...

<--  snip  -->

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---
--- linux-2.6.22-rc6-mm1/drivers/net/rrunner.c.old	2007-07-10 04:34:33.000000000 +0200
+++ linux-2.6.22-rc6-mm1/drivers/net/rrunner.c	2007-07-10 04:34:42.000000000 +0200
@@ -516,7 +516,7 @@
 }
 
 
-static int __init rr_init(struct net_device *dev)
+static int __devinit rr_init(struct net_device *dev)
 {
 	struct rr_private *rrpriv;
 	struct rr_regs __iomem *regs;

