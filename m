From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH 4/8] bcm63xx_enet: Remove unnecessary memset of netdev private data
Date: Thu,  6 May 2010 17:40:58 +0200
Message-ID: <1273160458-13039-1-git-send-email-tklauser@distanz.ch>
Cc: kernel-janitors@vger.kernel.org,
	Tobias Klauser <tklauser@distanz.ch>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:46838 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758954Ab0EFPlB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 May 2010 11:41:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The memory for the private data is allocated using kzalloc in
alloc_etherdev (or alloc_netdev_mq respectively) so there is no need to
set it to 0 again.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/bcm63xx_enet.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bcm63xx_enet.c b/drivers/net/bcm63xx_enet.c
index 9a8bdea..f48ba80 100644
--- a/drivers/net/bcm63xx_enet.c
+++ b/drivers/net/bcm63xx_enet.c
@@ -1647,7 +1647,6 @@ static int __devinit bcm_enet_probe(struct platform_device *pdev)
 	if (!dev)
 		return -ENOMEM;
 	priv = netdev_priv(dev);
-	memset(priv, 0, sizeof(*priv));
 
 	ret = compute_hw_mtu(priv, dev->mtu);
 	if (ret)
-- 
1.6.3.3

