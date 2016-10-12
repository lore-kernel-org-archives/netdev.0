From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 1/2] net: wan: slic_ds26522: add SPI device ID table to fix module autoload
Date: Wed, 12 Oct 2016 15:55:40 -0300
Message-ID: <1476298541-7354-1-git-send-email-javier@osg.samsung.com>
Cc: Javier Martinez Canillas <javier@osg.samsung.com>,
        netdev@vger.kernel.org, Zhao Qiang <qiang.zhao@nxp.com>,
        "David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ec2-52-27-115-49.us-west-2.compute.amazonaws.com ([52.27.115.49]:49318
        "EHLO s-opensource.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754719AbcJLSzw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 14:55:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the driver is built as a module, module alias information isn't filled
so the module won't be autoloaded. Add a SPI device ID table and use the
MODULE_DEVICE_TABLE() macro so the information is exported in the module.

Before this patch:

$ modinfo drivers/net/wan/slic_ds26522.ko | grep alias
$

After this patch:

$ modinfo drivers/net/wan/slic_ds26522.ko | grep alias
alias:          spi:ds26522

Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
---

 drivers/net/wan/slic_ds26522.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/wan/slic_ds26522.c b/drivers/net/wan/slic_ds26522.c
index d06a887a2352..53366a2232f0 100644
--- a/drivers/net/wan/slic_ds26522.c
+++ b/drivers/net/wan/slic_ds26522.c
@@ -223,6 +223,12 @@ static int slic_ds26522_probe(struct spi_device *spi)
 	return ret;
 }
 
+static const struct spi_device_id slic_ds26522_id[] = {
+	{ .name = "ds26522" },
+	{ /* sentinel */ },
+};
+MODULE_DEVICE_TABLE(spi, slic_ds26522_id);
+
 static const struct of_device_id slic_ds26522_match[] = {
 	{
 	 .compatible = "maxim,ds26522",
@@ -239,6 +245,7 @@ static struct spi_driver slic_ds26522_driver = {
 		   },
 	.probe = slic_ds26522_probe,
 	.remove = slic_ds26522_remove,
+	.id_table = slic_ds26522_id,
 };
 
 static int __init slic_ds26522_init(void)
-- 
2.7.4
