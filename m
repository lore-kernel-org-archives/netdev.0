From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 2/4] isdn/capi: Make verbose reporting depend on capidrv
Date: Sun, 18 May 2014 23:26:08 +0200
Message-ID: <9f26b3733e64ed9fafe1c0f7fcb5807223859d2f.1400448372.git.tilman@imap.cc>
References: <cover.1400448368.git.tilman@imap.cc>
Cc: Paul Bolle <pebolle@tiscali.nl>, isdn4linux@listserv.isdn4linux.de,
	"Keil, Karsten" <isdn@linux-pingi.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([89.1.7.7]:43908 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752150AbaERWnR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 May 2014 18:43:17 -0400
In-Reply-To: <cover.1400448368.git.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Bolle <pebolle@tiscali.nl>

The Kconfig symbol ISDN_DRV_AVMB1_VERBOSE_REASON is only used for
capi_info2str(). That function is only used in capidrv.c. So setting it
without setting ISDN_CAPI_CAPIDRV is pointless. Make it depend on
ISDN_CAPI_CAPIDRV, rename it to ISDN_CAPI_CAPIDRV_VERBOSE and put its
entry after ISDN_CAPI_CAPIDRV's entry.

Since this symbol seems to be primarily used for debugging, keep it off
by default. By now the last users of capidrv hopefully know all they
need to know about the reasons for disconnecting.

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/capi/Kconfig   | 16 ++++++++--------
 drivers/isdn/capi/capidrv.c |  2 +-
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/isdn/capi/Kconfig b/drivers/isdn/capi/Kconfig
index 9816c51..1d7adff 100644
--- a/drivers/isdn/capi/Kconfig
+++ b/drivers/isdn/capi/Kconfig
@@ -1,11 +1,3 @@
-config ISDN_DRV_AVMB1_VERBOSE_REASON
-	bool "Verbose reason code reporting"
-	default y
-	help
-	  If you say Y here, the CAPI drivers will give verbose reasons for
-	  disconnecting. This will increase the size of the kernel by 7 KB. If
-	  unsure, say Y.
-
 config CAPI_TRACE
 	bool "CAPI trace support"
 	default y
@@ -42,3 +34,11 @@ config ISDN_CAPI_CAPIDRV
 	  the legacy isdn4linux link layer.  If you have a card which is
 	  supported by a CAPI driver, but still want to use old features like
 	  ippp interfaces or ttyI emulation, say Y/M here.
+
+config ISDN_CAPI_CAPIDRV_VERBOSE
+	bool "Verbose reason code reporting"
+	depends on ISDN_CAPI_CAPIDRV
+	help
+	  If you say Y here, the capidrv interface will give verbose reasons
+	  for disconnecting. This will increase the size of the kernel by 7 KB.
+	  If unsure, say N.
diff --git a/drivers/isdn/capi/capidrv.c b/drivers/isdn/capi/capidrv.c
index 70e67f6..fd6d28f 100644
--- a/drivers/isdn/capi/capidrv.c
+++ b/drivers/isdn/capi/capidrv.c
@@ -765,7 +765,7 @@ static inline int new_bchan(capidrv_contr *card)
 /* ------------------------------------------------------------------- */
 static char *capi_info2str(u16 reason)
 {
-#ifndef CONFIG_ISDN_DRV_AVMB1_VERBOSE_REASON
+#ifndef CONFIG_ISDN_CAPI_CAPIDRV_VERBOSE
 	return "..";
 #else
 	switch (reason) {
-- 
1.9.2.459.g68773ac
