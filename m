From: Baoyou Xie <baoyou.xie@linaro.org>
Subject: [PATCH] net: hip04: mark tx_done() static
Date: Sun, 25 Sep 2016 17:19:04 +0800
Message-ID: <1474795144-15983-1-git-send-email-baoyou.xie@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, baoyou.xie@linaro.org, xie.baoyou@zte.com.cn,
        han.fei@zte.com.cn, tang.qiang007@zte.com.cn
To: yisen.zhuang@huawei.com, salil.mehta@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33616 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965729AbcIYJTU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 05:19:20 -0400
Received: by mail-pf0-f176.google.com with SMTP id 21so55610941pfy.0
        for <netdev@vger.kernel.org>; Sun, 25 Sep 2016 02:19:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We get 1 warning when building kernel with W=1:
drivers/net/ethernet/hisilicon/hip04_eth.c:603:22: warning: no previous prototype for 'tx_done' [-Wmissing-prototypes]

In fact, this function is only used in the file in which it is
declared and don't need a declaration, but can be made static.
so this patch marks this function with 'static'.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/net/ethernet/hisilicon/hip04_eth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hip04_eth.c b/drivers/net/ethernet/hisilicon/hip04_eth.c
index 415ffa1..3977889 100644
--- a/drivers/net/ethernet/hisilicon/hip04_eth.c
+++ b/drivers/net/ethernet/hisilicon/hip04_eth.c
@@ -600,7 +600,7 @@ static irqreturn_t hip04_mac_interrupt(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-enum hrtimer_restart tx_done(struct hrtimer *hrtimer)
+static enum hrtimer_restart tx_done(struct hrtimer *hrtimer)
 {
 	struct hip04_priv *priv;
 
-- 
2.7.4
