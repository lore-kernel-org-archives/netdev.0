From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] dwc_eth_qos: use dev_kfree_skb_any instead of dev_kfree_skb
Date: Thu, 20 Oct 2016 16:59:49 +0000
Message-ID: <1476982789-27821-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Lars Persson <lars.persson@axis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33241 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752463AbcJTRAP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 13:00:15 -0400
Received: by mail-pf0-f195.google.com with SMTP id i85so6078453pfa.0
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 10:00:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Replace dev_kfree_skb with dev_kfree_skb_any in dwceqos_start_xmit()
which can be called from hard irq context (netpoll) and from
other contexts. dwceqos_start_xmit() only frees skbs that it has
dropped.

This is detected by Coccinelle semantic patch.

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/ethernet/synopsys/dwc_eth_qos.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/synopsys/dwc_eth_qos.c b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
index 0d00531..eaa51ce 100644
--- a/drivers/net/ethernet/synopsys/dwc_eth_qos.c
+++ b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
@@ -2211,7 +2211,7 @@ static int dwceqos_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 
 tx_error:
 	dwceqos_tx_rollback(lp, &trans);
-	dev_kfree_skb(skb);
+	dev_kfree_skb_any(skb);
 	return 0;
 }
 
