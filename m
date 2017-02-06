From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH] net: ethernet: ti: cpsw: remove netif_trans_update
Date: Tue,  7 Feb 2017 00:53:45 +0200
Message-ID: <1486421625-24413-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: grygorii.strashko@ti.com, netdev@vger.kernel.org,
        linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:35361 "EHLO
        mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751418AbdBFWxw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 17:53:52 -0500
Received: by mail-lf0-f45.google.com with SMTP id n124so53034047lfd.2
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 14:53:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to update jiffies in txq->trans_start twice, it's supposed to be
done in netdev_start_xmit() and anyway is re-written. Also, no reason to
update trans time in case of an error.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
Based on net-next/master

 drivers/net/ethernet/ti/cpsw.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 35a95dc..4d1c0c3 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1601,8 +1601,6 @@ static netdev_tx_t cpsw_ndo_start_xmit(struct sk_buff *skb,
 	struct cpdma_chan *txch;
 	int ret, q_idx;
 
-	netif_trans_update(ndev);
-
 	if (skb_padto(skb, CPSW_MIN_PACKET_SIZE)) {
 		cpsw_err(priv, tx_err, "packet pad failed\n");
 		ndev->stats.tx_dropped++;
-- 
2.7.4
