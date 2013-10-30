From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v3] sh_eth: check platform data pointer
Date: Wed, 30 Oct 2013 23:30:19 +0300
Message-ID: <201310302330.19491.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:47359 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754369Ab3J3TaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 15:30:22 -0400
Received: by mail-lb0-f180.google.com with SMTP id y6so1574493lbh.25
        for <netdev@vger.kernel.org>; Wed, 30 Oct 2013 12:30:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check the platform data pointer before dereferencing it and error out of the
probe() method if it's NULL.

This has additional effect of preventing kernel oops with outdated platform data
containing zero PHY address instead (such as on SolutionEngine7710).

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
This patch is against David Miller's 'net-next.git' repo.

Changes in version 3:
- refreshed the patch.

Changes in version 2:
- refreshed the patch.

 drivers/net/ethernet/renesas/sh_eth.c |    6 ++++++
 1 file changed, 6 insertions(+)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -2663,6 +2663,12 @@ static int sh_eth_drv_probe(struct platf
 	pm_runtime_enable(&pdev->dev);
 	pm_runtime_resume(&pdev->dev);
 
+	if (!pd) {
+		dev_err(&pdev->dev, "no platform data\n");
+		ret = -EINVAL;
+		goto out_release;
+	}
+
 	/* get PHY ID */
 	mdp->phy_id = pd->phy;
 	mdp->phy_interface = pd->phy_interface;
