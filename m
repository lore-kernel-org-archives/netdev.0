From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH for/net-next 0/8] Add Mellanox mlx5 driver for Connect-IB devices
Date: Wed, 26 Jun 2013 17:22:09 +0300
Message-ID: <1372256537-21328-1-git-send-email-ogerlitz@mellanox.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	eli@dev.mellanox.co.il, moshel@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: roland@kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:42740 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752146Ab3FZOWw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jun 2013 10:22:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@mellanox.com>

The patches that follow constitute the driver for Mellanox's 5th generation
of HCAs named Connect-IB.

The driver is comprised of two kernel modules: mlx5_ib and mlx5_core. This
partitioning resembles what we have for mlx4 with the substantial difference
that mlx5_ib is the pci device driver and not mlx5_core.

mlx5_core provides general functionality that is intended to be used by
other Mellanox devices that will be introduced in the future. In this sense,
it can be perceived as a library. mlx5_ib has a similar role as any hardware
device under drivers/infiniband/hw.

The patches are partitioned to avoid exceeding the 100KB vger.kernel.org
limitation. They are divided such that the first three ones have the code
of the mlx5_core driver, and the last five the code of the mlx5_ib driver.

Only the last patch per driver adds the Makefiles and Kconfigs, to make
things robust for future bisections.

PPC is not yet supported but support will be included in the near future.

changes from V0:
 - Per Dave's request, cross posting to both netdev and linux-rdma, to see 
   if there are comments from netdev on the core driver.

Eli Cohen (8):
  net/mlx5: Mellanox Connect-IB, core driver part 1/3
  net/mlx5: Mellanox Connect-IB, core driver part 2/3
  net/mlx5: Mellanox Connect-IB, core driver part 3/3
  IB/mlx5: Mellanox Connect-IB, IB driver part 1/5
  IB/mlx5: Mellanox Connect-IB, IB driver part 2/5
  IB/mlx5: Mellanox Connect-IB, IB driver part 3/5
  IB/mlx5: Mellanox Connect-IB, IB driver part 4/5
  IB/mlx5: Mellanox Connect-IB, IB driver part 5/5

 MAINTAINERS                                        |   22 +
 drivers/infiniband/Kconfig                         |    1 +
 drivers/infiniband/Makefile                        |    1 +
 drivers/infiniband/hw/mlx5/Kconfig                 |   10 +
 drivers/infiniband/hw/mlx5/Makefile                |    4 +
 drivers/infiniband/hw/mlx5/ah.c                    |   95 +
 drivers/infiniband/hw/mlx5/cq.c                    |  851 +++++++
 drivers/infiniband/hw/mlx5/doorbell.c              |  100 +
 drivers/infiniband/hw/mlx5/mad.c                   |  143 ++
 drivers/infiniband/hw/mlx5/main.c                  | 1512 ++++++++++++
 drivers/infiniband/hw/mlx5/mem.c                   |  194 ++
 drivers/infiniband/hw/mlx5/mlx5_ib.h               |  593 +++++
 drivers/infiniband/hw/mlx5/mr.c                    | 1025 ++++++++
 drivers/infiniband/hw/mlx5/qp.c                    | 2549 ++++++++++++++++++++
 drivers/infiniband/hw/mlx5/srq.c                   |  481 ++++
 drivers/infiniband/hw/mlx5/user.h                  |  123 +
 drivers/net/ethernet/mellanox/Kconfig              |    1 +
 drivers/net/ethernet/mellanox/Makefile             |    1 +
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig    |   18 +
 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |    6 +
 drivers/net/ethernet/mellanox/mlx5/core/alloc.c    |  244 ++
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c      | 1497 ++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/cq.c       |  226 ++
 drivers/net/ethernet/mellanox/mlx5/core/debugfs.c  |  600 +++++
 drivers/net/ethernet/mellanox/mlx5/core/eq.c       |  523 ++++
 drivers/net/ethernet/mellanox/mlx5/core/fw.c       |  187 ++
 drivers/net/ethernet/mellanox/mlx5/core/health.c   |  216 ++
 drivers/net/ethernet/mellanox/mlx5/core/mad.c      |   80 +
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |  483 ++++
 drivers/net/ethernet/mellanox/mlx5/core/mcg.c      |  108 +
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |   96 +
 drivers/net/ethernet/mellanox/mlx5/core/mr.c       |  138 ++
 .../net/ethernet/mellanox/mlx5/core/pagealloc.c    |  438 ++++
 drivers/net/ethernet/mellanox/mlx5/core/pd.c       |  103 +
 drivers/net/ethernet/mellanox/mlx5/core/port.c     |  106 +
 drivers/net/ethernet/mellanox/mlx5/core/qp.c       |  303 +++
 drivers/net/ethernet/mellanox/mlx5/core/srq.c      |  225 ++
 drivers/net/ethernet/mellanox/mlx5/core/uar.c      |  225 ++
 include/linux/mlx5/cmd.h                           |   51 +
 include/linux/mlx5/cq.h                            |  166 ++
 include/linux/mlx5/device.h                        |  886 +++++++
 include/linux/mlx5/doorbell.h                      |   81 +
 include/linux/mlx5/driver.h                        |  763 ++++++
 include/linux/mlx5/qp.h                            |  467 ++++
 include/linux/mlx5/srq.h                           |   41 +
 45 files changed, 15983 insertions(+), 0 deletions(-)
 create mode 100644 drivers/infiniband/hw/mlx5/Kconfig
 create mode 100644 drivers/infiniband/hw/mlx5/Makefile
 create mode 100644 drivers/infiniband/hw/mlx5/ah.c
 create mode 100644 drivers/infiniband/hw/mlx5/cq.c
 create mode 100644 drivers/infiniband/hw/mlx5/doorbell.c
 create mode 100644 drivers/infiniband/hw/mlx5/mad.c
 create mode 100644 drivers/infiniband/hw/mlx5/main.c
 create mode 100644 drivers/infiniband/hw/mlx5/mem.c
 create mode 100644 drivers/infiniband/hw/mlx5/mlx5_ib.h
 create mode 100644 drivers/infiniband/hw/mlx5/mr.c
 create mode 100644 drivers/infiniband/hw/mlx5/qp.c
 create mode 100644 drivers/infiniband/hw/mlx5/srq.c
 create mode 100644 drivers/infiniband/hw/mlx5/user.h
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/Kconfig
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/Makefile
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/alloc.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/cmd.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/cq.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/debugfs.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/eq.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/fw.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/health.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/mad.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/main.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/mcg.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/mr.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/pd.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/port.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/qp.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/srq.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/uar.c
 create mode 100644 include/linux/mlx5/cmd.h
 create mode 100644 include/linux/mlx5/cq.h
 create mode 100644 include/linux/mlx5/device.h
 create mode 100644 include/linux/mlx5/doorbell.h
 create mode 100644 include/linux/mlx5/driver.h
 create mode 100644 include/linux/mlx5/qp.h
 create mode 100644 include/linux/mlx5/srq.h
