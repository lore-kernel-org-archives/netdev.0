From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/2] korina: fix misplaced return statement
Date: Sun, 20 Apr 2008 18:05:31 +0200
Message-ID: <20080420160531.GA26599@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Florian Fainelli <florian.fainelli@telecomint.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:43147 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752821AbYDTQXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Apr 2008 12:23:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver takes the error unwind path without condition.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/korina.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/korina.c b/drivers/net/korina.c
index 1d24a73..305be62 100644
--- a/drivers/net/korina.c
+++ b/drivers/net/korina.c
@@ -1031,6 +1031,8 @@ static int korina_open(struct net_device *dev)
 		    dev->name, lp->und_irq);
 		goto err_free_ovr_irq;
 	}
+out:
+	return ret;
 
 err_free_ovr_irq:
 	free_irq(lp->ovr_irq, dev);
@@ -1041,8 +1043,6 @@ err_free_rx_irq:
 err_release:
 	korina_free_ring(dev);
 	goto out;
-out:
-	return ret;
 }
 
 static int korina_close(struct net_device *dev)
-- 
1.5.3.3

