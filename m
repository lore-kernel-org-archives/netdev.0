From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH net-next 00/16] mlx5 batch of patches for net-next
Date: Thu,  2 Apr 2015 17:07:18 +0300
Message-ID: <1427983654-971-1-git-send-email-eli@mellanox.com>
Cc: netdev@vger.kernel.org, idos@mellaox.com, amirv@mellanox.com,
	Eli Cohen <eli@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:35118 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752093AbbDBOHj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 10:07:39 -0400
Received: by widdi4 with SMTP id di4so80033850wid.0
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2015 07:07:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series contains small fixes to the mlx5 core driver and also 
preparation steps towards adding Ethernet support for ConnectX4 
devices which will be part of mlx5 driver.

Eli

Achiad Shochat (3):
  net/mlx5_core: Use the right inbox struct in destroy mkey command
  net/mlx5_core: Fix a bug in alloc_token
  net/mlx5_core: Update module info macros for ConnectX4 Support

Eli Cohen (5):
  net/mlx5_core: Allocate firmware pages from device's NUMA node
  net/mlx5_core: Coding style fix
  net/mlx5_core: Avoid setting DC requestor/responder resources
  net/mlx5_core: Use coherent memory for command interface page
  net/mlx5_core: Avoid copying outbox in aysnc command completion

Haggai Abramonvsky (1):
  net/mlx5_core: Fix call to mlx5_core_qp_modify

Ira Gusinsky (1):
  net/mlx5_core: Avoid usage command work entry after writing command
    doorbell

Saeed Mahameed (6):
  net/mlx5_core: Clear doorbell record inside mlx5_db_alloc()
  net/mlx5_core: Fix Mellanox copyright note
  IB/mlx5: Fix Mellanox copyright note
  net/mlx5_core: Move completion eqs from mlx5_ib to mlx5_core
  net/mlx5_core: Modify arm CQ in preparation for upcoming Ethernet
    driver
  net/mlx5_core: Extend struct mlx5_interface to support multiple
    protocols

 drivers/infiniband/hw/mlx5/ah.c                    |   2 +-
 drivers/infiniband/hw/mlx5/cq.c                    |  14 ++-
 drivers/infiniband/hw/mlx5/doorbell.c              |   2 +-
 drivers/infiniband/hw/mlx5/mad.c                   |   2 +-
 drivers/infiniband/hw/mlx5/main.c                  | 107 +-----------------
 drivers/infiniband/hw/mlx5/mem.c                   |   2 +-
 drivers/infiniband/hw/mlx5/mlx5_ib.h               |   5 +-
 drivers/infiniband/hw/mlx5/mr.c                    |   2 +-
 drivers/infiniband/hw/mlx5/odp.c                   |   2 +-
 drivers/infiniband/hw/mlx5/qp.c                    |   8 +-
 drivers/infiniband/hw/mlx5/srq.c                   |   4 +-
 drivers/infiniband/hw/mlx5/user.h                  |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/alloc.c    |   5 +-
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c      |  85 +++++++++-----
 drivers/net/ethernet/mellanox/mlx5/core/cq.c       |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/debugfs.c  |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/eq.c       |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/fw.c       |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/health.c   |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/mad.c      |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/main.c     | 123 ++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/mcg.c      |   2 +-
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/mr.c       |   4 +-
 .../net/ethernet/mellanox/mlx5/core/pagealloc.c    |   5 +-
 drivers/net/ethernet/mellanox/mlx5/core/pd.c       |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/port.c     |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/qp.c       |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/srq.c      |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/uar.c      |   2 +-
 include/linux/mlx5/cmd.h                           |   2 +-
 include/linux/mlx5/cq.h                            |   7 +-
 include/linux/mlx5/device.h                        |   2 +-
 include/linux/mlx5/doorbell.h                      |   2 +-
 include/linux/mlx5/driver.h                        |  16 ++-
 include/linux/mlx5/mlx5_ifc.h                      |   2 +-
 include/linux/mlx5/qp.h                            |   2 +-
 include/linux/mlx5/srq.h                           |   2 +-
 38 files changed, 247 insertions(+), 188 deletions(-)

-- 
2.3.1
