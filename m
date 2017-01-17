From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 1/3] net: ethtool: Initialize buffer when querying device channel settings
Date: Tue, 17 Jan 2017 19:19:17 +0200
Message-ID: <1484673559-21687-2-git-send-email-tariqt@mellanox.com>
References: <1484673559-21687-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        "John W. Linville" <linville@tuxdriver.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:58802 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751180AbdAQRT4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 12:19:56 -0500
In-Reply-To: <1484673559-21687-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

Ethtool channels respond struct was uninitialized when querying device
channel boundaries settings. As a result, unreported fields by the driver
hold garbage.  This may cause sending unsupported params to driver.

Fixes: 8bf368620486 ('ethtool: ensure channel counts are within bounds ...')
Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
CC: John W. Linville <linville@tuxdriver.com>
---
 net/core/ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index e23766c7e3ba..236a21e3c878 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1712,7 +1712,7 @@ static noinline_for_stack int ethtool_get_channels(struct net_device *dev,
 static noinline_for_stack int ethtool_set_channels(struct net_device *dev,
 						   void __user *useraddr)
 {
-	struct ethtool_channels channels, max;
+	struct ethtool_channels channels, max = { .cmd = ETHTOOL_GCHANNELS };
 	u32 max_rx_in_use = 0;
 
 	if (!dev->ethtool_ops->set_channels || !dev->ethtool_ops->get_channels)
-- 
1.8.3.1
