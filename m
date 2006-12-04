From: akpm@osdl.org
Subject: [patch 1/1] atm: Add CPPFLAGS to byteorder.h check
Date: Mon, 04 Dec 2006 15:05:34 -0800
Message-ID: <200612042306.kB4N6haQ008125@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, bcollins@ubuntu.com,
	chas@cmf.nrl.navy.mil, jeff@garzik.org, sam@ravnborg.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:54070 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937451AbWLDXHZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 18:07:25 -0500
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Collins <bcollins@ubuntu.com>

O= builds produced errors in the shell command because of unfound headers.

Signed-off-by: Ben Collins <bcollins@ubuntu.com>
Cc: chas williams <chas@cmf.nrl.navy.mil>
Cc: Sam Ravnborg <sam@ravnborg.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/atm/Makefile |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/atm/Makefile~add-cppflags-to-byteorderh-check drivers/atm/Makefile
--- a/drivers/atm/Makefile~add-cppflags-to-byteorderh-check
+++ a/drivers/atm/Makefile
@@ -41,7 +41,7 @@ ifeq ($(CONFIG_ATM_FORE200E_PCA),y)
   # guess the target endianess to choose the right PCA-200E firmware image
   ifeq ($(CONFIG_ATM_FORE200E_PCA_DEFAULT_FW),y)
     byteorder.h			:= include$(if $(patsubst $(srctree),,$(objtree)),2)/asm/byteorder.h
-    CONFIG_ATM_FORE200E_PCA_FW	:= $(obj)/pca200e$(if $(shell $(CC) -E -dM $(byteorder.h) | grep ' __LITTLE_ENDIAN '),.bin,_ecd.bin2)
+    CONFIG_ATM_FORE200E_PCA_FW	:= $(obj)/pca200e$(if $(shell $(CC) $(CPPFLAGS) -E -dM $(byteorder.h) | grep ' __LITTLE_ENDIAN '),.bin,_ecd.bin2)
   endif
 endif
 
_
