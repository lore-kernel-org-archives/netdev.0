From: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Subject: [PATCH] qlge: fix duplicated code for different branches
Date: Sat, 12 Aug 2017 20:58:40 -0500
Message-ID: <20170813015840.GA8443@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <gustavo@embeddedor.com>
To: Harish Patil <harish.patil@cavium.com>,
        Manish Chopra <manish.chopra@cavium.com>,
        Dept-GELinuxNICDev@cavium.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Refactor code in order to avoid identical code for different branches.

This issue was detected with the help of Coccinelle.

Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
---
This code was tested by compilation only.

 drivers/net/ethernet/qlogic/qlge/qlge_dbg.c | 47 +++++++++--------------------
 1 file changed, 14 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_dbg.c b/drivers/net/ethernet/qlogic/qlge/qlge_dbg.c
index 28ea0af..458d55b 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_dbg.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_dbg.c
@@ -144,42 +144,23 @@ static int ql_get_serdes_regs(struct ql_adapter *qdev,
 	xaui_direct_valid = xaui_indirect_valid = 1;
 
 	/* The XAUI needs to be read out per port */
-	if (qdev->func & 1) {
-		/* We are NIC 2	*/
-		status = ql_read_other_func_serdes_reg(qdev,
-				XG_SERDES_XAUI_HSS_PCS_START, &temp);
-		if (status)
-			temp = XG_SERDES_ADDR_XAUI_PWR_DOWN;
-		if ((temp & XG_SERDES_ADDR_XAUI_PWR_DOWN) ==
-					XG_SERDES_ADDR_XAUI_PWR_DOWN)
-			xaui_indirect_valid = 0;
+	status = ql_read_other_func_serdes_reg(qdev,
+			XG_SERDES_XAUI_HSS_PCS_START, &temp);
+	if (status)
+		temp = XG_SERDES_ADDR_XAUI_PWR_DOWN;
 
-		status = ql_read_serdes_reg(qdev,
-				XG_SERDES_XAUI_HSS_PCS_START, &temp);
-		if (status)
-			temp = XG_SERDES_ADDR_XAUI_PWR_DOWN;
+	if ((temp & XG_SERDES_ADDR_XAUI_PWR_DOWN) ==
+				XG_SERDES_ADDR_XAUI_PWR_DOWN)
+		xaui_indirect_valid = 0;
 
-		if ((temp & XG_SERDES_ADDR_XAUI_PWR_DOWN) ==
-					XG_SERDES_ADDR_XAUI_PWR_DOWN)
-			xaui_direct_valid = 0;
-	} else {
-		/* We are NIC 1	*/
-		status = ql_read_other_func_serdes_reg(qdev,
-				XG_SERDES_XAUI_HSS_PCS_START, &temp);
-		if (status)
-			temp = XG_SERDES_ADDR_XAUI_PWR_DOWN;
-		if ((temp & XG_SERDES_ADDR_XAUI_PWR_DOWN) ==
-					XG_SERDES_ADDR_XAUI_PWR_DOWN)
-			xaui_indirect_valid = 0;
+	status = ql_read_serdes_reg(qdev, XG_SERDES_XAUI_HSS_PCS_START, &temp);
 
-		status = ql_read_serdes_reg(qdev,
-				XG_SERDES_XAUI_HSS_PCS_START, &temp);
-		if (status)
-			temp = XG_SERDES_ADDR_XAUI_PWR_DOWN;
-		if ((temp & XG_SERDES_ADDR_XAUI_PWR_DOWN) ==
-					XG_SERDES_ADDR_XAUI_PWR_DOWN)
-			xaui_direct_valid = 0;
-	}
+	if (status)
+		temp = XG_SERDES_ADDR_XAUI_PWR_DOWN;
+
+	if ((temp & XG_SERDES_ADDR_XAUI_PWR_DOWN) ==
+				XG_SERDES_ADDR_XAUI_PWR_DOWN)
+		xaui_direct_valid = 0;
 
 	/*
 	 * XFI register is shared so only need to read one
-- 
2.5.0
