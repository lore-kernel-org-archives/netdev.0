From: Meelis Roos <mroos@linux.ee>
Subject: [PATCH] fore200: fix oops on failed firmware load
Date: Tue, 10 Feb 2009 19:39:24 +0200 (EET)
Message-ID: <Pine.SOC.4.64.0902101701420.11180@math.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.it.da.ut.ee ([193.40.5.67]:53666 "EHLO smtp2.it.da.ut.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753429AbZBJRj0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Feb 2009 12:39:26 -0500
Received: from math.ut.ee (math.ut.ee [193.40.36.2])
	by smtp2.it.da.ut.ee (Postfix) with ESMTP id 9D9E073D7EA
	for <netdev@vger.kernel.org>; Tue, 10 Feb 2009 19:39:24 +0200 (EET)
Received: from localhost (localhost [127.0.0.1])
	by math.ut.ee (Postfix) with ESMTP id 85A8AFD79B
	for <netdev@vger.kernel.org>; Tue, 10 Feb 2009 19:39:24 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fore 200 ATM driver fails to handle request_firmware failures and oopses 
when no firmware file was found. Fix it by checking for the right return 
values and propaganting the return value up.

Signed-off-by: Meelis Roos <mroos@linux.ee>

diff --git a/drivers/atm/fore200e.c b/drivers/atm/fore200e.c
index 937c9c0..10f000d 100644
--- a/drivers/atm/fore200e.c
+++ b/drivers/atm/fore200e.c
@@ -2519,8 +2519,8 @@ fore200e_load_and_start_fw(struct fore200e* fore200e)
 	return err;
 
     sprintf(buf, "%s%s", fore200e->bus->proc_name, FW_EXT);
-    if (request_firmware(&firmware, buf, device) == 1) {
-	printk(FORE200E "missing %s firmware image\n", fore200e->bus->model_name);
+    if ((err = request_firmware(&firmware, buf, device)) < 0) {
+	printk(FORE200E "problem loading firmware image %s\n", fore200e->bus->model_name);
 	return err;
     }
 
-- 
Meelis Roos (mroos@linux.ee)
