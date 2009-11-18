From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 2/16] drivers/net/can: remove exceptional & on function name
Date: Wed, 18 Nov 2009 19:20:44 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0911181920250.20943@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Urs Thuermann <urs.thuermann@volkswagen.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	netdev@vger.kernel.org, arnd@arndb.de, joe@perches.com,
	linux-kernel@vger.kernel.org, ker
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:45412 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758218AbZKRSUk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Nov 2009 13:20:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

In this file, function names are otherwise used as pointers without &.

A simplified version of the semantic patch that makes this change is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@r@
identifier f;
@@

f(...) { ... }

@@
identifier r.f;
@@

- &f
+ f
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/can/sja1000/sja1000.c   |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/sja1000/sja1000.c b/drivers/net/can/sja1000/sja1000.c
index 782a47f..b4ba88a 100644
--- a/drivers/net/can/sja1000/sja1000.c
+++ b/drivers/net/can/sja1000/sja1000.c
@@ -516,7 +516,7 @@ static int sja1000_open(struct net_device *dev)
 
 	/* register interrupt handler, if not done by the device driver */
 	if (!(priv->flags & SJA1000_CUSTOM_IRQ_HANDLER)) {
-		err = request_irq(dev->irq, &sja1000_interrupt, priv->irq_flags,
+		err = request_irq(dev->irq, sja1000_interrupt, priv->irq_flags,
 				  dev->name, (void *)dev);
 		if (err) {
 			close_candev(dev);
