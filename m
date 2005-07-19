From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] NETCONSOLE must depend on INET
Date: Tue, 19 Jul 2005 20:29:19 +0200
Message-ID: <20050719182919.GA5531@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261604AbVGSS32@vger.kernel.org>
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NETCONSOLE=y and INET=n results in the following compile error:

<--  snip  -->

...
  LD      .tmp_vmlinux1
net/built-in.o: In function `netpoll_parse_options':
: undefined reference to `in_aton'
net/built-in.o: In function `netpoll_parse_options':
: undefined reference to `in_aton'
make: *** [.tmp_vmlinux1] Error 1

<--  snip  -->


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.13-rc3/drivers/net/Kconfig.old	2005-07-19 19:29:25.000000000 +0200
+++ linux-2.6.13-rc3/drivers/net/Kconfig	2005-07-19 19:29:37.000000000 +0200
@@ -2544,7 +2544,7 @@
 
 config NETCONSOLE
 	tristate "Network console logging support (EXPERIMENTAL)"
-	depends on NETDEVICES && EXPERIMENTAL
+	depends on NETDEVICES && INET && EXPERIMENTAL
 	---help---
 	If you want to log kernel messages over the network, enable this.
 	See <file:Documentation/networking/netconsole.txt> for details.
