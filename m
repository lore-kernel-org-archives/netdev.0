From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V2 10/11] mv643xx_eth: enable transmit time stamping.
Date: Sun, 19 Jun 2011 19:57:03 +0200
Message-ID: <218b70c07656cbf5cb7c448741a6363de4049c75.1308499701.git.richard.cochran@omicron.at>
References: <cover.1308499701.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:49063 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754377Ab1FSR5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 13:57:32 -0400
Received: by mail-bw0-f46.google.com with SMTP id 15so1751766bwz.19
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2011 10:57:31 -0700 (PDT)
In-Reply-To: <cover.1308499701.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1308499701.git.richard.cochran@omicron.at>
References: <cover.1308499701.git.richard.cochran@omicron.at>
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
index a5d9b1c..b63a074 100644
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

