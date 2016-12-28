From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 07/12] net/mlx5: Prevent setting multicast macs for VFs
Date: Wed, 28 Dec 2016 14:58:37 +0200
Message-ID: <1482929922-32626-8-git-send-email-saeedm@mellanox.com>
References: <1482929922-32626-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Mohamad Haj Yahia <mohamad@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:32813 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751611AbcL1M66 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2016 07:58:58 -0500
In-Reply-To: <1482929922-32626-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mohamad Haj Yahia <mohamad@mellanox.com>

Need to check that VF mac address entered by the admin user is either
zero or unicast mac.
Multicast mac addresses are prohibited.

Fixes: 77256579c6b4 ('net/mlx5: E-Switch, Introduce Vport administration functions')
Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index d6807c3..f14d9c9 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -1860,7 +1860,7 @@ int mlx5_eswitch_set_vport_mac(struct mlx5_eswitch *esw,
 
 	if (!ESW_ALLOWED(esw))
 		return -EPERM;
-	if (!LEGAL_VPORT(esw, vport))
+	if (!LEGAL_VPORT(esw, vport) || is_multicast_ether_addr(mac))
 		return -EINVAL;
 
 	mutex_lock(&esw->state_lock);
-- 
2.7.4
