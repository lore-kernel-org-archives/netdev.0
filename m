From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net v1 3/4] amd-xgbe: Fix the xpcs mmd debugfs support
Date: Fri, 29 Aug 2014 13:17:02 -0500
Message-ID: <20140829181702.3257.65947.stgit@tlendack-t1.amdoffice.net>
References: <20140829181643.3257.28011.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0186.outbound.protection.outlook.com ([207.46.163.186]:28780
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752914AbaH2SRI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Aug 2014 14:17:08 -0400
In-Reply-To: <20140829181643.3257.28011.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The debugfs support for the xpcs registers did not properly use the
specified mmd (xpcs_mmd entry) which resulted in the default mmd
value always being used.  Update the debugfs support to generate the
proper mmd register value.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c b/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
index 346592d..a3c1135 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
@@ -272,8 +272,8 @@ static ssize_t xpcs_reg_value_read(struct file *filp, char __user *buffer,
 	struct xgbe_prv_data *pdata = filp->private_data;
 	unsigned int value;
 
-	value = pdata->hw_if.read_mmd_regs(pdata, pdata->debugfs_xpcs_mmd,
-					   pdata->debugfs_xpcs_reg);
+	value = XMDIO_READ(pdata, pdata->debugfs_xpcs_mmd,
+			   pdata->debugfs_xpcs_reg);
 
 	return xgbe_common_read(buffer, count, ppos, value);
 }
@@ -290,8 +290,8 @@ static ssize_t xpcs_reg_value_write(struct file *filp,
 	if (len < 0)
 		return len;
 
-	pdata->hw_if.write_mmd_regs(pdata, pdata->debugfs_xpcs_mmd,
-				    pdata->debugfs_xpcs_reg, value);
+	XMDIO_WRITE(pdata, pdata->debugfs_xpcs_mmd, pdata->debugfs_xpcs_reg,
+		    value);
 
 	return len;
 }
