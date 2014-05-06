From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH v2 8/9] net: mvneta: Factorize feature setting
Date: Tue,  6 May 2014 14:20:57 -0300
Message-ID: <1399396858-14551-9-git-send-email-ezequiel.garcia@free-electrons.com>
References: <1399396858-14551-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	Willy Tarreau <w@1wt.eu>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:53560 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753796AbaEFRWC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 13:22:02 -0400
In-Reply-To: <1399396858-14551-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to ease the addition of new features, let's factorize the
feature list.

Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index ec4f67a..28b0536 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -2872,8 +2872,8 @@ static int mvneta_probe(struct platform_device *pdev)
 	netif_napi_add(dev, &pp->napi, mvneta_poll, pp->weight);
 
 	dev->features = NETIF_F_SG | NETIF_F_IP_CSUM;
-	dev->hw_features |= NETIF_F_SG | NETIF_F_IP_CSUM;
-	dev->vlan_features |= NETIF_F_SG | NETIF_F_IP_CSUM;
+	dev->hw_features |= dev->features;
+	dev->vlan_features |= dev->features;
 	dev->priv_flags |= IFF_UNICAST_FLT;
 
 	err = register_netdev(dev);
-- 
1.9.1
