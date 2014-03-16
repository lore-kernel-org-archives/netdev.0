From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH] isdn/capi: Make Middleware depend on CAPI2.0
Date: Sun, 16 Mar 2014 18:44:21 +0100
Message-ID: <5325E2F5.5030204@imap.cc>
References: <1394919189.13157.1.camel@x220>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Paul Bolle <pebolle@tiscali.nl>, isdn4linux@listserv.isdn4linux.de,
	"Keil, Karsten" <isdn@linux-pingi.de>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:59282 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753406AbaCPRoX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Mar 2014 13:44:23 -0400
In-Reply-To: <1394919189.13157.1.camel@x220>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Bolle <pebolle@tiscali.nl>

The Kconfig symbol ISDN_CAPI_MIDDLEWARE is only used in capi.c. Setting
it without setting ISDN_CAPI_CAPI20 is therefor useless. Make it depend
on ISDN_CAPI_CAPI20 and put its entry after ISDN_CAPI_CAPI20's entry.

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---

 drivers/isdn/capi/Kconfig | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/isdn/capi/Kconfig b/drivers/isdn/capi/Kconfig
index f046865..9816c51 100644
--- a/drivers/isdn/capi/Kconfig
+++ b/drivers/isdn/capi/Kconfig
@@ -16,9 +16,17 @@ config CAPI_TRACE
 	  This will increase the size of the kernelcapi module by 20 KB.
 	  If unsure, say Y.
 
+config ISDN_CAPI_CAPI20
+	tristate "CAPI2.0 /dev/capi support"
+	help
+	  This option will provide the CAPI 2.0 interface to userspace
+	  applications via /dev/capi20. Applications should use the
+	  standardized libcapi20 to access this functionality.  You should say
+	  Y/M here.
+
 config ISDN_CAPI_MIDDLEWARE
 	bool "CAPI2.0 Middleware support"
-	depends on TTY
+	depends on ISDN_CAPI_CAPI20 && TTY
 	help
 	  This option will enhance the capabilities of the /dev/capi20
 	  interface.  It will provide a means of moving a data connection,
@@ -26,14 +34,6 @@ config ISDN_CAPI_MIDDLEWARE
 	  device.  If you want to use pppd with pppdcapiplugin to dial up to
 	  your ISP, say Y here.
 
-config ISDN_CAPI_CAPI20
-	tristate "CAPI2.0 /dev/capi support"
-	help
-	  This option will provide the CAPI 2.0 interface to userspace
-	  applications via /dev/capi20. Applications should use the
-	  standardized libcapi20 to access this functionality.  You should say
-	  Y/M here.
-
 config ISDN_CAPI_CAPIDRV
 	tristate "CAPI2.0 capidrv interface support"
 	depends on ISDN_I4L
-- 
1.8.5.3
