From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: [PATCH] Host AP for wireless-2.6
Date: Mon, 31 May 2004 11:12:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040531181249.GB7537@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Finally, here's the first attempt at submitting Host AP code for
wireless-2.6 tree. In addition, this could be considered for merging
into linus-2.5 tree, so review and comments are very much welcome. Host
AP code has lived in an external CVS repository for three years and is
widely used.

The included patch has minimal changes to the current tree (against
2.6.6, but should apply to different versions with some differences in
line numbers) for including a new directory drivers/net/wireless/hostap.
The contents of that new directory is a bit large for a patch file and
since all the files are new, I made it available as a compressed tarball
at http://hostap.epitest.fi/hostap-linux.tgz. This should be untarred in
the root of the kernel tree (i.e., the file paths in the tarball start
with drivers/net/wirelss/hostap/...).

I removed most of the backwards (for Linux 2.4, pcmcia-cs modules,
different wireless extensions versions) compatibility code. In addition,
I replaced integrated implementations of ARC4, Michael MIC, and AES with
crypto API. AES-CCM mode is still implemented in hostap_crypt_ccmp.c,
but it could be moved at some point to crypto API as a new encryption
mode.


diff -ur linux-2.6.6.orig/MAINTAINERS linux-2.6.6/MAINTAINERS
--- linux-2.6.6.orig/MAINTAINERS	2004-05-31 09:42:05.621596168 -0700
+++ linux-2.6.6/MAINTAINERS	2004-05-31 09:43:38.113535256 -0700
@@ -911,6 +911,13 @@
 L:	iss_storagedev@hp.com
 S:	Supported
  
+HOST AP DRIVER
+P:	Jouni Malinen
+M:	jkmaline@cc.hut.fi
+L:	hostap@shmoo.com
+W:	http://hostap.epitest.fi/
+S:	Maintained
+
 HP100:	Driver for HP 10/100 Mbit/s Voice Grade Network Adapter Series
 P:	Jaroslav Kysela
 M:	perex@suse.cz
diff -ur linux-2.6.6.orig/drivers/net/wireless/Kconfig linux-2.6.6/drivers/net/wireless/Kconfig
--- linux-2.6.6.orig/drivers/net/wireless/Kconfig	2004-05-31 09:41:55.782092000 -0700
+++ linux-2.6.6/drivers/net/wireless/Kconfig	2004-05-29 20:18:11.000000000 -0700
@@ -355,6 +355,8 @@
 	  say M here and read <file:Documentation/modules.txt>.  The module
 	  will be called prism54.ko.
 
+source "drivers/net/wireless/hostap/Kconfig"
+
 # yes, this works even when no drivers are selected
 config NET_WIRELESS
 	bool
diff -ur linux-2.6.6.orig/drivers/net/wireless/Makefile linux-2.6.6/drivers/net/wireless/Makefile
--- linux-2.6.6.orig/drivers/net/wireless/Makefile	2004-05-31 09:41:55.781092152 -0700
+++ linux-2.6.6/drivers/net/wireless/Makefile	2004-05-29 20:18:29.000000000 -0700
@@ -28,6 +28,8 @@
 
 obj-$(CONFIG_PRISM54)		+= prism54/
 
+obj-$(CONFIG_HOSTAP)		+= hostap/
+
 # 16-bit wireless PCMCIA client drivers
 obj-$(CONFIG_PCMCIA_RAYCS)	+= ray_cs.o
 obj-$(CONFIG_PCMCIA_WL3501)	+= wl3501_cs.o



-- 
Jouni Malinen                                            PGP id EFC895FA
