From: Guillaume Chazarain <guichaz@gmail.com>
Subject: [PATCH 1/2] skge: Remove tx queue stopping in skge_devinit()
Date: Sat,  6 Nov 2010 17:39:31 +0100
Message-ID: <1289061572-5029-1-git-send-email-guichaz@gmail.com>
Cc: Guillaume Chazarain <guichaz@gmail.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41397 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753897Ab0KFQjy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Nov 2010 12:39:54 -0400
Received: by wyb36 with SMTP id 36so2096349wyb.19
        for <netdev@vger.kernel.org>; Sat, 06 Nov 2010 09:39:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After e6484930d7c73d324bccda7d43d131088da697b9: net: allocate tx queues in register_netdevice
It causes an Oops at skge_probe() time.

Signed-off-by: Guillaume Chazarain <guichaz@gmail.com>
---
 drivers/net/skge.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index bfec2e0..220e039 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -3858,7 +3858,6 @@ static struct net_device *skge_devinit(struct skge_hw *hw, int port,
 
 	/* device is off until link detection */
 	netif_carrier_off(dev);
-	netif_stop_queue(dev);
 
 	return dev;
 }
-- 
1.7.1

