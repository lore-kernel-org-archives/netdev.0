From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net] net/mlx4_core: Allow not to specify probe_vf in SRIOV IB mode
Date: Tue, 23 Sep 2014 16:05:59 +0300
Message-ID: <1411477559-22155-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Matan Barak <matanb@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40922 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751601AbaIWNGG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2014 09:06:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matan Barak <matanb@mellanox.com>

When the HCA is configured in SRIOV IB mode (that is, at least one of
the ports is IB) and the probe_vf module param isn't specified,
mlx4_init_one() failed because of the following condition:

if (ib_ports && (num_vfs_argc > 1 || probe_vfs_argc > 1)) {
	 .....
}

The root cause for that is a mistake in the initialization of num_vfs_argc
and probe_vfs_argc. When num_vfs / probe_vf aren't given, their argument
count counterpart should be 0, fix that.

Fixes: dd41cc3bb90e ('net/mlx4: Adapt num_vfs/probed_vf params for single port VF')
Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---

Hi Dave, 

This bug was introduced in 3.16, can you please push this patch along 
with commit a91c772fa0275 "net/mlx4: Correctly configure single ported 
VFs from the host" to 3.16-stable

Or.

 drivers/net/ethernet/mellanox/mlx4/main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 7e2d5d5..871e3a5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -78,13 +78,13 @@ MODULE_PARM_DESC(msi_x, "attempt to use MSI-X if nonzero");
 #endif /* CONFIG_PCI_MSI */
 
 static uint8_t num_vfs[3] = {0, 0, 0};
-static int num_vfs_argc = 3;
+static int num_vfs_argc;
 module_param_array(num_vfs, byte , &num_vfs_argc, 0444);
 MODULE_PARM_DESC(num_vfs, "enable #num_vfs functions if num_vfs > 0\n"
 			  "num_vfs=port1,port2,port1+2");
 
 static uint8_t probe_vf[3] = {0, 0, 0};
-static int probe_vfs_argc = 3;
+static int probe_vfs_argc;
 module_param_array(probe_vf, byte, &probe_vfs_argc, 0444);
 MODULE_PARM_DESC(probe_vf, "number of vfs to probe by pf driver (num_vfs > 0)\n"
 			   "probe_vf=port1,port2,port1+2");
-- 
1.7.1
