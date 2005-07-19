From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] VIA_VELOCITY must depend on INET
Date: Tue, 19 Jul 2005 15:55:23 +0200
Message-ID: <20050719135523.GF5031@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261383AbVGSN55@vger.kernel.org>
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

VIA_VELOCITY=y and INET=n results in the following compile error:

<--  snip  -->

...
  LD      .tmp_vmlinux1
drivers/built-in.o: In function `velocity_register_notifier':
via-velocity.c:(.text+0x3462c6): undefined reference to `register_inetaddr_notifier'
drivers/built-in.o: In function `velocity_unregister_notifier':
via-velocity.c:(.text+0x3462d6): undefined reference to `unregister_inetaddr_notifier'
make: *** [.tmp_vmlinux1] Error 1

<--  snip  -->


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.13-rc3-mm1-full/drivers/net/Kconfig.old	2005-07-19 02:11:45.000000000 +0200
+++ linux-2.6.13-rc3-mm1-full/drivers/net/Kconfig	2005-07-19 02:12:09.000000000 +0200
@@ -2016,7 +2016,7 @@
 
 config VIA_VELOCITY
 	tristate "VIA Velocity support"
-	depends on NET_PCI && PCI
+	depends on INET && NET_PCI && PCI
 	select CRC32
 	select CRC_CCITT
 	select MII
