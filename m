From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: [PATCH] net/gianfar: drop recycled skbs on MTU change
Date: Mon, 3 May 2010 17:17:45 +0200
Message-ID: <20100503151745.GA17997@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: netdev@vger.kernel.org
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:57322 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932715Ab0ECPRr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 11:17:47 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

The size for skb which is added to the recycled list is using the
current descriptor size which is current MTU. gfar_new_skb() is also
using this size. So after changing or alteast increasing the MTU all
recycled skbs should be dropped.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
I'm not 100% sure but it looks like it is wrong.

 drivers/net/gianfar.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 5267c27..9093106 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -2287,8 +2287,10 @@ static int gfar_change_mtu(struct net_device *dev, int new_mtu)
 
 	/* Only stop and start the controller if it isn't already
 	 * stopped, and we changed something */
-	if ((oldsize != tempsize) && (dev->flags & IFF_UP))
+	if ((oldsize != tempsize) && (dev->flags & IFF_UP)) {
 		stop_gfar(dev);
+		skb_queue_purge(&priv->rx_recycle);
+	}
 
 	priv->rx_buffer_size = tempsize;
 
-- 
1.6.6.1
