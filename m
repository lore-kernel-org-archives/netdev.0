From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH] smsc911x: Add check for ioremap_nocache() return code
Date: Wed, 12 Jul 2017 23:58:56 +0300
Message-ID: <1499893136-17013-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Steve Glendinning <steve.glendinning@shawell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ispras.ru ([83.149.199.45]:35782 "EHLO mail.ispras.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753282AbdGLU7G (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Jul 2017 16:59:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no check for return code of smsc911x_drv_probe()
in smsc911x_drv_probe(). The patch adds one.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/ethernet/smsc/smsc911x.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index ea1bbc355b4d..0b6a39b003a4 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -2467,6 +2467,10 @@ static int smsc911x_drv_probe(struct platform_device *pdev)
 	pdata = netdev_priv(dev);
 	dev->irq = irq;
 	pdata->ioaddr = ioremap_nocache(res->start, res_size);
+	if (!pdata->ioaddr) {
+		retval = -ENOMEM;
+		goto out_ioremap_fail;
+	}
 
 	pdata->dev = dev;
 	pdata->msg_enable = ((1 << debug) - 1);
@@ -2572,6 +2576,7 @@ static int smsc911x_drv_probe(struct platform_device *pdev)
 	smsc911x_free_resources(pdev);
 out_request_resources_fail:
 	iounmap(pdata->ioaddr);
+out_ioremap_fail:
 	free_netdev(dev);
 out_release_io_1:
 	release_mem_region(res->start, resource_size(res));
-- 
2.7.4
