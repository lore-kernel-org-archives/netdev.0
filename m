From: Jochen Friedrich <jochen@scram.de>
Subject: [PATCH] b44: Ratelimit timeout error message.
Date: Fri, 12 Feb 2010 21:11:54 +0100
Message-ID: <1266005514-2731-1-git-send-email-jochen@scram.de>
Cc: netdev@vger.kernel.org, Jochen Friedrich <jochen@scram.de>
To: Gary Zambrano <zambrano@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail0.scram.de ([78.47.204.202]:42161 "EHLO mail.scram.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753446Ab0BLUMU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Feb 2010 15:12:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jochen Friedrich <jochen@scram.de>
---
 drivers/net/b44.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 4869adb..499212e 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -189,11 +189,13 @@ static int b44_wait_bit(struct b44 *bp, unsigned long reg,
 		udelay(10);
 	}
 	if (i == timeout) {
-		printk(KERN_ERR PFX "%s: BUG!  Timeout waiting for bit %08x of register "
-		       "%lx to %s.\n",
-		       bp->dev->name,
-		       bit, reg,
-		       (clear ? "clear" : "set"));
+		if (net_ratelimit()) 
+			printk(KERN_ERR PFX "%s: BUG!  Timeout waiting for bit "
+			       "%08x of register "
+			       "%lx to %s.\n",
+			       bp->dev->name,
+			       bit, reg,
+			       (clear ? "clear" : "set"));
 		return -ENODEV;
 	}
 	return 0;
-- 
1.6.6

