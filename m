From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 1/2] sh_eth: check platform data pointer
Date: Sat, 31 Aug 2013 04:23:29 +0400
Message-ID: <201308310423.30322.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Check the platform data pointer before dereferencing it and error out of the
probe() method if it's NULL.

This has additional effect of preventing kernel oops with outdated platform data
containing zero PHY address instead (such as on SolutionEngine7710).

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
This patch is against Dave's 'net-next.git' repo.

 drivers/net/ethernet/renesas/sh_eth.c |    6 ++++++
 1 file changed, 6 insertions(+)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -2653,6 +2653,12 @@ static int sh_eth_drv_probe(struct platf
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
