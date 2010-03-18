From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] atm: Use kasprintf
Date: Fri, 19 Mar 2010 00:48:26 +0100
Message-ID: <1268956106.2894.211.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:56593 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027Ab0CRXsa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 19:48:30 -0400
Received: by bwz1 with SMTP id 1so2568252bwz.21
        for <netdev@vger.kernel.org>; Thu, 18 Mar 2010 16:48:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use kasprintf in atm_proc_dev_register()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/atm/proc.c |   10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/net/atm/proc.c b/net/atm/proc.c
index 7a96b23..f188a39 100644
--- a/net/atm/proc.c
+++ b/net/atm/proc.c
@@ -406,7 +406,6 @@ EXPORT_SYMBOL(atm_proc_root);
 
 int atm_proc_dev_register(struct atm_dev *dev)
 {
-	int digits, num;
 	int error;
 
 	/* No proc info */
@@ -414,16 +413,9 @@ int atm_proc_dev_register(struct atm_dev *dev)
 		return 0;
 
 	error = -ENOMEM;
-	digits = 0;
-	for (num = dev->number; num; num /= 10)
-		digits++;
-	if (!digits)
-		digits++;
-
-	dev->proc_name = kmalloc(strlen(dev->type) + digits + 2, GFP_KERNEL);
+	dev->proc_name = kasprintf(GFP_KERNEL, "%s:%d", dev->type, dev->number);
 	if (!dev->proc_name)
 		goto err_out;
-	sprintf(dev->proc_name, "%s:%d", dev->type, dev->number);
 
 	dev->proc_entry = proc_create_data(dev->proc_name, 0, atm_proc_root,
 					   &proc_atm_dev_ops, dev);


