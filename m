From: Andrew Pilloud <andrewpilloud@igneoussystems.com>
Subject: [PATCH] mvneta: Driver and hardware supports IPv6 offload, so enable it
Date: Fri,  1 Sep 2017 07:49:49 -0700
Message-ID: <20170901144949.13129-1-andrewpilloud@igneoussystems.com>
Cc: netdev@vger.kernel.org,
        Andrew Pilloud <andrewpilloud@igneoussystems.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:36772 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752109AbdIAOt4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 10:49:56 -0400
Received: by mail-pg0-f44.google.com with SMTP id r133so1193334pgr.3
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2017 07:49:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mvneta driver and hardware supports IPv6 offload, however it
isn't enabled. Set the NETIF_F_IPV6_CSUM feature to inform the
network layer that this driver can offload IPV6 TCP and UDP
checksums. This change has been tested on an Armada 370 and the
feature support confirmed with several device datasheets
including the Armada XP and Armada 3700.

Signed-off-by: Andrew Pilloud <andrewpilloud@igneoussystems.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 0aab74c2a209..369ad971b42a 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -4332,7 +4332,7 @@ static int mvneta_probe(struct platform_device *pdev)
 		}
 	}
 
-	dev->features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO;
+	dev->features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | NETIF_F_TSO;
 	dev->hw_features |= dev->features;
 	dev->vlan_features |= dev->features;
 	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
-- 
2.11.0
