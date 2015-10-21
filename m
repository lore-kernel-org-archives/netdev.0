From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 8/8] cxgb4: Update ethtool get_drvinfo to get regdump len
Date: Wed, 21 Oct 2015 14:39:57 +0530
Message-ID: <1445418597-771-9-git-send-email-hariprasad@chelsio.com>
References: <1445418597-771-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.115.98]:30368 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752733AbbJUJKO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 05:10:14 -0400
In-Reply-To: <1445418597-771-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update ethtool get_drvinfo to display regdump len and also update
firmware string version print to display N/A in case FW isn't present

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
index 43e0bc5..a077f94 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
@@ -211,8 +211,11 @@ static void get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 		sizeof(info->version));
 	strlcpy(info->bus_info, pci_name(adapter->pdev),
 		sizeof(info->bus_info));
+	info->regdump_len = get_regs_len(dev);
 
-	if (adapter->params.fw_vers)
+	if (!adapter->params.fw_vers)
+		strcpy(info->fw_version, "N/A");
+	else
 		snprintf(info->fw_version, sizeof(info->fw_version),
 			 "%u.%u.%u.%u, TP %u.%u.%u.%u",
 			 FW_HDR_FW_VER_MAJOR_G(adapter->params.fw_vers),
-- 
2.3.4
