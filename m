From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net V1 2/6] mlx4: VF is not allowed to perform dump stats
Date: Thu, 19 Jan 2012 21:44:37 +0200
Message-ID: <4F1872A5.5010509@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<eugenia@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:58062 "HELO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932675Ab2ASToo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2012 14:44:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.co.il>

In multifunction mode - DUMP_STATS command is not executed
for VFs.

Signed-off-by: Eugenia Emantayev <eugenia@mellanox.co.il>
Reviewed-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/port.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index 88b52e5..1a551d6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -898,6 +898,8 @@ int mlx4_DUMP_ETH_STATS_wrapper(struct mlx4_dev *dev, int slave,
 				struct mlx4_cmd_mailbox *outbox,
 				struct mlx4_cmd_info *cmd)
 {
+	if (slave != dev->caps.function)
+		return 0;
 	return mlx4_common_dump_eth_stats(dev, slave,
 					  vhcr->in_modifier, outbox);
 }
-- 
1.5.4.3
