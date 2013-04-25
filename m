From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] caif: spi: missing platform_driver_unregister() on error in cfspi_init_module()
Date: Thu, 25 Apr 2013 15:15:23 +0800
Message-ID: <CAPgLHd8BY8bbBS39Y5HP=qMo7p3OGGcQ9LD8ptiXvwees2QjzQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: dmitry.tarnyagin@lockless.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f51.google.com ([209.85.214.51]:50090 "EHLO
	mail-bk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754200Ab3DYHPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 03:15:24 -0400
Received: by mail-bk0-f51.google.com with SMTP id y7so24966bkt.10
        for <netdev@vger.kernel.org>; Thu, 25 Apr 2013 00:15:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Add the missing platform_driver_unregister() before return
from cfspi_init_module() in the error handling case.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/caif/caif_spi.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/caif/caif_spi.c b/drivers/net/caif/caif_spi.c
index 2fb279a..155db68 100644
--- a/drivers/net/caif/caif_spi.c
+++ b/drivers/net/caif/caif_spi.c
@@ -863,6 +863,7 @@ static int __init cfspi_init_module(void)
 	driver_remove_file(&cfspi_spi_driver.driver,
 			   &driver_attr_up_head_align);
  err_create_up_head_align:
+	platform_driver_unregister(&cfspi_spi_driver);
  err_dev_register:
 	return result;
 }
