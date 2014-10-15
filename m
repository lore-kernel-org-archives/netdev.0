From: Zhu Yanjun <zyjzyj2000@gmail.com>
Subject: [PATCH] gianfar: disable vlan tag insertion by default
Date: Wed, 15 Oct 2014 18:00:34 +0800
Message-ID: <1413367234-28652-2-git-send-email-Yanjun.Zhu@windriver.com>
References: <1413367234-28652-1-git-send-email-Yanjun.Zhu@windriver.com>
Cc: Zhu Yanjun <Yanjun.Zhu@windriver.com>
To: sandeep.kumar@freescale.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Yue.Tao@windriver.com,
	guang.yang@windriver.com, joe@perches.com, festevam@gmail.com,
	richardcochran@gmail.com, clarocq@gmail.com,
	yongjun_wei@trendmicro.com.cn, claudiu.manoil@freescale.com,
	w@1wt.eu, roy.xu@huawei.com, sky.wangfeng@huawei.com,
	zyjzyj2000@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1413367234-28652-1-git-send-email-Yanjun.Zhu@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2.6.x kernels require a similar logic change as commit 51b8cbfc
[gianfar: fix bug caused by e1653c3e] introduces for newer kernels.

Gianfar driver originally enables vlan tag insertion by default.
This will lead to unusable connections on some configurations.

Since gianfar nic vlan tag insertion is disabled by default and 
it is not enabled any longer, it is not necessary to disable it 
again.

Reported-by: Xu Jianrong <roy.xu@huawei.com>
Suggested-by: Wang Feng <sky.wangfeng@huawei.com>
---
 drivers/net/gianfar.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 8aa2cf6..afdcb41 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1115,7 +1115,6 @@ int startup_gfar(struct net_device *dev)
 	/* keep vlan related bits if it's enabled */
 	if (priv->vlgrp) {
 		rctrl |= RCTRL_VLEX | RCTRL_PRSDEP_INIT;
-		tctrl |= TCTRL_VLINS;
 	}
 
 	/* Init rctrl based on our settings */
@@ -1456,11 +1455,6 @@ static void gfar_vlan_rx_register(struct net_device *dev,
 		tempval |= (RCTRL_VLEX | RCTRL_PRSDEP_INIT);
 		gfar_write(&priv->regs->rctrl, tempval);
 	} else {
-		/* Disable VLAN tag insertion */
-		tempval = gfar_read(&priv->regs->tctrl);
-		tempval &= ~TCTRL_VLINS;
-		gfar_write(&priv->regs->tctrl, tempval);
-
 		/* Disable VLAN tag extraction */
 		tempval = gfar_read(&priv->regs->rctrl);
 		tempval &= ~RCTRL_VLEX;
-- 
1.9.1
