From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next v2 01/10] netvsc: fix return value for set_channels
Date: Wed, 26 Jul 2017 16:40:20 -0700
Message-ID: <20170726234029.7342-2-sthemmin@microsoft.com>
References: <20170726234029.7342-1-sthemmin@microsoft.com>
Cc: devel@linuxdriverproject.org, linux-doc@vger.kernel.org,
        netdev@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com,
        corbet@lwn.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:32913 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751466AbdGZXkp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 19:40:45 -0400
Received: by mail-pg0-f45.google.com with SMTP id b8so13649640pgn.0
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2017 16:40:44 -0700 (PDT)
In-Reply-To: <20170726234029.7342-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The error and normal case got swapped.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 262486ce8e2a..f1eaf675d2e9 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -758,8 +758,8 @@ static int netvsc_set_channels(struct net_device *net,
 	if (!IS_ERR(nvdev)) {
 		netif_set_real_num_tx_queues(net, nvdev->num_chn);
 		netif_set_real_num_rx_queues(net, nvdev->num_chn);
-		ret = PTR_ERR(nvdev);
 	} else {
+		ret = PTR_ERR(nvdev);
 		device_info.num_chn = orig;
 		rndis_filter_device_add(dev, &device_info);
 	}
-- 
2.11.0
