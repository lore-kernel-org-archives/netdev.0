From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net-next 3/8] net/mlx4: fix sparse warnings on TX blue flame
 buffer
Date: Tue, 6 Mar 2012 16:04:02 +0200
Message-ID: <4F561952.4080001@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:44314 "HELO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1030681Ab2CFOEb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 09:04:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

The blue flame buffer is defined to be of type void __iomem *
but was passed to mlx4_bf_copy which gets unsigned long * .
This triggered sparse warning on different address spaces,
fix that by changing mlx4_bf_copy first param to be of type void __iomem * .

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 008f0af..1796824 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -584,7 +584,7 @@ u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb)
 	return skb_tx_hash(dev, skb);
 }
 
-static void mlx4_bf_copy(unsigned long *dst, unsigned long *src, unsigned bytecnt)
+static void mlx4_bf_copy(void __iomem *dst, unsigned long *src, unsigned bytecnt)
 {
 	__iowrite64_copy(dst, src, bytecnt / 8);
 }
-- 
1.7.7
