From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [pull request][for-next 0/6] Mellanox mlx5 updates 2017-05-23
Date: Tue, 23 May 2017 14:43:58 +0300
Message-ID: <20170523114404.20387-1-saeedm@mellanox.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Ilan Tayari <ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave and Doug,

This series introduces some small updates and FPGA support to the mlx5
core/ethernet and IB drivers.

For more details please see below.

Please pull and let me know if there's any problem.

Thanks,
Saeed.

---

The following changes since commit 2ea659a9ef488125eb46da6eb571de5eae5c43f6:

  Linux 4.12-rc1 (2017-05-13 13:19:49 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mellanox/linux.git tags/mlx5-update-2017-05-23

for you to fetch changes up to b359911d6608bd16888466184e8e8faeb63bd9eb:

  IB/mlx5: Bump driver version (2017-05-14 14:24:19 +0300)

----------------------------------------------------------------
mlx5-update-2017-05-23

First patch from Leon, came to remove the redundant usage of mlx5_vzalloc,
and directly use kvzalloc across all mlx5 drivers.

2nd patch from Noa, adds new device IDs into the supported devices list.

3rd and 4th patches from Ilan are adding the basic infrastructure and
support for Mellanox's mlx5 FPGA.

Last two patches from Tariq came to modify the outdated driver version
reported in ethtool and in mlx5_ib to more reflect the current driver state
and remove the redundant date string reported in the version.

Thanks,
Saeed.

----------------------------------------------------------------
Ilan Tayari (2):
      net/mlx5: Introduce trigger_health_work function
      net/mlx5: FPGA, Add basic support for Innova

Leon Romanovsky (1):
      {net, IB}/mlx5: Replace mlx5_vzalloc with kvzalloc

Noa Osherovich (1):
      net/mlx5: Update the list of the PCI supported devices

Tariq Toukan (2):
      net/mlx5: Bump driver version
      IB/mlx5: Bump driver version

 MAINTAINERS                                        |  10 +
 drivers/infiniband/hw/mlx5/cq.c                    |   6 +-
 drivers/infiniband/hw/mlx5/mad.c                   |   4 +-
 drivers/infiniband/hw/mlx5/main.c                  |  11 +-
 drivers/infiniband/hw/mlx5/mr.c                    |   2 +-
 drivers/infiniband/hw/mlx5/qp.c                    |  32 ++--
 drivers/infiniband/hw/mlx5/srq.c                   |   4 +-
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig    |  10 +
 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |   3 +
 drivers/net/ethernet/mellanox/mlx5/core/debugfs.c  |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c  |   8 +-
 .../net/ethernet/mellanox/mlx5/core/en_common.c    |   4 +-
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |   4 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c    |  24 +--
 .../ethernet/mellanox/mlx5/core/en_fs_ethtool.c    |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  33 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/eq.c       |  13 +-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  |  24 +--
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c |  13 +-
 drivers/net/ethernet/mellanox/mlx5/core/fpga/cmd.c |  64 +++++++
 drivers/net/ethernet/mellanox/mlx5/core/fpga/cmd.h |  59 ++++++
 .../net/ethernet/mellanox/mlx5/core/fpga/core.c    | 202 +++++++++++++++++++++
 .../net/ethernet/mellanox/mlx5/core/fpga/core.h    |  99 ++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c   |   6 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  |  10 +-
 drivers/net/ethernet/mellanox/mlx5/core/health.c   |  32 ++--
 drivers/net/ethernet/mellanox/mlx5/core/ipoib.c    |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |  21 ++-
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |   3 +-
 .../net/ethernet/mellanox/mlx5/core/pagealloc.c    |   4 +-
 drivers/net/ethernet/mellanox/mlx5/core/port.c     |   6 +-
 drivers/net/ethernet/mellanox/mlx5/core/qp.c       |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/srq.c      |  14 +-
 drivers/net/ethernet/mellanox/mlx5/core/transobj.c |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/vport.c    |  34 ++--
 include/linux/mlx5/device.h                        |   6 +
 include/linux/mlx5/driver.h                        |  11 +-
 include/linux/mlx5/mlx5_ifc.h                      |  11 +-
 include/linux/mlx5/mlx5_ifc_fpga.h                 | 144 +++++++++++++++
 40 files changed, 779 insertions(+), 164 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/fpga/cmd.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/fpga/cmd.h
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/fpga/core.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/fpga/core.h
 create mode 100644 include/linux/mlx5/mlx5_ifc_fpga.h
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
