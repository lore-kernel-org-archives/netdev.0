From: Joerg Roedel <joerg.roedel@amd.com>
Subject: [PATCH] mlx4: Fix compile error when driver is comiled-in
Date: Thu, 15 Dec 2011 17:48:37 +0100
Message-ID: <20111215164837.GE2112@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>
To: "David S. Miller" <davem@davemloft.net>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Testing my iommu-configs against linux-next found a compile error for
allyesconfig. It only happens when the mlx4 driver is compiled into the
kernel and not as a module because these two static functions are also
used in another file. The attached patch fixes it.

>From b993c4448c2ce5447fd24e7d4fce02e633d3222e Mon Sep 17 00:00:00 2001
From: Joerg Roedel <joerg.roedel@amd.com>
Date: Thu, 15 Dec 2011 17:30:33 +0100
Subject: [PATCH 1/2] mlx4: Fix compile error when driver is comiled-in

This patch fixes a compile error that occurs when the driver
is compile into the kernel and not as a module.

Signed-off-by: Joerg Roedel <joerg.roedel@amd.com>
---
 drivers/net/ethernet/mellanox/mlx4/port.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index 00a9547..88b52e5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -783,7 +783,7 @@ int mlx4_SET_PORT(struct mlx4_dev *dev, u8 port)
 	return err;
 }
 
-static int mlx4_SET_PORT_general(struct mlx4_dev *dev, u8 port, int mtu,
+int mlx4_SET_PORT_general(struct mlx4_dev *dev, u8 port, int mtu,
 			  u8 pptx, u8 pfctx, u8 pprx, u8 pfcrx)
 {
 	struct mlx4_cmd_mailbox *mailbox;
@@ -813,7 +813,7 @@ static int mlx4_SET_PORT_general(struct mlx4_dev *dev, u8 port, int mtu,
 }
 EXPORT_SYMBOL(mlx4_SET_PORT_general);
 
-static int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
+int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
 			   u8 promisc)
 {
 	struct mlx4_cmd_mailbox *mailbox;
-- 
1.7.5.4


-- 
AMD Operating System Research Center

Advanced Micro Devices GmbH Einsteinring 24 85609 Dornach
General Managers: Alberto Bozzo, Andrew Bowd
Registration: Dornach, Landkr. Muenchen; Registerger. Muenchen, HRB Nr. 43632
