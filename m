From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH 7/8] sunhme: Remove unnecessary memset of netdev private data
Date: Thu,  6 May 2010 17:41:44 +0200
Message-ID: <1273160504-13308-1-git-send-email-tklauser@distanz.ch>
Cc: kernel-janitors@vger.kernel.org,
	Tobias Klauser <tklauser@distanz.ch>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:46892 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932146Ab0EFPlr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 May 2010 11:41:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The memory for the private data is allocated using kzalloc in
alloc_etherdev (or alloc_netdev_mq respectively) so there is no need to
set it to 0 again.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/sunhme.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sunhme.c b/drivers/net/sunhme.c
index 20deb14..982ff12 100644
--- a/drivers/net/sunhme.c
+++ b/drivers/net/sunhme.c
@@ -3004,7 +3004,6 @@ static int __devinit happy_meal_pci_probe(struct pci_dev *pdev,
 	dev->base_addr = (long) pdev;
 
 	hp = netdev_priv(dev);
-	memset(hp, 0, sizeof(*hp));
 
 	hp->happy_dev = pdev;
 	hp->dma_dev = &pdev->dev;
-- 
1.6.3.3

