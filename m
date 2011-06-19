From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 08/11] smsc911x: enable transmit time stamping.
Date: Sun, 19 Jun 2011 13:20:04 +0200
Message-ID: <900cdab4d60bcbaf6940a449e9c70edf19487406.1308481492.git.richard.cochran@omicron.at>
References: <cover.1308481491.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:44082 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753490Ab1FSLUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 07:20:23 -0400
Received: by mail-fx0-f46.google.com with SMTP id 17so448603fxm.19
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2011 04:20:23 -0700 (PDT)
In-Reply-To: <cover.1308481491.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1308481491.git.richard.cochran@omicron.at>
References: <cover.1308481491.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables software (and phy device) transmit time stamping.
Compile tested only.

Cc: Steve Glendinning <steve.glendinning@smsc.com>
Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/smsc911x.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index c6d47d1..6d08b0f 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -1473,6 +1473,7 @@ static int smsc911x_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	pdata->ops->tx_writefifo(pdata, (unsigned int *)bufp, wrsz);
 	freespace -= (skb->len + 32);
+	skb_tx_timestamp(skb);
 	dev_kfree_skb(skb);
 
 	if (unlikely(smsc911x_tx_get_txstatcount(pdata) >= 30))
-- 
1.7.0.4

