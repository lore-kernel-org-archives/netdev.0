From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] net/spider_net: fix error return code in spider_net_open()
Date: Tue, 7 May 2013 20:16:00 +0800
Message-ID: <CAPgLHd9kSJdv+gdKr6OBcG2h0RmjnWFscELHGEPQwT1kbD5FSQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org
To: kou.ishizaki@toshiba.co.jp, jens@de.ibm.com,
	grant.likely@linaro.org, rob.herring@calxeda.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f45.google.com ([209.85.214.45]:47222 "EHLO
	mail-bk0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757143Ab3EGMQB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 08:16:01 -0400
Received: by mail-bk0-f45.google.com with SMTP id je9so249171bkc.32
        for <netdev@vger.kernel.org>; Tue, 07 May 2013 05:16:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Fix to return a negative error code from the error handling
case instead of 0, as done elsewhere in this function.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/toshiba/spider_net.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/toshiba/spider_net.c b/drivers/net/ethernet/toshiba/spider_net.c
index c655fe6..5734480 100644
--- a/drivers/net/ethernet/toshiba/spider_net.c
+++ b/drivers/net/ethernet/toshiba/spider_net.c
@@ -1990,7 +1990,8 @@ spider_net_open(struct net_device *netdev)
 		goto alloc_rx_failed;
 
 	/* Allocate rx skbs */
-	if (spider_net_alloc_rx_skbs(card))
+	result = spider_net_alloc_rx_skbs(card);
+	if (result)
 		goto alloc_skbs_failed;
 
 	spider_net_set_multi(netdev);
