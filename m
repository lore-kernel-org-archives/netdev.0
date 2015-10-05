From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH] amd-xgbe: Check for successful buffer allocation before use
Date: Mon, 5 Oct 2015 10:51:03 -0500
Message-ID: <20151005155103.10841.38132.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0090.outbound.protection.outlook.com ([157.56.111.90]:45632
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751055AbbJEPvL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Oct 2015 11:51:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The kasprintf function can return NULL if the allocation fails. Check for
successful allocation before attempting to use the returned buffer.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c b/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
index 66137ff..96f485a 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
@@ -327,6 +327,9 @@ void xgbe_debugfs_init(struct xgbe_prv_data *pdata)
 	pdata->debugfs_xpcs_reg = 0;
 
 	buf = kasprintf(GFP_KERNEL, "amd-xgbe-%s", pdata->netdev->name);
+	if (!buf)
+		return;
+
 	pdata->xgbe_debugfs = debugfs_create_dir(buf, NULL);
 	if (!pdata->xgbe_debugfs) {
 		netdev_err(pdata->netdev, "debugfs_create_dir failed\n");
