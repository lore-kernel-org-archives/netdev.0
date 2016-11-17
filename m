From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net v2 6/7] net: ethernet: ti: cpsw: add missing sanity check
Date: Thu, 17 Nov 2016 17:40:03 +0100
Message-ID: <1479400804-9847-7-git-send-email-johan@kernel.org>
References: <1479400804-9847-1-git-send-email-johan@kernel.org>
Cc: Grygorii Strashko <grygorii.strashko@ti.com>,
        linux-omap@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Johan Hovold <johan@kernel.org>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479400804-9847-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure to check for allocation failures before dereferencing a
NULL-pointer during probe.

Fixes: 649a1688c960 ("net: ethernet: ti: cpsw: create common struct to
hold shared driver data")
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/ethernet/ti/cpsw.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 11b2daef3158..1387299030e4 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2588,6 +2588,9 @@ static int cpsw_probe(struct platform_device *pdev)
 	int irq;
 
 	cpsw = devm_kzalloc(&pdev->dev, sizeof(struct cpsw_common), GFP_KERNEL);
+	if (!cpsw)
+		return -ENOMEM;
+
 	cpsw->dev = &pdev->dev;
 
 	ndev = alloc_etherdev_mq(sizeof(struct cpsw_priv), CPSW_MAX_QUEUES);
-- 
2.7.3
