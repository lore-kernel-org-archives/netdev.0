From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 3/3] net/mlx4_en: set correct MTU in SRIOV
Date: Thu, 11 Apr 2013 14:56:42 +0300
Message-ID: <1365681402-19445-4-git-send-email-amirv@mellanox.com>
References: <1365681402-19445-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.co.il>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:44044 "EHLO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933510Ab3DKMAL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 08:00:11 -0400
In-Reply-To: <1365681402-19445-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.co.il>

When setting MTU in SRIOV mode add ETH, VLAN and FCS header length
to the maximum MTU obtained from QUERY_DEV_CAP.

Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/port.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index 10c57c8..4b6aad3 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -32,6 +32,7 @@
 
 #include <linux/errno.h>
 #include <linux/if_ether.h>
+#include <linux/if_vlan.h>
 #include <linux/export.h>
 
 #include <linux/mlx4/cmd.h>
@@ -517,7 +518,8 @@ static int mlx4_common_set_port(struct mlx4_dev *dev, int slave, u32 in_mod,
 			/* Mtu is configured as the max MTU among all the
 			 * the functions on the port. */
 			mtu = be16_to_cpu(gen_context->mtu);
-			mtu = min_t(int, mtu, dev->caps.eth_mtu_cap[port]);
+			mtu = min_t(int, mtu, dev->caps.eth_mtu_cap[port] +
+				    ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN);
 			prev_mtu = slave_st->mtu[port];
 			slave_st->mtu[port] = mtu;
 			if (mtu > master->max_mtu[port])
-- 
1.7.8.2
