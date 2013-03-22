From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] s6gmac: fix error return code in s6gmac_probe()
Date: Fri, 22 Mar 2013 21:17:47 +0800
Message-ID: <CAPgLHd87mx9eMA1O_Nr9uxtKq=uMvmVW=uzaUPwhcjrAe43eaw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: davem@davemloft.net, jim.cromie@gmail.com,
	gregkh@linuxfoundation.org, jkosina@suse.cz, oskar@scara.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f45.google.com ([209.85.214.45]:40021 "EHLO
	mail-bk0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753876Ab3CVNRt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 09:17:49 -0400
Received: by mail-bk0-f45.google.com with SMTP id i18so1866420bkv.32
        for <netdev@vger.kernel.org>; Fri, 22 Mar 2013 06:17:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Fix to return a negative error code from the error handling
case instead of 0, as returned elsewhere in this function.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/s6gmac.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/s6gmac.c b/drivers/net/ethernet/s6gmac.c
index cd5f4e2..b6739af 100644
--- a/drivers/net/ethernet/s6gmac.c
+++ b/drivers/net/ethernet/s6gmac.c
@@ -998,6 +998,7 @@ static int s6gmac_probe(struct platform_device *pdev)
 	mb = mdiobus_alloc();
 	if (!mb) {
 		printk(KERN_ERR DRV_PRMT "error allocating mii bus\n");
+		res = -ENOMEM;
 		goto errmii;
 	}
 	mb->name = "s6gmac_mii";
