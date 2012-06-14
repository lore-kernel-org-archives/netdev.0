From: <sarveshwar.bandi@emulex.com>
Subject: [PATCH 1/3] be2net: reduce gso_max_size setting to account for ethernet header.
Date: Thu, 14 Jun 2012 11:21:43 +0530
Message-ID: <a5935849-a5bc-4876-b632-7a863cd714ab@exht1.ad.emulex.com>
References: <1339653105-7313-1-git-send-email-sarveshwar.bandi@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:51758 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751190Ab2FNFwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2012 01:52:20 -0400
In-Reply-To: <1339653105-7313-1-git-send-email-sarveshwar.bandi@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>

The maximum size of packet that can be handled by controller including ethernet
header is 65535. Reducing gso_max_size accordingly.

Signed-off-by: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 5a34503..cbd245a 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3242,7 +3242,7 @@ static void be_netdev_init(struct net_device *netdev)
 
 	netdev->flags |= IFF_MULTICAST;
 
-	netif_set_gso_max_size(netdev, 65535);
+	netif_set_gso_max_size(netdev, 65535 - ETH_HLEN);
 
 	netdev->netdev_ops = &be_netdev_ops;
 
-- 
1.7.9.5
