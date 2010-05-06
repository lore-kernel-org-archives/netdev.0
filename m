From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH 3/8] KS8695: Remove unnecessary memset of netdev private data
Date: Thu,  6 May 2010 17:40:29 +0200
Message-ID: <1273160429-12964-1-git-send-email-tklauser@distanz.ch>
Cc: kernel-janitors@vger.kernel.org,
	Tobias Klauser <tklauser@distanz.ch>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:46795 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758919Ab0EFPkc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 May 2010 11:40:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The memory for the private data is allocated using kzalloc in
alloc_etherdev (or alloc_netdev_mq respectively) so there is no need to
set it to 0 again.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/arm/ks8695net.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/arm/ks8695net.c b/drivers/net/arm/ks8695net.c
index 7413a87..6404704 100644
--- a/drivers/net/arm/ks8695net.c
+++ b/drivers/net/arm/ks8695net.c
@@ -1472,7 +1472,6 @@ ks8695_probe(struct platform_device *pdev)
 
 	/* Configure our private structure a little */
 	ksp = netdev_priv(ndev);
-	memset(ksp, 0, sizeof(struct ks8695_priv));
 
 	ksp->dev = &pdev->dev;
 	ksp->ndev = ndev;
-- 
1.6.3.3

