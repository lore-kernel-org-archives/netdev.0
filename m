From: Benedikt Spranger <b.spranger@linutronix.de>
Subject: [PATCH] net: cpsw: do not register cpts twice
Date: Sun, 16 Mar 2014 16:36:29 +0100
Message-ID: <1394984189-1659-2-git-send-email-b.spranger@linutronix.de>
References: <1394984189-1659-1-git-send-email-b.spranger@linutronix.de>
Cc: tglx@linutronix.de, Mugunthan V N <mugunthanvnm@ti.com>,
	Felipe Balbi <balbi@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	Benedikt Spranger <b.spranger@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:40195 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751122AbaCPPgv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Mar 2014 11:36:51 -0400
In-Reply-To: <1394984189-1659-1-git-send-email-b.spranger@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit f280e89a (drivers: net: cpsw: fix for cpsw crash when build as modules)
moved cpts_register()/cpts_unregister() to  ndo_open()/ndo_stop(), but failed
to remove cpts_register in cpsw_probe() which leads to a double registration
and the following debug object splat.

[   18.991902] ODEBUG: init active (active state 0) object type: timer_list hint: delayed_work_timer_fn+0x0/0x2c
[   19.082249] [<c0059e80>] (init_timer_key) from [<c04965d4>] (cpts_register+0x1f0/0x2c4)
[   19.090642] [<c04965d4>] (cpts_register) from [<c04931dc>] (cpsw_ndo_open+0x780/0x81c)
[   19.098948] [<c04931dc>] (cpsw_ndo_open) from [<c0599c2c>] (__dev_open+0xb4/0x118)

Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>
---
 drivers/net/ethernet/ti/cpsw.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index ffd4d12..7d6d8ec 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2229,10 +2229,6 @@ static int cpsw_probe(struct platform_device *pdev)
 		goto clean_ale_ret;
 	}
 
-	if (cpts_register(&pdev->dev, priv->cpts,
-			  data->cpts_clock_mult, data->cpts_clock_shift))
-		dev_err(priv->dev, "error registering cpts device\n");
-
 	cpsw_notice(priv, probe, "initialized device (regs %pa, irq %d)\n",
 		    &ss_res->start, ndev->irq);
 
-- 
1.9.0
