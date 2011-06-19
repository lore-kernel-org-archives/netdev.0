From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 10/11] mv643xx_eth: enable transmit time stamping.
Date: Sun, 19 Jun 2011 13:20:06 +0200
Message-ID: <1b5632e5cd90ed390245f3d1264e42fdd760dd7e.1308481492.git.richard.cochran@omicron.at>
References: <cover.1308481491.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:44082 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753501Ab1FSLU3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 07:20:29 -0400
Received: by mail-fx0-f46.google.com with SMTP id 17so448603fxm.19
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2011 04:20:29 -0700 (PDT)
In-Reply-To: <cover.1308481491.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1308481491.git.richard.cochran@omicron.at>
References: <cover.1308481491.git.richard.cochran@omicron.at>
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
index a5d9b1c..c7a8f10 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -884,6 +884,8 @@ static netdev_tx_t mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (!txq_submit_skb(txq, skb)) {
 		int entries_left;
 
+		skb_tx_timestamp(skb);
+
 		txq->tx_bytes += skb->len;
 		txq->tx_packets++;
 
-- 
1.7.0.4

