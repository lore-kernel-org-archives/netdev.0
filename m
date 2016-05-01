From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 0/4] Mellanox 100G mlx5 fixes for 4.6-rc
Date: Sun,  1 May 2016 22:59:53 +0300
Message-ID: <1462132797-22853-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:55759 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752080AbcEAUCH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 May 2016 16:02:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This small series provides some bug fixes for mlx5 driver.
 
A small bug fix for iounmap of a null pointer, which dumps a warning on some archs.

One patch to fix the VXLAN/MLX5_EN dependency issue reported by Arnd.

Two patches to fix the scheduling while atomic issue for ndo_add/del_vxlan_port 
NDOs.  The first will add an internal mlx5e workqueue and the second will 
delegate vxlan ports add/del requests to that workqueue.

Note: ('net/mlx5: Kconfig: Fix MLX5_EN/VXLAN build issue') is only needed for net 
and not net-next as the issue was globally fixed for all device drivers by:
b7aade15485a ('vxlan: break dependency with netdev drivers') in net-next.

Applied on top: f27337e16f2d ('ip_tunnel: fix preempt warning in ip tunnel creation/updating')

Gal Pressman (1):
  net/mlx5: Unmap only the relevant IO memory mapping

Matthew Finlay (3):
  net/mlx5: Kconfig: Fix MLX5_EN/VXLAN build issue
  net/mlx5e: Implement a mlx5e workqueue
  net/mlx5e: Use workqueue for vxlan ops

 drivers/net/ethernet/mellanox/mlx5/core/Kconfig   |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 34 +++++++++------
 drivers/net/ethernet/mellanox/mlx5/core/uar.c     |  6 ++-
 drivers/net/ethernet/mellanox/mlx5/core/vxlan.c   | 50 +++++++++++++++++------
 drivers/net/ethernet/mellanox/mlx5/core/vxlan.h   | 11 ++++-
 6 files changed, 74 insertions(+), 29 deletions(-)

-- 
2.8.0
