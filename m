From: Adam Borowski <kilobyte@angband.pl>
Subject: [PATCH] wanxl: use m68k-linux-gnu-as if available
Date: Fri, 13 Oct 2017 01:24:34 +0200
Message-ID: <20171012232434.15890-1-kilobyte@angband.pl>
Cc: Adam Borowski <kilobyte@angband.pl>
To: Krzysztof Halasa <khc@pm.waw.pl>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tartarus.angband.pl ([89.206.35.136]:36731 "EHLO
        tartarus.angband.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752804AbdJLXYm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 19:24:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes build failure on Debian based systems: GNU as is the only m68k
assembler available in the archive (package binutils-m68k-linux-gnu).

Signed-off-by: Adam Borowski <kilobyte@angband.pl>
---
I have no relevant hardware, thus I can't check whether the built firmware
actually works.  Some opcodes are translated differently, thus it might be
possible that some extra options are required.  Or possibly the assembler
has long since changed -- the prebuilt copy hasn't been updated anywhere
within recorded history.

In any case, I admit I don't really care about this driver -- it's merely
a notorious cause of randconfig failures.

 drivers/net/wan/Makefile | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/wan/Makefile b/drivers/net/wan/Makefile
index 73c2326603fc..fa17b18765b0 100644
--- a/drivers/net/wan/Makefile
+++ b/drivers/net/wan/Makefile
@@ -38,14 +38,20 @@ obj-$(CONFIG_SLIC_DS26522)	+= slic_ds26522.o
 clean-files := wanxlfw.inc
 $(obj)/wanxl.o:	$(obj)/wanxlfw.inc
 
+HAVE_GNU_M68K_AS := $(shell command -v m68k-linux-gnu-as 2> /dev/null)
 ifeq ($(CONFIG_WANXL_BUILD_FIRMWARE),y)
 ifeq ($(ARCH),m68k)
   AS68K = $(AS)
   LD68K = $(LD)
+else
+ifdef HAVE_GNU_M68K_AS
+  AS68K = m68k-linux-gnu-as
+  LD68K = m68k-linux-gnu-ld
 else
   AS68K = as68k
   LD68K = ld68k
 endif
+endif
 
 quiet_cmd_build_wanxlfw = BLD FW  $@
       cmd_build_wanxlfw = \
-- 
2.15.0.rc0
