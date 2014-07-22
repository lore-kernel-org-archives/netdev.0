From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 1/4] net/mlx4_en: current_mac isn't updated in port up
Date: Tue, 22 Jul 2014 15:44:09 +0300
Message-ID: <1406033052-16550-2-git-send-email-amirv@mellanox.com>
References: <1406033052-16550-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:58660 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751595AbaGVMpA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2014 08:45:00 -0400
In-Reply-To: <1406033052-16550-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eyal Perry <eyalpe@mellanox.com>

When port is down dev_addr is changed (e.g. by bonding) but current_mac
is not touched. When port is up again, hash_mac is updated to dev_addr,
but current_mac isn't. This leads to inconsistency between current_mac
and mac_hash. Because of that, mlx4_en_replace_mac() fails to find
current_mac in mac_hash.

Fix is to reset current_mac to dev_addr when port is up - as we do for
mac_hash.

Signed-off-by: Eyal Perry <eyalpe@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 887cf01..82708bd 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -644,6 +644,7 @@ static int mlx4_en_get_qp(struct mlx4_en_priv *priv)
 		goto alloc_err;
 	}
 	memcpy(entry->mac, priv->dev->dev_addr, sizeof(entry->mac));
+	memcpy(priv->current_mac, entry->mac, sizeof(priv->current_mac));
 	entry->reg_id = reg_id;
 
 	hlist_add_head_rcu(&entry->hlist,
-- 
1.8.3.4
