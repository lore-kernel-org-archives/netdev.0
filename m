From: Fabio Estevam <fabio.estevam@freescale.com>
Subject: [PATCH] mkiss: Fix error handling in mkiss_open()
Date: Mon, 10 Aug 2015 14:22:43 -0300
Message-ID: <1439227363-6737-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <zy900702@163.com>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bbn0109.outbound.protection.outlook.com ([157.56.111.109]:31712
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932197AbbHJRzn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Aug 2015 13:55:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If register_netdev() fails we are not propagating the error and
we return success because ax_open() succeeded previously.

Fix this by checking the return value of ax_open() and 
register_netdev() and propagate the error in case of failure.

Reported-by: RUC_Soft_Sec <zy900702@163.com>
Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/hamradio/mkiss.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/hamradio/mkiss.c b/drivers/net/hamradio/mkiss.c
index 2ffbf13..216bfd3 100644
--- a/drivers/net/hamradio/mkiss.c
+++ b/drivers/net/hamradio/mkiss.c
@@ -728,11 +728,12 @@ static int mkiss_open(struct tty_struct *tty)
 	dev->type = ARPHRD_AX25;
 
 	/* Perform the low-level AX25 initialization. */
-	if ((err = ax_open(ax->dev))) {
+	err = ax_open(ax->dev);
+	if (err)
 		goto out_free_netdev;
-	}
 
-	if (register_netdev(dev))
+	err = register_netdev(dev);
+	if (err)
 		goto out_free_buffers;
 
 	/* after register_netdev() - because else printk smashes the kernel */
-- 
1.9.1
