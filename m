From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 07/14] mlx4_en: Validate port up prior to transmitting
Date: Tue, 24 Aug 2010 16:46:07 +0300
Message-ID: <4C73CD1F.5040800@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<eugenia@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:50108 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755235Ab0HXNqN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Aug 2010 09:46:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We might try to use resources which were not activated.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_tx.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mlx4/en_tx.c b/drivers/net/mlx4/en_tx.c
index 580968f..3deabd1 100644
--- a/drivers/net/mlx4/en_tx.c
+++ b/drivers/net/mlx4/en_tx.c
@@ -612,6 +612,9 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	int lso_header_size;
 	void *fragptr;
 
+	if (!priv->port_up)
+		goto tx_drop;
+
 	real_size = get_real_size(skb, dev, &lso_header_size);
 	if (unlikely(!real_size))
 		goto tx_drop;
-- 
1.6.1.3


