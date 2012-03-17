From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH RFC 8/8] davinci_emac: Support the get_ts_info ethtool method.
Date: Sat, 17 Mar 2012 13:12:34 +0100
Message-ID: <178ee12ef47bdfb1af344c869715f927286a059a.1331983687.git.richardcochran@gmail.com>
References: <cover.1331983685.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:43662 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030830Ab2CQMNC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Mar 2012 08:13:02 -0400
Received: by mail-wi0-f178.google.com with SMTP id hq7so1983407wib.1
        for <netdev@vger.kernel.org>; Sat, 17 Mar 2012 05:13:02 -0700 (PDT)
In-Reply-To: <cover.1331983685.git.richardcochran@gmail.com>
In-Reply-To: <cover.1331983685.git.richardcochran@gmail.com>
References: <cover.1331983685.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/ti/davinci_emac.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 174a334..155a178 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -613,6 +613,15 @@ static int emac_set_coalesce(struct net_device *ndev,
 
 }
 
+static int emac_get_ts_info(struct net_device *nd, struct ethtool_ts_info *info)
+{
+	info->so_timestamping =
+		SOF_TIMESTAMPING_TX_SOFTWARE |
+		SOF_TIMESTAMPING_RX_SOFTWARE |
+		SOF_TIMESTAMPING_SOFTWARE;
+	info->phc_index = -1;
+	return 0;
+}
 
 /**
  * ethtool_ops: DaVinci EMAC Ethtool structure
@@ -627,6 +636,7 @@ static const struct ethtool_ops ethtool_ops = {
 	.get_link = ethtool_op_get_link,
 	.get_coalesce = emac_get_coalesce,
 	.set_coalesce =  emac_set_coalesce,
+	.get_ts_info = emac_get_ts_info,
 };
 
 /**
-- 
1.7.2.5
