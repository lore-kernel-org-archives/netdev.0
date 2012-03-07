From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net] mlx4_core: fix bug in modify_cq wrapper for resize flow.
Date: Wed, 7 Mar 2012 17:56:35 +0200
Message-ID: <4F578533.3090405@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<jackm@dev.mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:44007 "HELO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757605Ab2CGP4l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2012 10:56:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

The actual FW command is called in procedure "handle_resize".
Code incorrectly invoked the FW command again (in good flow), in
the modify_cq wrapper function.

Fix by skipping second FW invocation unconditionally for resize.

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
---
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index bfdb7af..8752e6e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -2255,8 +2255,7 @@ int mlx4_MODIFY_CQ_wrapper(struct mlx4_dev *dev, int slave,
 
 	if (vhcr->op_modifier == 0) {
 		err = handle_resize(dev, slave, vhcr, inbox, outbox, cmd, cq);
-		if (err)
-			goto ex_put;
+		goto ex_put;
 	}
 
 	err = mlx4_DMA_wrapper(dev, slave, vhcr, inbox, outbox, cmd);
-- 
1.7.7
