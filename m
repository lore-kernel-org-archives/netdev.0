From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 06/12] isdn/capi: correct capi20_manufacturer argument type mismatch
Date: Sat, 11 Oct 2014 13:46:30 +0200 (CEST)
Message-ID: <c6167666dd9c206765eac6d87f421e0405eb59b1.1413021630.git.tilman@imap.cc>
References: <cover.1413021630.git.tilman@imap.cc>
Cc: David Miller <davem@davemloft.net>, Dave Jones <davej@redhat.com>,
	Hansjoerg Lipp <hjlipp@web.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([89.1.7.7]:50234 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752099AbaJKLrD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Oct 2014 07:47:03 -0400
In-Reply-To: <cover.1413021630.git.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Function capi20_manufacturer() is declared with unsigned int cmd
argument but called with unsigned long.
Fix by correcting the function prototype since the actual argument
is part of the user visible API.

Spotted with Coverity.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
Note: The issue about printk(KERN_ERR which checkpatch is complaining
about is already present in the original file in this and many other
places. Cleaning it up is outside the scope of this patch.

 drivers/isdn/capi/kcapi.c  | 4 ++--
 include/linux/kernelcapi.h | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/isdn/capi/kcapi.c b/drivers/isdn/capi/kcapi.c
index c123709..823f698 100644
--- a/drivers/isdn/capi/kcapi.c
+++ b/drivers/isdn/capi/kcapi.c
@@ -1184,7 +1184,7 @@ static int old_capi_manufacturer(unsigned int cmd, void __user *data)
  * Return value: CAPI result code
  */
 
-int capi20_manufacturer(unsigned int cmd, void __user *data)
+int capi20_manufacturer(unsigned long cmd, void __user *data)
 {
 	struct capi_ctr *ctr;
 	int retval;
@@ -1259,7 +1259,7 @@ int capi20_manufacturer(unsigned int cmd, void __user *data)
 	}
 
 	default:
-		printk(KERN_ERR "kcapi: manufacturer command %d unknown.\n",
+		printk(KERN_ERR "kcapi: manufacturer command %lu unknown.\n",
 		       cmd);
 		break;
 
diff --git a/include/linux/kernelcapi.h b/include/linux/kernelcapi.h
index 9be37da..e985ba6 100644
--- a/include/linux/kernelcapi.h
+++ b/include/linux/kernelcapi.h
@@ -41,7 +41,7 @@ u16 capi20_get_manufacturer(u32 contr, u8 buf[CAPI_MANUFACTURER_LEN]);
 u16 capi20_get_version(u32 contr, struct capi_version *verp);
 u16 capi20_get_serial(u32 contr, u8 serial[CAPI_SERIAL_LEN]);
 u16 capi20_get_profile(u32 contr, struct capi_profile *profp);
-int capi20_manufacturer(unsigned int cmd, void __user *data);
+int capi20_manufacturer(unsigned long cmd, void __user *data);
 
 #define CAPICTR_UP			0
 #define CAPICTR_DOWN			1
-- 
1.9.2.459.g68773ac
