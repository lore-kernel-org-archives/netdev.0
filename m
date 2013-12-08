From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 09/12] net/mlx4_en: Ignore irrelevant hypervisor events
Date: Sun,  8 Dec 2013 14:35:49 +0200
Message-ID: <1386506152-10298-10-git-send-email-amirv@mellanox.com>
References: <1386506152-10298-1-git-send-email-amirv@mellanox.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	Eugenia Emantayev <eugenia@mellanox.co.il>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40361 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754561Ab3LHMgM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Dec 2013 07:36:12 -0500
In-Reply-To: <1386506152-10298-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.co.il>

MLX4_DEV_EVENT_SLAVE_INIT and MLX4_DEV_EVENT_SLAVE_SHUTDOWN
events used by Hypervisor to inform the PPF IB driver that
IB para-virtualization must be initialized/destroyed for a slave.
If this event is catched by ETH VF annoying but harmless error message
is printed into dmesg. Remove dmesg prints for these events.


Signed-off-by: Eugenia Emantayev <eugenia@mellanox.co.il>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_main.c b/drivers/net/ethernet/mellanox/mlx4/en_main.c
index 0d087b0..725a4e1 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_main.c
@@ -174,6 +174,9 @@ static void mlx4_en_event(struct mlx4_dev *dev, void *endev_ptr,
 		mlx4_err(mdev, "Internal error detected, restarting device\n");
 		break;
 
+	case MLX4_DEV_EVENT_SLAVE_INIT:
+	case MLX4_DEV_EVENT_SLAVE_SHUTDOWN:
+		break;
 	default:
 		if (port < 1 || port > dev->caps.num_ports ||
 		    !mdev->pndev[port])
-- 
1.8.3.4
