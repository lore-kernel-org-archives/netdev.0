From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] drivers/net/hamradio/dmascc.c: fix section mismatch
Date: Mon, 26 Jun 2006 12:31:46 +0200
Message-ID: <20060626103146.GP23314@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932445AbWFZKbt@vger.kernel.org>
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dev_setup() is using the __initdata variables ax25_broadcast and 
ax25_test.

Since the only caller of dev_setup() (setup_adapter()) is already 
__init, the solution is to make dev_setup() __init, too.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.17-mm2-full/drivers/net/hamradio/dmascc.c.old	2006-06-26 01:56:37.000000000 +0200
+++ linux-2.6.17-mm2-full/drivers/net/hamradio/dmascc.c	2006-06-26 01:56:55.000000000 +0200
@@ -436,7 +436,7 @@
 module_init(dmascc_init);
 module_exit(dmascc_exit);
 
-static void dev_setup(struct net_device *dev)
+static void __init dev_setup(struct net_device *dev)
 {
 	dev->type = ARPHRD_AX25;
 	dev->hard_header_len = AX25_MAX_HEADER_LEN;
