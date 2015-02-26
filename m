From: Jaedon Shin <jaedon.shin@gmail.com>
Subject: [PATCH] net: bcmgenet: fix throughtput regression with TSO autosizing
Date: Thu, 26 Feb 2015 20:05:58 +0900
Message-ID: <1424948758-48244-1-git-send-email-jaedon.shin@gmail.com>
Cc: netdev@vger.kernel.org, Jaedon Shin <jaedon.shin@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:46549 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932166AbbBZLGg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 06:06:36 -0500
Received: by pdjy10 with SMTP id y10so12194959pdj.13
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 03:06:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch prevents the performance degradation of xmit after
605ad7f ("tcp: refine TSO autosizing").

Signed-off-by: Jaedon Shin <jaedon.shin@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index ff83c46b..87eeff0 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1310,6 +1310,9 @@ static netdev_tx_t bcmgenet_xmit(struct sk_buff *skb, struct net_device *dev)
 out:
 	spin_unlock_irqrestore(&ring->lock, flags);
 
+	if (index != DESC_INDEX)
+		skb_orphan(skb);
+
 	return ret;
 }
 
-- 
2.3.0
