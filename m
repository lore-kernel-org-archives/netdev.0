From: Jonas Jensen <jonas.jensen@gmail.com>
Subject: [PATCH 5/5] net: MOXA ART: use eth_mac_addr()
Date: Fri, 22 Nov 2013 15:57:22 +0100
Message-ID: <1385132242-3204-5-git-send-email-jonas.jensen@gmail.com>
References: <1385132242-3204-1-git-send-email-jonas.jensen@gmail.com>
Cc: davem@davemloft.net, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, Jonas Jensen <jonas.jensen@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:41559 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932078Ab3KVO5s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Nov 2013 09:57:48 -0500
In-Reply-To: <1385132242-3204-1-git-send-email-jonas.jensen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace boilerplate in moxart_set_mac_address() with eth_mac_addr().

Signed-off-by: Jonas Jensen <jonas.jensen@gmail.com>
---

Notes:
    Applies to next-20131122

 drivers/net/ethernet/moxa/moxart_ether.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
index c02075a..9a11d34 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.c
+++ b/drivers/net/ethernet/moxa/moxart_ether.c
@@ -56,12 +56,7 @@ static void moxart_update_mac_address(struct net_device *ndev)
 
 static int moxart_set_mac_address(struct net_device *ndev, void *addr)
 {
-	struct sockaddr *address = addr;
-
-	if (!is_valid_ether_addr(address->sa_data))
-		return -EADDRNOTAVAIL;
-
-	memcpy(ndev->dev_addr, address->sa_data, ndev->addr_len);
+	eth_mac_addr(ndev, addr);
 	moxart_update_mac_address(ndev);
 
 	return 0;
-- 
1.8.2.1
