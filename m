From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH 1/1] drivers: net: cpsw: fix dt probe for one port ethernet
Date: Mon, 2 Dec 2013 12:53:39 +0530
Message-ID: <1385969019-12880-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-omap@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-omap-owner@vger.kernel.org>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When only one port of the two port is pinned out, then dt probe is failing
because second port phy is not found. fixing this by checking the number of
slaves and breaking the loop.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 90d41d2..68ef9f2 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1813,6 +1813,8 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 		}
 
 		i++;
+		if (i == data->slaves)
+			break;
 	}
 
 	return 0;
-- 
1.8.5.rc3.2.gc302941

