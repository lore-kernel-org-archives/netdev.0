From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net] net/mlx4_core: Fix the error flow when probing with invalid VF configuration
Date: Sun, 22 Jun 2014 13:21:34 +0300
Message-ID: <1403432494-20043-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, matanb@mellanox.com,
	jackm@dev.mellanox.co.il, Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:38867 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751390AbaFVKVp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Jun 2014 06:21:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Single ported VF are currently not supported on configurations where
one or both ports are IB. When we hit this case, the relevant flow in
the driver didn't return error and jumped to the wrong label. Fix that.

Fixes: dd41cc3 ('net/mlx4: Adapt num_vfs/probed_vf params for single port VF')
Reported-by: Shirley Ma <shirley.ma@oracle.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---

Dave, 

The bug was introduced in 3.15-rc1, can you please push the 
fix to -stable of 3.15.y?

Thanks,

Or.

 drivers/net/ethernet/mellanox/mlx4/main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 5f42f6d..82ab427 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2439,7 +2439,8 @@ slave_start:
 			    (num_vfs_argc > 1 || probe_vfs_argc > 1)) {
 				mlx4_err(dev,
 					 "Invalid syntax of num_vfs/probe_vfs with IB port - single port VFs syntax is only supported when all ports are configured as ethernet\n");
-				goto err_close;
+				err = -EINVAL;
+				goto err_master_mfunc;
 			}
 			for (i = 0; i < sizeof(nvfs)/sizeof(nvfs[0]); i++) {
 				unsigned j;
-- 
1.7.1
