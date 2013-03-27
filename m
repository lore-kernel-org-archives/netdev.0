From: Colin King <colin.king@canonical.com>
Subject: [PATCH v2] yam: remove redundant null check on dev
Date: Wed, 27 Mar 2013 18:25:04 +0000
Message-ID: <1364408704-27359-1-git-send-email-colin.king@canonical.com>
To: Jean-Paul Roubelat <jpr@f6fbb.org>, linux-hams@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:33295 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752568Ab3C0SZG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 14:25:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

yam_open has a redundant null check on null,  it will
never be called with dev == NULL. Remove this redundant check.
This also cleans up a smatch warning:

drivers/net/hamradio/yam.c:869 yam_open() warn: variable
  dereferenced before check 'dev' (see line 867)

Signed-off-by: Colin Ian King <colin.king@canonical.com>
Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/hamradio/yam.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/hamradio/yam.c b/drivers/net/hamradio/yam.c
index 4cf8f10..b2d863f 100644
--- a/drivers/net/hamradio/yam.c
+++ b/drivers/net/hamradio/yam.c
@@ -866,7 +866,7 @@ static int yam_open(struct net_device *dev)
 
 	printk(KERN_INFO "Trying %s at iobase 0x%lx irq %u\n", dev->name, dev->base_addr, dev->irq);
 
-	if (!dev || !yp->bitrate)
+	if (!yp->bitrate)
 		return -ENXIO;
 	if (!dev->base_addr || dev->base_addr > 0x1000 - YAM_EXTENT ||
 		dev->irq < 2 || dev->irq > 15) {
-- 
1.7.9.5
