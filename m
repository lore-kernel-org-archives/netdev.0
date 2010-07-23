From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH net-next 5/7] be2net: supress printing error when mac query
 fails for VF
Date: Fri, 23 Jul 2010 17:30:24 +0530
Message-ID: <20100723120008.GA24995@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:27647 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753979Ab0GWMAI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 08:00:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a virtual function driver in initialized, the network mac
query command can fail. Skip display of error message in that case.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be_cmds.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 32ae324..cf3af05 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -76,7 +76,8 @@ static int be_mcc_compl_process(struct be_adapter *adapter,
 						sizeof(resp->hw_stats));
 			netdev_stats_update(adapter);
 		}
-	} else if (compl_status != MCC_STATUS_NOT_SUPPORTED) {
+	} else if ((compl_status != MCC_STATUS_NOT_SUPPORTED) &&
+			(compl->tag0 != OPCODE_COMMON_NTWK_MAC_QUERY)) {
 		extd_status = (compl->status >> CQE_STATUS_EXTD_SHIFT) &
 				CQE_STATUS_EXTD_MASK;
 		dev_warn(&adapter->pdev->dev,
-- 
1.7.0.4

