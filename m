From: Lars-Peter Clausen <lars@metafoo.de>
Subject: [PATCH] ieee802154: at86rf230: Remove empty suspend/resume callbacks
Date: Fri, 15 Feb 2013 14:03:29 +0100
Message-ID: <1360933409-2529-1-git-send-email-lars@metafoo.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Lars-Peter Clausen <lars@metafoo.de>
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out-045.synserver.de ([212.40.185.45]:1038 "EHLO
	smtp-out-045.synserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161260Ab3BONIt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 08:08:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to implement empty suspend/resume callbacks if there is nothing
to do during suspend/resume. The drivers will behave the same with no callbacks
or empty callbacks during suspend/resume.

Signed-off-by: Lars-Peter Clausen <lars@metafoo.de>
---
 drivers/net/ieee802154/at86rf230.c | 12 ------------
 1 file changed, 12 deletions(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index a4a62e1..fc1687e 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -751,16 +751,6 @@ static int at86rf230_hw_init(struct at86rf230_local *lp)
 	return 0;
 }
 
-static int at86rf230_suspend(struct spi_device *spi, pm_message_t message)
-{
-	return 0;
-}
-
-static int at86rf230_resume(struct spi_device *spi)
-{
-	return 0;
-}
-
 static int at86rf230_fill_data(struct spi_device *spi)
 {
 	struct at86rf230_local *lp = spi_get_drvdata(spi);
@@ -948,8 +938,6 @@ static struct spi_driver at86rf230_driver = {
 	},
 	.probe      = at86rf230_probe,
 	.remove     = at86rf230_remove,
-	.suspend    = at86rf230_suspend,
-	.resume     = at86rf230_resume,
 };
 
 module_spi_driver(at86rf230_driver);
-- 
1.8.0
