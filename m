From: Jonas Jensen <jonas.jensen@gmail.com>
Subject: [PATCH v3 7/7] net: moxa: use eth_mac_addr()
Date: Mon, 20 Jan 2014 12:13:19 +0100
Message-ID: <1390216399-27028-7-git-send-email-jonas.jensen@gmail.com>
References: <1390216399-27028-1-git-send-email-jonas.jensen@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, f.fainelli@gmail.com,
	bhutchings@solarflare.com, Jonas Jensen <jonas.jensen@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1390216399-27028-1-git-send-email-jonas.jensen@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace boilerplate in moxart_set_mac_address() with eth_mac_addr().

Signed-off-by: Jonas Jensen <jonas.jensen@gmail.com>
---

Notes:
    Applies to next-20140120

 drivers/net/ethernet/moxa/moxart_ether.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
index 0f25f4dc..8378be9 100644
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
