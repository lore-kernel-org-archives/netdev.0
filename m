From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 2/2] net: wan: slic_ds26522: Export OF module alias information
Date: Wed, 12 Oct 2016 15:55:41 -0300
Message-ID: <1476298541-7354-2-git-send-email-javier@osg.samsung.com>
References: <1476298541-7354-1-git-send-email-javier@osg.samsung.com>
Cc: Javier Martinez Canillas <javier@osg.samsung.com>,
        netdev@vger.kernel.org, Zhao Qiang <qiang.zhao@nxp.com>,
        "David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ec2-52-27-115-49.us-west-2.compute.amazonaws.com ([52.27.115.49]:49324
        "EHLO s-opensource.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755937AbcJLSzz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 14:55:55 -0400
In-Reply-To: <1476298541-7354-1-git-send-email-javier@osg.samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the device is registered via OF, the OF table is used to match the
driver instead of the SPI device ID table, but the entries in the later
are used as aliasses to load the module if the driver was not built-in.

This is because the SPI core always reports an SPI module alias instead
of an OF one, but that could change so it's better to always export it.

Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
---

 drivers/net/wan/slic_ds26522.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wan/slic_ds26522.c b/drivers/net/wan/slic_ds26522.c
index 53366a2232f0..b776a0ab106c 100644
--- a/drivers/net/wan/slic_ds26522.c
+++ b/drivers/net/wan/slic_ds26522.c
@@ -235,6 +235,7 @@ static const struct of_device_id slic_ds26522_match[] = {
 	 },
 	{},
 };
+MODULE_DEVICE_TABLE(of, slic_ds26522_match);
 
 static struct spi_driver slic_ds26522_driver = {
 	.driver = {
-- 
2.7.4
