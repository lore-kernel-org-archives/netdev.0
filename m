From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] NET_PKTGEN must depend on INET
Date: Tue, 19 Jul 2005 15:55:25 +0200
Message-ID: <20050719135525.GG5031@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261975AbVGSN55@vger.kernel.org>
To: Robert Olsson <robert.olsson@its.uu.se>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NET_PKTGEN=y and INET=n results in the following compile error:

<--  snip  -->

...
  LD      .tmp_vmlinux1
net/built-in.o: In function `proc_if_write':
pktgen.c:(.text+0x18ca9): undefined reference to `in_aton'
pktgen.c:(.text+0x19c11): undefined reference to `in_aton'
pktgen.c:(.text+0x19ced): undefined reference to `in_aton'
pktgen.c:(.text+0x19e85): undefined reference to `in_aton'
net/built-in.o: In function `pktgen_setup_inject':
pktgen.c:(.text+0x1a93f): undefined reference to `in_aton'
net/built-in.o:pktgen.c:(.text+0x1a950): more undefined references to `in_aton' follow
make: *** [.tmp_vmlinux1] Error 1

<--  snip  -->


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.13-rc3-mm1-full/net/Kconfig.old	2005-07-19 02:16:32.000000000 +0200
+++ linux-2.6.13-rc3-mm1-full/net/Kconfig	2005-07-19 02:16:57.000000000 +0200
@@ -192,7 +192,7 @@
 
 config NET_PKTGEN
 	tristate "Packet Generator (USE WITH CAUTION)"
-	depends on PROC_FS
+	depends on INET && PROC_FS
 	---help---
 	  This module will inject preconfigured packets, at a configurable
 	  rate, out of a given interface.  It is used for network interface
