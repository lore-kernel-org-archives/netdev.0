From: Seguier Regis <rseguier@e-teleport.net>
Subject: [PATCH] via-velocity : fix no link detection on boot
Date: Tue, 16 Jun 2009 20:33:19 +0000
Message-ID: <1245184399-11890-1-git-send-email-rseguier@e-teleport.net>
Cc: Seguier Regis <rseguier@e-teleport.net>
To: romieu@fr.zoreil.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.e-teleport.net ([213.190.64.162]:49617 "EHLO
	smtp.e-teleport.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751505AbZFPU7M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 16:59:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

on boot, link is always up.

Signed-off-by: Seguier Regis <rseguier@e-teleport.net>
---
 drivers/net/via-velocity.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 754a4b1..bd3335e 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -989,8 +989,11 @@ static int __devinit velocity_found1(struct pci_dev *pdev, const struct pci_devi
 	if (ret < 0)
 		goto err_iounmap;
 
-	if (velocity_get_link(dev))
+	if (!velocity_get_link(dev))
+	{
 		netif_carrier_off(dev);
+		vptr->mii_status |= VELOCITY_LINK_FAIL;
+	}
 
 	velocity_print_info(vptr);
 	pci_set_drvdata(pdev, dev);
-- 
1.6.1.rc2

