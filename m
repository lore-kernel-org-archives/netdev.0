From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH 1/5] net: ethernet: ti: cpsw: use same macros to get active slave
Date: Sat, 10 Dec 2016 14:23:46 +0200
Message-ID: <1481372630-14914-2-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1481372630-14914-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: mugunthanvnm@ti.com, grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481372630-14914-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the same, more convenient macros, to get active slave.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index b62d958..c45f7d2 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1624,10 +1624,7 @@ static void cpsw_hwtstamp_v2(struct cpsw_priv *priv)
 	struct cpsw_common *cpsw = priv->cpsw;
 	u32 ctrl, mtype;
 
-	if (cpsw->data.dual_emac)
-		slave = &cpsw->slaves[priv->emac_port];
-	else
-		slave = &cpsw->slaves[cpsw->data.active_slave];
+	slave = &cpsw->slaves[cpsw_slave_index(cpsw, priv)];
 
 	ctrl = slave_read(slave, CPSW2_CONTROL);
 	switch (cpsw->version) {
-- 
2.7.4
