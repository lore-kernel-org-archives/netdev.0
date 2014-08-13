From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH net-next 00/10] IB core and mlx5 changes
Date: Wed, 13 Aug 2014 14:39:01 +0300
Message-ID: <1407929951-16362-1-git-send-email-eli@mellanox.com>
Cc: netdev@vger.kernel.org, rdma@vger.kernel.org, amirv@mellanox.com,
	yevgenyp@mellanox.com, Eli Cohen <eli@mellanox.com>
To: roland@kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:48707 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751843AbaHMLj3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 07:39:29 -0400
Received: by mail-wg0-f50.google.com with SMTP id n12so10896180wgh.21
        for <netdev@vger.kernel.org>; Wed, 13 Aug 2014 04:39:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Roland and Dave,
Following are patches that extend IB verbs to support extended capabilities and
extended atomic operations which further extend the operations introduced for
ConnectX. There are also some bug fixes and also first introduction to using a
set of macros to set/get values from command mailboxes based on a special
header file that describes hardware registers layout.

I am sending to net-next since these patches heavily depend on commit
9603b61de1eee ("mlx5: Move pci device handling from mlx5_ib to mlx5_core")
which is available in net-next but not yet in ib-next.

Eli Cohen (10):
  IB/core: Add support for extended query device caps
  IB/mlx5: Add support for extended query device
  mlx5: Use hardware registers description header file
  IB/mlx5: Remove duplicate code from mlx5_set_path
  IB/core: Define big endian response for atomic operations
  IB/mlx5: Add extended atomic support
  IB/mlx4: Add extended atomic support
  IB/mlx5: Clear umr resources after ib_unregister_device
  IB/mlx5: Improve debug prints in mlx5_ib_reg_user_mr
  IB/core: Avoid leakage from kernel to user space

 drivers/infiniband/core/uverbs.h               |    1 +
 drivers/infiniband/core/uverbs_cmd.c           |  142 +-
 drivers/infiniband/core/uverbs_main.c          |    4 +-
 drivers/infiniband/hw/mlx4/main.c              |    3 +
 drivers/infiniband/hw/mlx5/cq.c                |    8 +-
 drivers/infiniband/hw/mlx5/mad.c               |    2 +-
 drivers/infiniband/hw/mlx5/main.c              |  154 +-
 drivers/infiniband/hw/mlx5/mr.c                |    6 +-
 drivers/infiniband/hw/mlx5/qp.c                |  115 +-
 drivers/infiniband/hw/mlx5/srq.c               |    6 +-
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c  |   35 +
 drivers/net/ethernet/mellanox/mlx5/core/eq.c   |    2 +-
 drivers/net/ethernet/mellanox/mlx5/core/fw.c   |  102 +-
 drivers/net/ethernet/mellanox/mlx5/core/main.c |  199 +-
 drivers/net/ethernet/mellanox/mlx5/core/uar.c  |    4 +-
 include/linux/mlx5/device.h                    |   99 +-
 include/linux/mlx5/driver.h                    |   85 +-
 include/linux/mlx5/mlx5_ifc.h                  | 4389 ++++++++++++++++++++++++
 include/rdma/ib_verbs.h                        |   10 +-
 include/uapi/rdma/ib_user_verbs.h              |   64 +-
 20 files changed, 5147 insertions(+), 283 deletions(-)
 create mode 100644 include/linux/mlx5/mlx5_ifc.h

-- 
1.9.3
