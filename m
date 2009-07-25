From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] eepro: Read buffer overflow
Date: Sun, 26 Jul 2009 00:40:59 +0200
Message-ID: <4A6B89FB.8020103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:65026 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752110AbZGYWiY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jul 2009 18:38:24 -0400
Received: by ey-out-2122.google.com with SMTP id 9so641950eyd.37
        for <netdev@vger.kernel.org>; Sat, 25 Jul 2009 15:38:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

io[i] is read before the bounds check on i, order should be reversed

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/net/eepro.c b/drivers/net/eepro.c
index cc2ab64..4f70034 100644
--- a/drivers/net/eepro.c
+++ b/drivers/net/eepro.c
@@ -1784,7 +1784,7 @@ int __init init_module(void)
 		printk(KERN_INFO "eepro_init_module: Auto-detecting boards (May God protect us...)
");
 	}
 
-	for (i = 0; io[i] != -1 && i < MAX_EEPRO; i++) {
+	for (i = 0; i < MAX_EEPRO && io[i] != -1; i++) {
 		dev = alloc_etherdev(sizeof(struct eepro_local));
 		if (!dev)
 			break;
