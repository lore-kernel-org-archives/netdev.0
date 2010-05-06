From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH 5/8] ethoc: Remove unnecessary memset of napi member in netdev private data
Date: Thu,  6 May 2010 17:41:12 +0200
Message-ID: <1273160472-13127-1-git-send-email-tklauser@distanz.ch>
Cc: kernel-janitors@vger.kernel.org,
	Tobias Klauser <tklauser@distanz.ch>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:46848 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758977Ab0EFPlQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 May 2010 11:41:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The memory for the private data is allocated using kzalloc in
alloc_etherdev (or alloc_netdev_mq respectively) so there is no need to
set the napi member it to 0 explicitely.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethoc.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index 6bd03c8..ad1bc73 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -1040,7 +1040,6 @@ static int ethoc_probe(struct platform_device *pdev)
 	netdev->features |= 0;
 
 	/* setup NAPI */
-	memset(&priv->napi, 0, sizeof(priv->napi));
 	netif_napi_add(netdev, &priv->napi, ethoc_poll, 64);
 
 	spin_lock_init(&priv->rx_lock);
-- 
1.6.3.3

