From: Bryan Wu <cooloney@kernel.org>
Subject: [PATCH 1/3] Blackfin EMAC Driver: add proper __devinit/__devexit markings
Date: Sun, 27 Jul 2008 22:45:03 +0800
Message-ID: <1217169905-7055-2-git-send-email-cooloney@kernel.org>
References: <1217169905-7055-1-git-send-email-cooloney@kernel.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mike Frysinger <vapier.adi@gmail.com>,
	Bryan Wu <cooloney@kernel.org>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from po-out-1718.google.com ([72.14.252.157]:28450 "EHLO
	po-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752870AbYG0OpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jul 2008 10:45:19 -0400
Received: by po-out-1718.google.com with SMTP id c31so8301862poi.1
        for <netdev@vger.kernel.org>; Sun, 27 Jul 2008 07:45:18 -0700 (PDT)
In-Reply-To: <1217169905-7055-1-git-send-email-cooloney@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier.adi@gmail.com>

Signed-off-by: Mike Frysinger <vapier.adi@gmail.com>
Signed-off-by: Bryan Wu <cooloney@kernel.org>
---
 drivers/net/bfin_mac.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 4144343..17951cb 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -956,7 +956,7 @@ static int bfin_mac_close(struct net_device *dev)
 	return 0;
 }
 
-static int __init bfin_mac_probe(struct platform_device *pdev)
+static int __devinit bfin_mac_probe(struct platform_device *pdev)
 {
 	struct net_device *ndev;
 	struct bfin_mac_local *lp;
@@ -1082,7 +1082,7 @@ out_err_probe_mac:
 	return rc;
 }
 
-static int bfin_mac_remove(struct platform_device *pdev)
+static int __devexit bfin_mac_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct bfin_mac_local *lp = netdev_priv(ndev);
@@ -1129,7 +1129,7 @@ static int bfin_mac_resume(struct platform_device *pdev)
 
 static struct platform_driver bfin_mac_driver = {
 	.probe = bfin_mac_probe,
-	.remove = bfin_mac_remove,
+	.remove = __devexit_p(bfin_mac_remove),
 	.resume = bfin_mac_resume,
 	.suspend = bfin_mac_suspend,
 	.driver = {
-- 
1.5.6

