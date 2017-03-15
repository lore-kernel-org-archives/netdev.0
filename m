From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH net] fjes: Fix wrong netdevice feature flags
Date: Wed, 15 Mar 2017 13:47:50 +0900
Message-ID: <1489553270-7754-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: yasu.isimatu@gmail.com, Taku Izumi <izumi.taku@jp.fujitsu.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm03.jp.fujitsu.com ([202.219.69.170]:59256 "EHLO
        mgwkm03.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750819AbdCOFPB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 01:15:01 -0400
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
        by kw-mxauth.gw.nic.fujitsu.com (Postfix) with ESMTP id B94DFAC00DA
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 14:03:31 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes netdev->features for Extended Socket network device.

Currently Extended Socket network device's netdev->feature claims
NETIF_F_HW_CSUM, however this is completely wrong. There's no feature
of checksum offloading.
That causes invalid TCP/UDP checksum and packet rjection when IP
forwarding from Extended Socket network device to other network device.

NETIF_F_HW_CSUM should be omitted.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/fjes_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index b75d9cd..c4b3c4b 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -1316,7 +1316,7 @@ static void fjes_netdev_setup(struct net_device *netdev)
 	netdev->min_mtu = fjes_support_mtu[0];
 	netdev->max_mtu = fjes_support_mtu[3];
 	netdev->flags |= IFF_BROADCAST;
-	netdev->features |= NETIF_F_HW_CSUM | NETIF_F_HW_VLAN_CTAG_FILTER;
+	netdev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
 }
 
 static void fjes_irq_watch_task(struct work_struct *work)
-- 
1.8.3.1
