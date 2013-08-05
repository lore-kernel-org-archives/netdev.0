From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] tile: fix missing unlock on error in tile_net_open()
Date: Mon, 5 Aug 2013 12:42:00 +0800
Message-ID: <CAPgLHd8k5yfO4G1Fvz86VSC-HbwgGEb8OwTShAa5e+owRvaMqg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: cmetcalf@tilera.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f54.google.com ([209.85.214.54]:64859 "EHLO
	mail-bk0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750868Ab3HEEmC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 00:42:02 -0400
Received: by mail-bk0-f54.google.com with SMTP id it19so794450bkc.27
        for <netdev@vger.kernel.org>; Sun, 04 Aug 2013 21:42:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Add the missing unlock before return from function tile_net_open()
in the error handling case.

Introduced by commit f3286a3af89d6db7a488f3e8f02b98d67d50f00c.
(tile: support multiple mPIPE shims in tilegx network driver)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/tile/tilegx.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index 907b577..5d2a719 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -1510,8 +1510,10 @@ static int tile_net_open(struct net_device *dev)
 
 	/* Get the instance info. */
 	rc = gxio_mpipe_link_instance(dev->name);
-	if (rc < 0 || rc >= NR_MPIPE_MAX)
+	if (rc < 0 || rc >= NR_MPIPE_MAX) {
+		mutex_unlock(&tile_net_devs_for_channel_mutex);
 		return -EIO;
+	}
 
 	priv->instance = rc;
 	instance = rc;
