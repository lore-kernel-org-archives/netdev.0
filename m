From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 20/27] drivers/net/wan: fix sparse warnings: make do-while a
	compound statement
Date: Mon, 22 Dec 2008 20:17:55 +0100
Message-ID: <20081222191755.11807.57896.stgit@vmbox.hanneseder.net>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f21.google.com ([209.85.218.21]:34234 "EHLO
	mail-bw0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757130AbYLVT0F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2008 14:26:05 -0500
Received: by bwz14 with SMTP id 14so8615871bwz.13
        for <netdev@vger.kernel.org>; Mon, 22 Dec 2008 11:26:03 -0800 (PST)
In-Reply-To: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix this sparse warnings:

  drivers/net/wan/wanxl.c:414:3: warning: do-while statement is not a compound statement
  drivers/net/wan/wanxl.c:441:3: warning: do-while statement is not a compound statement

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/net/wan/wanxl.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wan/wanxl.c b/drivers/net/wan/wanxl.c
index 8845949..4bffb67 100644
--- a/drivers/net/wan/wanxl.c
+++ b/drivers/net/wan/wanxl.c
@@ -410,12 +410,12 @@ static int wanxl_open(struct net_device *dev)
 	writel(1 << (DOORBELL_TO_CARD_OPEN_0 + port->node), dbr);
 
 	timeout = jiffies + HZ;
-	do
+	do {
 		if (get_status(port)->open) {
 			netif_start_queue(dev);
 			return 0;
 		}
-	while (time_after(timeout, jiffies));
+	} while (time_after(timeout, jiffies));
 
 	printk(KERN_ERR "%s: unable to open port\n", dev->name);
 	/* ask the card to close the port, should it be still alive */
@@ -437,10 +437,10 @@ static int wanxl_close(struct net_device *dev)
 	       port->card->plx + PLX_DOORBELL_TO_CARD);
 
 	timeout = jiffies + HZ;
-	do
+	do {
 		if (!get_status(port)->open)
 			break;
-	while (time_after(timeout, jiffies));
+	} while (time_after(timeout, jiffies));
 
 	if (get_status(port)->open)
 		printk(KERN_ERR "%s: unable to close port\n", dev->name);

