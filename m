From: Kim Phillips <kim.phillips@freescale.com>
Subject: [PATCH 1/2] net: gianfar - initialize per-queue statistics
Date: Tue, 30 Mar 2010 16:54:21 -0500
Message-ID: <1269986062-1697-1-git-send-email-kim.phillips@freescale.com>
Cc: Kim Phillips <kim.phillips@freescale.com>
To: "David S. Miller" <davem@davemloft.net>,
	Anton Vorontsov <avorontsov@ru.mvista.com>,
	Sandeep Gopalpet <Sandeep.Kumar@freescale.com>,
	Kumar Gala <galak@kernel.crashing.org>,
	Andy Flem
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:54974 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754475Ab0C3Vqk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 17:46:40 -0400
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id o2ULkdNQ006914
	for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 14:46:39 -0700 (MST)
Received: from az33exm22.fsl.freescale.net (az33exm22.am.freescale.net [10.64.32.10])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id o2ULsBSt007633
	for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 16:54:11 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Interfaces come up claiming having already received 3.0 GiB.
Use kzalloc to properly initialize per-queue data.

Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
---
 drivers/net/gianfar.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 669de02..d557ab6 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -676,7 +676,7 @@ static int gfar_of_init(struct of_device *ofdev, struct net_device **pdev)
 		priv->rx_queue[i] = NULL;
 
 	for (i = 0; i < priv->num_tx_queues; i++) {
-		priv->tx_queue[i] =  (struct gfar_priv_tx_q *)kmalloc(
+		priv->tx_queue[i] =  (struct gfar_priv_tx_q *)kzalloc(
 				sizeof (struct gfar_priv_tx_q), GFP_KERNEL);
 		if (!priv->tx_queue[i]) {
 			err = -ENOMEM;
@@ -689,7 +689,7 @@ static int gfar_of_init(struct of_device *ofdev, struct net_device **pdev)
 	}
 
 	for (i = 0; i < priv->num_rx_queues; i++) {
-		priv->rx_queue[i] = (struct gfar_priv_rx_q *)kmalloc(
+		priv->rx_queue[i] = (struct gfar_priv_rx_q *)kzalloc(
 					sizeof (struct gfar_priv_rx_q), GFP_KERNEL);
 		if (!priv->rx_queue[i]) {
 			err = -ENOMEM;
-- 
1.7.0.2

