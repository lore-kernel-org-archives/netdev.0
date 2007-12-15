From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH] sky2: check pci_register_driver() error
Date: Sat, 15 Dec 2007 20:58:51 +0900
Message-ID: <20071215115851.GA4816@APFDCB5C>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:53280 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753097AbXLOL7z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Dec 2007 06:59:55 -0500
Received: by wa-out-1112.google.com with SMTP id v27so1962673wah.23
        for <netdev@vger.kernel.org>; Sat, 15 Dec 2007 03:59:53 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check pci_register_driver() error and clean up debugfs entries
if error happened.

Cc: Stephen Hemminger <shemminger@linux-foundation.org>
Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>

---
 drivers/net/sky2.c |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

Index: 2.6-git/drivers/net/sky2.c
===================================================================
--- 2.6-git.orig/drivers/net/sky2.c
+++ 2.6-git/drivers/net/sky2.c
@@ -4426,8 +4426,15 @@ static struct pci_driver sky2_driver = {
 
 static int __init sky2_init_module(void)
 {
+	int err;
+
 	sky2_debug_init();
-	return pci_register_driver(&sky2_driver);
+	err = pci_register_driver(&sky2_driver);
+	if (err) {
+		sky2_debug_cleanup();
+		return err;
+	}
+	return 0;
 }
 
 static void __exit sky2_cleanup_module(void)
