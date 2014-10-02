From: Eli Cohen <eli@mellanox.com>
Subject: [PATCH V2 net-next 0/5] mlx5 update for 3.18
Date: Thu,  2 Oct 2014 12:19:41 +0300
Message-ID: <1412241586-10108-1-git-send-email-eli@mellanox.com>
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	yevgenyp@mellanox.com, Eli Cohen <eli@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:58758 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751285AbaJBJT6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2014 05:19:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, 

This series integrates a new mechanism for populating and extracting field values 
used in the driver/firmware interaction around command mailboxes.

Changes from V1:
 - Remove unused definition of memcpy_cpu_to_be32()
 - Remove definitions of non_existent_*() and use BUILD_BUG_ON() instead.
 - Added a patch one line patch to add support for ConnectX-4 devices.

Changes from V0:
 - trimmed the auto-generated file to a minimum, as required by the reviewers.

Eli

Eli Cohen (5):
  net/mlx5_core: Update device capabilities handling
  net/mlx5_core: Use hardware registers description header file
  net/mlx5_core: use set/get macros in device caps
  net/mlx5_core: Identify resources by their type
  net/mlx5_core: Add ConnectX-4 to list of supported devices

 drivers/infiniband/hw/mlx5/cq.c                |   8 +-
 drivers/infiniband/hw/mlx5/mad.c               |   2 +-
 drivers/infiniband/hw/mlx5/main.c              |  83 +++---
 drivers/infiniband/hw/mlx5/qp.c                |  72 +++--
 drivers/infiniband/hw/mlx5/srq.c               |   6 +-
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c  |  77 +++---
 drivers/net/ethernet/mellanox/mlx5/core/eq.c   |  14 +-
 drivers/net/ethernet/mellanox/mlx5/core/fw.c   |  81 +-----
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 230 ++++++++++++----
 drivers/net/ethernet/mellanox/mlx5/core/qp.c   |  60 +++--
 drivers/net/ethernet/mellanox/mlx5/core/uar.c  |   4 +-
 include/linux/mlx5/device.h                    | 152 ++++-------
 include/linux/mlx5/driver.h                    | 118 +++------
 include/linux/mlx5/mlx5_ifc.h                  | 349 +++++++++++++++++++++++++
 include/linux/mlx5/qp.h                        |   3 +-
 15 files changed, 804 insertions(+), 455 deletions(-)
 create mode 100644 include/linux/mlx5/mlx5_ifc.h

-- 
2.1.1
