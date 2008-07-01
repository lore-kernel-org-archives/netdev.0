From: Stefan Roese <sr@denx.de>
Subject: [PATCH v3] ibm_newemac: Fixes kernel crashes when speed of cable connected changes
Date: Tue,  1 Jul 2008 10:58:05 +0200
Message-ID: <1214902685-10489-1-git-send-email-sr@denx.de>
Cc: benh@kernel.crashing.org, Sathya Narayanan <sathyan@teamf1.com>
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.177]:59987 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753218AbYGAI6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 04:58:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Narayanan <sathyan@teamf1.com>

The descriptor pointers were not initialized to NIL values, so it was
poiniting to some random addresses which was completely invalid. This
fix takes care of initializing the descriptor to NIL values and clearing
the valid descriptors on clean ring operation.

Signed-off-by: Sathya Narayanan <sathyan@teamf1.com>
Signed-off-by: Stefan Roese <sr@denx.de>
---
 drivers/net/ibm_newemac/core.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index 5d2108c..ca63fa0 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -2719,6 +2719,8 @@ static int __devinit emac_probe(struct of_device *ofdev,
 	/* Clean rings */
 	memset(dev->tx_desc, 0, NUM_TX_BUFF * sizeof(struct mal_descriptor));
 	memset(dev->rx_desc, 0, NUM_RX_BUFF * sizeof(struct mal_descriptor));
+	memset(dev->tx_skb, 0, NUM_TX_BUFF * sizeof(struct sk_buff *));
+	memset(dev->rx_skb, 0, NUM_RX_BUFF * sizeof(struct sk_buff *));
 
 	/* Attach to ZMII, if needed */
 	if (emac_has_feature(dev, EMAC_FTR_HAS_ZMII) &&
-- 
1.5.6.1

