From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH] amd-xgbe: fix potential memory leak in xgbe-debugfs
Date: Wed, 30 Sep 2015 03:48:50 -0700
Message-ID: <636eed156113df40f9dd5e696f0486f428aff590.1443638366.git.geliangtang@163.com>
Cc: Geliang Tang <geliangtang@163.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tom Lendacky <thomas.lendacky@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-13.163.com ([220.181.12.13]:40391 "EHLO m12-13.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754821AbbI3KtM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 06:49:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added kfree() to avoid the memory leak when debugfs_create_dir() fails.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c b/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
index 2c063b6..66137ff 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
@@ -330,6 +330,7 @@ void xgbe_debugfs_init(struct xgbe_prv_data *pdata)
 	pdata->xgbe_debugfs = debugfs_create_dir(buf, NULL);
 	if (!pdata->xgbe_debugfs) {
 		netdev_err(pdata->netdev, "debugfs_create_dir failed\n");
+		kfree(buf);
 		return;
 	}
 
-- 
1.9.1
