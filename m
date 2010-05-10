From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 9/9] netdev: bfin_mac: check for mii_bus platform data
Date: Mon, 10 May 2010 11:39:14 -0400
Message-ID: <1273505954-32588-9-git-send-email-vapier@gentoo.org>
References: <1273505954-32588-1-git-send-email-vapier@gentoo.org>
Cc: uclinux-dist-devel@blackfin.uclinux.org,
	Sonic Zhang <sonic.zhang@analog.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:43509 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753330Ab0EJPg2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 May 2010 11:36:28 -0400
In-Reply-To: <1273505954-32588-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sonic Zhang <sonic.zhang@analog.com>

If the platform data for the mii_bus is missing, gracefully error out
rather than deference NULL pointers.

Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 drivers/net/bfin_mac.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 0b62dbf..0f0aa57 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -1469,6 +1469,11 @@ static int __devinit bfin_mac_probe(struct platform_device *pdev)
 	}
 	pd = pdev->dev.platform_data;
 	lp->mii_bus = platform_get_drvdata(pd);
+	if (!lp->mii_bus) {
+		dev_err(&pdev->dev, "Cannot get mii_bus!\n");
+		rc = -ENODEV;
+		goto out_err_mii_bus_probe;
+	}
 	lp->mii_bus->priv = ndev;
 
 	rc = mii_probe(ndev);
@@ -1514,6 +1519,7 @@ out_err_request_irq:
 out_err_mii_probe:
 	mdiobus_unregister(lp->mii_bus);
 	mdiobus_free(lp->mii_bus);
+out_err_mii_bus_probe:
 	peripheral_free_list(pin_req);
 out_err_probe_mac:
 	platform_set_drvdata(pdev, NULL);
-- 
1.7.1

