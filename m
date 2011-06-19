From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 09/11] pxa168_eth: enable transmit time stamping.
Date: Sun, 19 Jun 2011 13:20:05 +0200
Message-ID: <bda59e6bdd024ed1c3249b1708900d0fa0baa994.1308481492.git.richard.cochran@omicron.at>
References: <cover.1308481491.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Sachin Sanap <ssanap@marvell.com>,
	Zhangfei Gao <zgao6@marvell.com>,
	Philip Rakity <prakity@marvell.com>,
	Mark Brown <markb@marvell.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:44082 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753464Ab1FSLU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 07:20:27 -0400
Received: by mail-fx0-f46.google.com with SMTP id 17so448603fxm.19
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2011 04:20:26 -0700 (PDT)
In-Reply-To: <cover.1308481491.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1308481491.git.richard.cochran@omicron.at>
References: <cover.1308481491.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables software (and phy device) transmit time stamping
Compile tested only.

Cc: Sachin Sanap <ssanap@marvell.com>
Cc: Zhangfei Gao <zgao6@marvell.com>
Cc: Philip Rakity <prakity@marvell.com>
Cc: Mark Brown <markb@marvell.com>
Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/pxa168_eth.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/pxa168_eth.c b/drivers/net/pxa168_eth.c
index 89f7540..cd2e471 100644
--- a/drivers/net/pxa168_eth.c
+++ b/drivers/net/pxa168_eth.c
@@ -1273,6 +1273,7 @@ static int pxa168_eth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	wmb();
 	wrl(pep, SDMA_CMD, SDMA_CMD_TXDH | SDMA_CMD_ERD);
 
+	skb_tx_timestamp(skb);
 	stats->tx_bytes += skb->len;
 	stats->tx_packets++;
 	dev->trans_start = jiffies;
-- 
1.7.0.4

