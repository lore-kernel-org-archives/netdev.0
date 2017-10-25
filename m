From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] drivers/net: arcnet: Convert timers to use timer_setup()
Date: Wed, 25 Oct 2017 03:54:06 -0700
Message-ID: <20171025105406.GA146659@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Grzeschik <m.grzeschik@pengutronix.de>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:43246 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932422AbdJYKyI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 06:54:08 -0400
Received: by mail-pg0-f65.google.com with SMTP id s75so16999889pgs.0
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 03:54:08 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Michael Grzeschik <m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/arcnet/arcnet.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
index 13236b2cdf13..8459115d9d4e 100644
--- a/drivers/net/arcnet/arcnet.c
+++ b/drivers/net/arcnet/arcnet.c
@@ -382,9 +382,10 @@ static void arcdev_setup(struct net_device *dev)
 	dev->flags = IFF_BROADCAST;
 }
 
-static void arcnet_timer(unsigned long data)
+static void arcnet_timer(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *)data;
+	struct arcnet_local *lp = from_timer(lp, t, timer);
+	struct net_device *dev = lp->dev;
 
 	if (!netif_carrier_ok(dev)) {
 		netif_carrier_on(dev);
@@ -450,7 +451,7 @@ struct net_device *alloc_arcdev(const char *name)
 
 		lp->dev = dev;
 		spin_lock_init(&lp->lock);
-		setup_timer(&lp->timer, arcnet_timer, (unsigned long)dev);
+		timer_setup(&lp->timer, arcnet_timer, 0);
 	}
 
 	return dev;
-- 
2.7.4


-- 
Kees Cook
Pixel Security
