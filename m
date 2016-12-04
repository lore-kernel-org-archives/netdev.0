From: Pan Bian <bianpan201604@163.com>
Subject: [PATCH 1/1] net: ethernet: qlogic: fix improper return value
Date: Sun,  4 Dec 2016 14:15:17 +0800
Message-ID: <1480832117-5526-1-git-send-email-bianpan201604@163.com>
Cc: linux-kernel@vger.kernel.org, Pan Bian <bianpan2016@163.com>
To: Harish Patil <harish.patil@cavium.com>,
        Manish Chopra <manish.chopra@cavium.com>,
        Dept-GELinuxNICDev@cavium.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m50-135.163.com ([123.125.50.135]:43159 "EHLO m50-135.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752585AbcLDGP2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 4 Dec 2016 01:15:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pan Bian <bianpan2016@163.com>

When the call to qlcnic_alloc_mbx_args() fails, returning variable "err"
seems improper. With reference to the context, returing variable
"config" may be better.

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=189101

Signed-off-by: Pan Bian <bianpan2016@163.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index bdbcd2b..21c4aca 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -3189,7 +3189,7 @@ int qlcnic_83xx_test_link(struct qlcnic_adapter *adapter)
 
 	err = qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_GET_LINK_STATUS);
 	if (err)
-		return err;
+		return config;
 
 	err = qlcnic_issue_cmd(adapter, &cmd);
 	if (err) {
-- 
1.9.1
