From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] net: macb: fix missing unlock on error in macb_start_xmit()
Date: Sat, 10 Sep 2016 11:17:57 +0000
Message-ID: <1473506277-31304-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Nicolas Ferre <nicolas.ferre@atmel.com>,
        Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:36187 "EHLO
        mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751066AbcIJLSE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Sep 2016 07:18:04 -0400
Received: by mail-pa0-f65.google.com with SMTP id ez1so5100324pab.3
        for <netdev@vger.kernel.org>; Sat, 10 Sep 2016 04:18:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Fix missing unlock before return from function macb_start_xmit()
in the error handling case.

Fixes: 007e4ba3ee13 ("net: macb: initialize checksum when using
checksum offloading")
Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/ethernet/cadence/macb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 0294b6a..63144bb 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1398,7 +1398,7 @@ static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (macb_clear_csum(skb)) {
 		dev_kfree_skb_any(skb);
-		return NETDEV_TX_OK;
+		goto unlock;
 	}
 
 	/* Map socket buffer for DMA transfer */
