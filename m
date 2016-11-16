From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net 6/7] net: ethernet: ti: cpsw: add missing sanity check
Date: Wed, 16 Nov 2016 15:35:15 +0100
Message-ID: <1479306916-27673-7-git-send-email-johan@kernel.org>
References: <1479306916-27673-1-git-send-email-johan@kernel.org>
Cc: Grygorii Strashko <grygorii.strashko@ti.com>,
        linux-omap@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Johan Hovold <johan@kernel.org>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479306916-27673-1-git-send-email-johan@kernel.org>
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
index 421da97a5be6..411be060fee6 100644
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
