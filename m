From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V3 10/11] mv643xx_eth: enable transmit time stamping.
Date: Mon, 20 Jun 2011 09:51:32 +0200
Message-ID: <96e6a2899b55ac1272cee8ce63e2549e24a10386.1308556146.git.richard.cochran@omicron.at>
References: <cover.1308556146.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:40854 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753556Ab1FTHwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 03:52:03 -0400
Received: by mail-fx0-f46.google.com with SMTP id 17so760782fxm.19
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2011 00:52:02 -0700 (PDT)
In-Reply-To: <cover.1308556146.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1308556146.git.richard.cochran@omicron.at>
References: <cover.1308556146.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables software (and phy device) transmit time stamping.
Compile tested only.

Cc: Lennert Buytenhek <buytenh@wantstofly.org>
Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/mv643xx_eth.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 1b7d2c1..3671714 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -847,6 +847,8 @@ no_csum:
 	/* clear TX_END status */
 	mp->work_tx_end &= ~(1 << txq->index);
 
+	skb_tx_timestamp(skb);
+
 	/* ensure all descriptors are written before poking hardware */
 	wmb();
 	txq_enable(txq);
-- 
1.7.0.4

