From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net 2/7] net: ethernet: ti: cpsw: fix mdio device reference leak
Date: Wed, 16 Nov 2016 15:35:11 +0100
Message-ID: <1479306916-27673-3-git-send-email-johan@kernel.org>
References: <1479306916-27673-1-git-send-email-johan@kernel.org>
Cc: Grygorii Strashko <grygorii.strashko@ti.com>,
        linux-omap@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Johan Hovold <johan@kernel.org>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479306916-27673-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure to drop the reference taken by of_find_device_by_node() when
looking up an mdio device from a phy_id property during probe.

Fixes: 549985ee9c72 ("cpsw: simplify the setup of the register
pointers")
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/ethernet/ti/cpsw.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 5bc5e6189661..ee1fae914abc 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2397,6 +2397,7 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 			}
 			snprintf(slave_data->phy_id, sizeof(slave_data->phy_id),
 				 PHY_ID_FMT, mdio->name, phyid);
+			put_device(&mdio->dev);
 		} else {
 			dev_err(&pdev->dev,
 				"No slave[%d] phy_id, phy-handle, or fixed-link property\n",
-- 
2.7.3
