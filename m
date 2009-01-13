From: akpm@linux-foundation.org
Subject: [patch 1/1] drivers/net/irda/irda-usb.c: fix buffer overflow
Date: Tue, 13 Jan 2009 13:30:54 -0800
Message-ID: <200901132130.n0DLUsjq014237@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	josevteg@gmail.com, linville@tuxdriver.com, samuel@sortiz.org,
	stable@kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35871 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752780AbZAMVbo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 16:31:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jos-Vicente Gilabert <josevteg@gmail.com>

Taken from http://bugzilla.kernel.org/show_bug.cgi?id=12397

We're doing an sprintf of an 11-char string into an 11-char buffer. 
Whoops.  It breaks firmware uploading.

Reported-by: Jos-Vicente Gilabert <josevteg@gmail.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Samuel Ortiz <samuel@sortiz.org>
Cc: "John W. Linville" <linville@tuxdriver.com>
Cc: <stable@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/irda/irda-usb.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/irda/irda-usb.c~drivers-net-irda-irda-usbc-fix-buffer-overflow drivers/net/irda/irda-usb.c
--- a/drivers/net/irda/irda-usb.c~drivers-net-irda-irda-usbc-fix-buffer-overflow
+++ a/drivers/net/irda/irda-usb.c
@@ -1073,7 +1073,7 @@ static int stir421x_patch_device(struct 
 {
 	unsigned int i;
 	int ret;
-	char stir421x_fw_name[11];
+	char stir421x_fw_name[12];
 	const struct firmware *fw;
 	const unsigned char *fw_version_ptr; /* pointer to version string */
 	unsigned long fw_version = 0;
_
