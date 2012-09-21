From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] net/irda: sh_sir: fix return value check in sh_sir_set_baudrate()
Date: Fri, 21 Sep 2012 15:13:55 +0800
Message-ID: <CAPgLHd9DZuXtx2atvpLV3bHC9tnv+CNaKhvEWzv6f3iS--vfcg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:58597 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753479Ab2IUHNz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 03:13:55 -0400
Received: by qaas11 with SMTP id s11so1029887qaa.19
        for <netdev@vger.kernel.org>; Fri, 21 Sep 2012 00:13:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

In case of error, the function clk_get() returns ERR_PTR()
and never returns NULL pointer. The NULL test in the error
handling should be replaced with IS_ERR().

dpatch engine is used to auto generated this patch.
(https://github.com/weiyj/dpatch)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/irda/sh_sir.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/irda/sh_sir.c b/drivers/net/irda/sh_sir.c
index 256eddf..7951094 100644
--- a/drivers/net/irda/sh_sir.c
+++ b/drivers/net/irda/sh_sir.c
@@ -280,7 +280,7 @@ static int sh_sir_set_baudrate(struct sh_sir_self *self, u32 baudrate)
 	}
 
 	clk = clk_get(NULL, "irda_clk");
-	if (!clk) {
+	if (IS_ERR(clk)) {
 		dev_err(dev, "can not get irda_clk\n");
 		return -EIO;
 	}
