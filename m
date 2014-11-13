From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Subject: [PATCH] net: sh_eth: Add RMII mode setting in probe
Date: Thu, 13 Nov 2014 15:54:05 +0900
Message-ID: <1415861645-27685-1-git-send-email-ykaneko0929@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hisashi Nakamura <hisashi.nakamura.ak@renesas.com>

When using RMMI mode, it is necessary to change in probe.

Signed-off-by: Hisashi Nakamura <hisashi.nakamura.ak@renesas.com>
Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
---

This patch is based on net-next tree.

 drivers/net/ethernet/renesas/sh_eth.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index dbe8606..1f79ed6 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1,5 +1,6 @@
 /*  SuperH Ethernet device driver
  *
+ *  Copyright (C) 2014  Renesas Electronics Corporation
  *  Copyright (C) 2006-2012 Nobuhiro Iwamatsu
  *  Copyright (C) 2008-2014 Renesas Solutions Corp.
  *  Copyright (C) 2013-2014 Cogent Embedded, Inc.
@@ -2883,6 +2884,9 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 		}
 	}
 
+	if (mdp->cd->rmiimode)
+		sh_eth_write(ndev, 0x1, RMIIMODE);
+
 	/* MDIO bus init */
 	ret = sh_mdio_init(mdp, pd);
 	if (ret) {
-- 
1.9.1

