From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 0/4] mlx4 driver update, May 28, 2015
Date: Thu, 28 May 2015 18:41:12 +0300
Message-ID: <1432827676-5599-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:57603 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751815AbbE1Plk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 11:41:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

The 1st patch fixes an issue with a function running DPDK overriding 
broadcast steering rules set by other functions. Please add
this one to your -stable queue.

The rest of the series from Matan and Ido deals with scaling the number 
of IRQs that serve RoCE applications to be in par with the Ethernet driver.

Or.

Ido Shamay (1):
  net/mlx4_core: Move affinity hints to mlx4_core ownership

Matan Barak (3):
  net/mlx4_core: Demote simple multicast and broadcast flow steering rules
  net/mlx4: Add EQ pool
  net/mlx4_core: Make sure there are no pending async events when freeing CQ

 drivers/infiniband/hw/mlx4/main.c                  |   75 ++---
 drivers/infiniband/hw/mlx4/mlx4_ib.h               |    1 -
 drivers/net/ethernet/mellanox/mlx4/cq.c            |   14 +-
 drivers/net/ethernet/mellanox/mlx4/en_cq.c         |   56 ++--
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |    7 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c         |   13 +-
 drivers/net/ethernet/mellanox/mlx4/eq.c            |  374 ++++++++++++--------
 drivers/net/ethernet/mellanox/mlx4/main.c          |  110 +++++-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |   12 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h       |    2 +-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   23 ++
 include/linux/mlx4/device.h                        |   11 +-
 12 files changed, 429 insertions(+), 269 deletions(-)
