From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V2 net-next 0/7] mlx4: Add SRIOV support for RoCE
Date: Wed, 12 Mar 2014 12:00:36 +0200
Message-ID: <1394618443-20337-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, roland@kernel.org,
	jackm@dev.mellanox.co.il, amirv@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:59204 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750981AbaCLKZl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Mar 2014 06:25:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series adds SRIOV support for RoCE (RDMA over Ethernet) to the mlx4 driver.

The patches are against net-next, as of commit 2d8d40a "pkt_sched: fq:
do not hold qdisc lock while allocating memory"

Or.

changes from V1:
 - addressed feedback from Dave on patch #3 and changed get_real_sgid_index()
   to be called fill_in_real_sgid_index() and be a void  function.
 - removed some checkpatch warnings on long lines

changes from V0:
  - always check the return code of mlx4_get_roce_gid_from_slave().
    The call we fixed is introduced in patch #1 and later removed by 
    patch #3 that allows guests to have multiple GIDS. The 1..3 
    separation was done for proper division of patches to logical changes.


Jack Morgenstein (6):
  mlx4: Adjust QP1 multiplexing for RoCE/SRIOV
  mlx4_core: For RoCE, allow slaves to set the GID entry at that
    slave's index
  mlx4: In RoCE allow guests to have multiple GIDS
  mlx4: Add ref counting to port MAC table for RoCE
  mlx4: Implement IP based gids support for RoCE/SRIOV
  mlx4: Activate RoCE/SRIOV

Shani Michaelli (1):
  mlx4_ib: Fix SIDR support of for UD QPs under SRIOV/RoCE

 drivers/infiniband/hw/mlx4/cm.c                    |   80 ++++-
 drivers/infiniband/hw/mlx4/cq.c                    |   42 ++-
 drivers/infiniband/hw/mlx4/mad.c                   |  121 +++++++-
 drivers/infiniband/hw/mlx4/main.c                  |    8 -
 drivers/infiniband/hw/mlx4/mcg.c                   |    5 +-
 drivers/infiniband/hw/mlx4/mlx4_ib.h               |   24 ++-
 drivers/infiniband/hw/mlx4/qp.c                    |  319 ++++++++++++++++----
 drivers/net/ethernet/mellanox/mlx4/cmd.c           |   24 ++
 drivers/net/ethernet/mellanox/mlx4/fw.c            |    5 +-
 drivers/net/ethernet/mellanox/mlx4/main.c          |    6 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |    8 +
 drivers/net/ethernet/mellanox/mlx4/port.c          |  144 +++++++++-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |  146 ++++++++--
 include/linux/mlx4/cmd.h                           |    7 +
 include/linux/mlx4/device.h                        |   11 +-
 15 files changed, 811 insertions(+), 139 deletions(-)
