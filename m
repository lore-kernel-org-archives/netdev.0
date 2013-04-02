From: Yan Burman <yanb@mellanox.com>
Subject: [PATCH net] net/mlx4_en: Fix setting initial MAC address
Date: Tue,  2 Apr 2013 16:49:45 +0300
Message-ID: <1364910585-2963-1-git-send-email-yanb@mellanox.com>
Cc: Yan Burman <yanb@mellanox.com>,
	"Or Gerlitz" <ogerlitz@mellanox.com>,
	"Amir Vadai" <amirv@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:60499 "EHLO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759611Ab3DBONE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 10:13:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 6bbb6d9 "net/mlx4_en: Optimize Rx fast path filter checks" introduced a regression
under which the MAC address read from the card was not converted correctly
(the most significant byte was not handled), fix that.

Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Yan Burman <yanb@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index f278b10..30d78f8 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -411,8 +411,8 @@ static int mlx4_en_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
 
 static void mlx4_en_u64_to_mac(unsigned char dst_mac[ETH_ALEN + 2], u64 src_mac)
 {
-	unsigned int i;
-	for (i = ETH_ALEN - 1; i; --i) {
+	int i;
+	for (i = ETH_ALEN - 1; i >= 0; --i) {
 		dst_mac[i] = src_mac & 0xff;
 		src_mac >>= 8;
 	}
-- 
1.7.10.1
