From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH 2/9] net: mvneta: Factorize feature setting
Date: Mon, 19 May 2014 13:59:53 -0300
Message-ID: <1400518800-6111-3-git-send-email-ezequiel.garcia@free-electrons.com>
References: <1400518800-6111-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: Willy Tarreau <w@1wt.eu>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:53591 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932566AbaESRA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2014 13:00:58 -0400
In-Reply-To: <1400518800-6111-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to ease the addition of new features, let's factorize the
feature list.

Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index c7cbaf3..ed7f924 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -2896,8 +2896,8 @@ static int mvneta_probe(struct platform_device *pdev)
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
