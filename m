From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: [PATCH net-next] sunvnet: restrict advertized checksum offloads to just IP
Date: Wed, 14 Jun 2017 15:43:37 -0700
Message-ID: <1497480217-391315-1-git-send-email-shannon.nelson@oracle.com>
Cc: sparclinux@vger.kernel.org,
        Shannon Nelson <shannon.nelson@oracle.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:44676 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751600AbdFNWpI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 18:45:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As much as we'd like to play well with others, we really aren't
handling the checksums on non-IP protocol packets very well.  This
is easily seen when trying to do TCP over ipv6 - the checksums are
garbage.

Here we restrict the checksum feature flag to just IP traffic so
that we aren't given work we can't yet do.

Orabug: 26175391, 26259755

Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
---
 drivers/net/ethernet/sun/ldmvsw.c  |    2 +-
 drivers/net/ethernet/sun/sunvnet.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sun/ldmvsw.c b/drivers/net/ethernet/sun/ldmvsw.c
index 5b56c24..8603e39 100644
--- a/drivers/net/ethernet/sun/ldmvsw.c
+++ b/drivers/net/ethernet/sun/ldmvsw.c
@@ -248,7 +248,7 @@ static void vsw_poll_controller(struct net_device *dev)
 	dev->ethtool_ops = &vsw_ethtool_ops;
 	dev->watchdog_timeo = VSW_TX_TIMEOUT;
 
-	dev->hw_features = NETIF_F_HW_CSUM | NETIF_F_SG;
+	dev->hw_features = NETIF_F_IP_CSUM | NETIF_F_SG;
 	dev->features = dev->hw_features;
 
 	/* MTU range: 68 - 65535 */
diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 0b95105..75b167e 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -312,7 +312,7 @@ static void vnet_poll_controller(struct net_device *dev)
 	dev->watchdog_timeo = VNET_TX_TIMEOUT;
 
 	dev->hw_features = NETIF_F_TSO | NETIF_F_GSO | NETIF_F_GSO_SOFTWARE |
-			   NETIF_F_HW_CSUM | NETIF_F_SG;
+			   NETIF_F_IP_CSUM | NETIF_F_SG;
 	dev->features = dev->hw_features;
 
 	/* MTU range: 68 - 65535 */
-- 
1.7.1
