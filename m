From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 00/13] mlx4 driver update (+ new VF ndo)
Date: Wed, 10 Jun 2015 17:59:25 +0300
Message-ID: <1433948378-17570-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:37755 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933489AbbFJPAH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jun 2015 11:00:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series from Eran and Hadar is further dealing with traffic 
counters in the mlx4 driver, this time mostly around SRIOV.

We added a new ndo to read the VF counters through the PF netdev 
netlink infrastructure plus mlx4 implementation for that ndo.

Or.

Eran Ben Elisha (13):
  net/mlx4_core: Check before cleaning counters bitmap
  net/mlx4_core: Reset counters data when freed
  net/mlx4_core: Add sink counter
  net/mlx4_core: Remove counters table allocation from VF flow
  net/mlx4_core: Adjust counter grant policy in the resource tracker
  net/mlx4_core: Add port attribute when tracking counters
  net/mlx4_core: Allocate default counter per port
  IB/mlx4: Add RoCE/IB dedicated counters
  IB/mlx4: Set VF to read from QP counters
  net/mlx4_core: Add helper to query counters
  net/mlx4_en: Show PF own statistics via ethtool
  net/core: Add reading VF statistics through the PF netdevice
  net/mlx4_en: Support ndo_get_vf_stats

 drivers/infiniband/hw/mlx4/mad.c                   |   38 ++---
 drivers/infiniband/hw/mlx4/main.c                  |   43 ++++--
 drivers/infiniband/hw/mlx4/mlx4_ib.h               |    7 +-
 drivers/infiniband/hw/mlx4/qp.c                    |    7 +-
 drivers/net/ethernet/mellanox/mlx4/cmd.c           |   86 ++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c    |   17 ++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |   23 +++-
 drivers/net/ethernet/mellanox/mlx4/en_port.c       |   24 +++-
 drivers/net/ethernet/mellanox/mlx4/en_resources.c  |    2 +-
 drivers/net/ethernet/mellanox/mlx4/main.c          |  134 ++++++++++++++--
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |    5 +
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h       |    2 +
 drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h    |   11 +-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |  173 +++++++++++++++++++-
 include/linux/mlx4/cmd.h                           |    6 +
 include/linux/mlx4/device.h                        |   10 +
 include/linux/netdevice.h                          |    4 +
 include/uapi/linux/if_link.h                       |   11 ++
 net/core/rtnetlink.c                               |   12 +-
 19 files changed, 545 insertions(+), 70 deletions(-)
