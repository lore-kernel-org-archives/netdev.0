From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH 2/5] net: 7990: Export lance_poll() to modules
Date: Tue, 29 Sep 2015 10:24:03 +0200
Message-ID: <1443515046-13968-3-git-send-email-geert@linux-m68k.org>
References: <1443515046-13968-1-git-send-email-geert@linux-m68k.org>
Cc: Finn Thain <fthain@telegraphics.com.au>,
	Joshua Thompson <funaho@jurai.org>,
	Philip Blundell <philb@gnu.org>, netdev@vger.kernel.org,
	linux-m68k@lists.linux-m68k.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: "David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from andre.telenet-ops.be ([195.130.132.53]:53213 "EHLO
	andre.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932918AbbI2IYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 04:24:09 -0400
In-Reply-To: <1443515046-13968-1-git-send-email-geert@linux-m68k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If CONFIG_HPLANCE=m and CONFIG_NET_POLL_CONTROLLER=y:

    ERROR: "lance_poll" [drivers/net/ethernet/amd/hplance.ko] undefined!

Add the missing export to fix this.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/ethernet/amd/7990.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/amd/7990.c b/drivers/net/ethernet/amd/7990.c
index 98a10d555b793e02..66d0b73c39c03ba2 100644
--- a/drivers/net/ethernet/amd/7990.c
+++ b/drivers/net/ethernet/amd/7990.c
@@ -661,6 +661,7 @@ void lance_poll(struct net_device *dev)
 	spin_unlock(&lp->devlock);
 	lance_interrupt(dev->irq, dev);
 }
+EXPORT_SYMBOL_GPL(lance_poll);
 #endif
 
 MODULE_LICENSE("GPL");
-- 
1.9.1
