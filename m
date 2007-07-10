From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] tokenring/3c359.c:xl_init() must be __devinit
Date: Tue, 10 Jul 2007 14:44:37 +0200
Message-ID: <20070710124437.GS3492@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:56639 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752927AbXGJMoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2007 08:44:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes the following section mismatch:

<--  snip  -->

...
  MODPOST vmlinux
WARNING: drivers/built-in.o(.text+0x361ef1): Section mismatch: reference to .init.text:xl_init (between 'xl_probe' and 'xl_hw_reset')
...

<--  snip  -->

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---
--- linux-2.6.22-rc6-mm1/drivers/net/tokenring/3c359.c.old	2007-07-10 04:07:19.000000000 +0200
+++ linux-2.6.22-rc6-mm1/drivers/net/tokenring/3c359.c	2007-07-10 04:08:01.000000000 +0200
@@ -363,7 +363,7 @@
 }
 
 
-static int __init xl_init(struct net_device *dev) 
+static int __devinit xl_init(struct net_device *dev) 
 {
     	struct xl_private *xl_priv = (struct xl_private *)dev->priv ;
 

