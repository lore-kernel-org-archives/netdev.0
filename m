From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 1/1] qlge: Bonding fix for mode 6.
Date: Tue, 17 Nov 2009 13:10:40 -0800
Message-ID: <1258492240-24554-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:9445 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750772AbZKQVRR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 16:17:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow MAC address to be changed even if device is not up.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index e2ee47d..7692299 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3951,9 +3951,6 @@ static int qlge_set_mac_address(struct net_device *ndev, void *p)
 	struct sockaddr *addr = p;
 	int status;
 
-	if (netif_running(ndev))
-		return -EBUSY;
-
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 	memcpy(ndev->dev_addr, addr->sa_data, ndev->addr_len);
-- 
1.6.0.2

