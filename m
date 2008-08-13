From: Brice Goglin <brice@myri.com>
Subject: [PATCH 2.6.27] myri10ge: myri10ge_fw_name also overrides the rss
 firmware
Date: Wed, 13 Aug 2008 21:05:52 +0200
Message-ID: <48A33090.2060208@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1862 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756478AbYHMTHk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 15:07:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When myri10ge_fw_name is given, use it to override the rss firmware
name as well.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

Index: linux-2.6/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-2.6.orig/drivers/net/myri10ge/myri10ge.c	2008-08-12 16:43:26.000000000 +0200
+++ linux-2.6/drivers/net/myri10ge/myri10ge.c	2008-08-12 16:43:53.000000000 +0200
@@ -3548,7 +3548,11 @@
 
 	/* try to load the slice aware rss firmware */
 	old_fw = mgp->fw_name;
-	if (old_fw == myri10ge_fw_aligned)
+	if (myri10ge_fw_name != NULL) {
+		dev_info(&mgp->pdev->dev, "overriding rss firmware to %s\n",
+			 myri10ge_fw_name);
+		mgp->fw_name = myri10ge_fw_name;
+	} else if (old_fw == myri10ge_fw_aligned)
 		mgp->fw_name = myri10ge_fw_rss_aligned;
 	else
 		mgp->fw_name = myri10ge_fw_rss_unaligned;


