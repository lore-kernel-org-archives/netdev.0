From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 1/5] net/mlx4_core: Fix wrong mask applied on EQ numbers in the wrapper
Date: Thu, 21 Mar 2013 17:55:51 +0200
Message-ID: <1363881355-21137-2-git-send-email-ogerlitz@mellanox.com>
References: <1363881355-21137-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	jackm@dev.mellanox.co.il, hadarh@mellanox.com,
	Moshe Lazer <moshel@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:58807 "EHLO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755950Ab3CUP4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 11:56:05 -0400
In-Reply-To: <1363881355-21137-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Moshe Lazer <moshel@mellanox.com>

Currently the  mask is wrongly set in the MAP_EQ wrapper, fix that.
Without the fix any EQ number above 511 is mapped to one below 511.

Signed-off-by: Moshe Lazer <moshel@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/eq.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index 251ae2f..8e3123a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -771,7 +771,7 @@ int mlx4_MAP_EQ_wrapper(struct mlx4_dev *dev, int slave,
 	struct mlx4_slave_event_eq_info *event_eq =
 		priv->mfunc.master.slave_state[slave].event_eq;
 	u32 in_modifier = vhcr->in_modifier;
-	u32 eqn = in_modifier & 0x1FF;
+	u32 eqn = in_modifier & 0x3FF;
 	u64 in_param =  vhcr->in_param;
 	int err = 0;
 	int i;
-- 
1.7.1
