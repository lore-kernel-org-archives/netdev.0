From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [pull request][for-next] Mellanox mlx5 Reorganize core driver directory layout
Date: Thu, 12 Jan 2017 19:22:34 +0200
Message-ID: <1484241755-17603-1-git-send-email-saeedm@mellanox.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave and Doug,

This pull request includes one patch from Leon, this patch as described 
below will change the driver directory structure and layout for better,
logical and modular driver files separation.

This change is important to both rdma and net maintainers in order to 
have smoother management of driver patches for different mlx5 sub modules
and smoother rdma-next vs. net-next features submissions.

Please find more info below -in the tag commit message-,
review and let us know if there's any problem.

This change doesn't introduce any conflicts with the current mlx5
fixes and cleanups posted on 2017-01-10 to net branch, and merge tests
worked flawlessly with no issues.

This is the last pull request meant for both rdma-next and net-next.
Once pulled, this will be the base shared code for both trees.

Thanks,
Saeed and Leon.

The following changes since commit f502d834950a28e02651bb7e2cc7111ddd352644:

  net/mlx5: Activate support for 4K UARs (2017-01-09 20:25:10 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mellanox/linux.git tags/mlx5-dir-layout-reorg

for you to fetch changes up to 8a9a0375cee4888f7d70e651f3e76347c731c51f:

  {net, IB}/mlx5: Reorganize driver file layout (2017-01-11 13:40:43 +0200)

----------------------------------------------------------------
{net, IB}/mlx5: Reorganize driver file layout

    This patch organizes mlx5 driver file layout to better reflect mlx5
    modularity and allow future separation between EN, IB and shared code
    parts.

    The new structure:
     * drivers/net/ethernet/mellanox/mlx5/*       - core HW/PCI driver logic
     * drivers/net/ethernet/mellanox/mlx5/en/*    - ethernet
     * drivers/net/ethernet/mellanox/mlx5/fs/*    - flow steering
     * drivers/net/ethernet/mellanox/mlx5/sriov/* - SR-IOV and E-Switch
     * drivers/net/ethernet/mellanox/mlx5/lib/*   - common mlx5 commands and API library

    In future submissions, we will shrink the "lib" directory to the code
    related to both subsystems only, while IB part will be moved to
    drivers/infiniband/hw/mlx5, and EN will be moved to "en" directory.
    Such separation will make this library (shared) code to be lean and minimal,
    and help avoid future conflicts between IB and net submissions.

    The proposed structure allows us to remove include/linux/mlx5,
    which belongs solely to Mellanox's devices and don't need to
    be exposed in common linux include directory.

    The following change goes together with update of MAINTAINERS file to
    more granular maintainership roles:
     * drivers/net/ethernet/mellanox/mlx5/*       - Saeed, Matan and Leon
     * drivers/net/ethernet/mellanox/mlx5/en/*    - Saeed
     * drivers/net/ethernet/mellanox/mlx5/fs/*    - Saeed, Matan and Leon
     * drivers/net/ethernet/mellanox/mlx5/sriov/* - Saeed
     * drivers/net/ethernet/mellanox/mlx5/lib/*   - Saeed, Matan and Leon
     * include/uapi/rdma/mlx5-abi.h               - Matan and Leon

Thanks,
	Leon Romanovsky.

----------------------------------------------------------------
Leon Romanovsky (1):
      {net, IB}/mlx5: Reorganize driver file layout

 MAINTAINERS                                         | 11 ++++++-----
 drivers/infiniband/hw/mlx5/Makefile                 |  1 +
 drivers/infiniband/hw/mlx5/ib_virt.c                |  2 +-
 drivers/infiniband/hw/mlx5/mad.c                    |  4 ++--
 drivers/infiniband/hw/mlx5/main.c                   |  6 +++---
 drivers/infiniband/hw/mlx5/mlx5_ib.h                | 10 +++++-----
 drivers/infiniband/hw/mlx5/srq.c                    |  4 ++--
 drivers/net/ethernet/mellanox/Kconfig               |  2 +-
 drivers/net/ethernet/mellanox/Makefile              |  2 +-
 .../net/ethernet/mellanox/mlx5/{core => }/Kconfig   |  0
 drivers/net/ethernet/mellanox/mlx5/Makefile         | 21 +++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/{core => }/cmd.c |  5 ++---
 drivers/net/ethernet/mellanox/mlx5/core/Makefile    | 13 -------------
 .../net/ethernet/mellanox/mlx5/{core => }/debugfs.c |  8 ++++----
 drivers/net/ethernet/mellanox/mlx5/{core => }/dev.c |  4 ++--
 .../mellanox/mlx5/{core/en_arfs.c => en/arfs.c}     |  4 ++--
 .../mellanox/mlx5/{core/en_clock.c => en/clock.c}   |  2 +-
 .../mellanox/mlx5/{core/en_common.c => en/common.c} |  2 +-
 .../mellanox/mlx5/{core/en_dcbnl.c => en/dcbnl.c}   |  2 +-
 .../net/ethernet/mellanox/mlx5/{core => en}/en.h    | 18 +++++++++---------
 .../mlx5/{core/en_ethtool.c => en/ethtool.c}        |  2 +-
 .../mellanox/mlx5/{core/en_fs.c => en/fs.c}         |  4 ++--
 .../mlx5/{core/en_fs_ethtool.c => en/fs_ethtool.c}  |  4 ++--
 .../mellanox/mlx5/{core/en_main.c => en/main.c}     | 10 +++++-----
 .../mellanox/mlx5/{core/en_rep.c => en/rep.c}       |  8 ++++----
 .../mellanox/mlx5/{core/en_rx.c => en/rx.c}         |  6 +++---
 .../mellanox/mlx5/{core/en_rx_am.c => en/rx_am.c}   |  2 +-
 .../mlx5/{core/en_selftest.c => en/selftest.c}      |  2 +-
 .../mellanox/mlx5/{core/en_stats.h => en/stats.h}   |  0
 .../mellanox/mlx5/{core/en_tc.c => en/tc.c}         | 12 ++++++------
 .../mellanox/mlx5/{core/en_tc.h => en/tc.h}         |  0
 .../mellanox/mlx5/{core/en_tx.c => en/tx.c}         |  2 +-
 .../mellanox/mlx5/{core/en_txrx.c => en/txrx.c}     |  2 +-
 .../net/ethernet/mellanox/mlx5/{core => en}/vxlan.c |  6 +++---
 .../net/ethernet/mellanox/mlx5/{core => en}/vxlan.h |  4 ++--
 .../net/ethernet/mellanox/mlx5/{core => en}/wq.c    |  6 +++---
 .../net/ethernet/mellanox/mlx5/{core => en}/wq.h    |  2 +-
 drivers/net/ethernet/mellanox/mlx5/{core => }/eq.c  |  8 ++++----
 .../mellanox/mlx5/{core/fs_cmd.c => fs/cmd.c}       | 15 +++++++--------
 .../mellanox/mlx5/{core/fs_cmd.h => fs/cmd.h}       |  0
 .../mellanox/mlx5/{core/fs_core.c => fs/core.c}     |  9 ++++-----
 .../mellanox/mlx5/{core/fs_core.h => fs/core.h}     |  2 +-
 .../mlx5/{core/fs_counters.c => fs/counters.c}      | 10 +++++-----
 .../net/ethernet/mellanox/mlx5/{core => }/health.c  |  6 +++---
 drivers/net/ethernet/mellanox/mlx5/{core => }/lag.c |  6 +++---
 .../ethernet/mellanox/mlx5/{core => lib}/alloc.c    |  5 ++---
 .../net/ethernet/mellanox/mlx5/lib}/cmd.h           |  0
 .../net/ethernet/mellanox/mlx5/{core => lib}/cq.c   |  8 ++++----
 .../net/ethernet/mellanox/mlx5/lib}/cq.h            |  2 +-
 .../net/ethernet/mellanox/mlx5/lib}/device.h        |  2 +-
 .../net/ethernet/mellanox/mlx5/lib}/doorbell.h      |  0
 .../net/ethernet/mellanox/mlx5/lib}/driver.h        |  6 +++---
 .../net/ethernet/mellanox/mlx5/lib}/fs.h            |  4 ++--
 .../net/ethernet/mellanox/mlx5/{core => lib}/fw.c   |  6 +++---
 .../net/ethernet/mellanox/mlx5/{core => lib}/mad.c  |  6 +++---
 .../net/ethernet/mellanox/mlx5/{core => lib}/mcg.c  |  6 +++---
 .../net/ethernet/mellanox/mlx5/lib}/mlx5_ifc.h      |  0
 .../net/ethernet/mellanox/mlx5/{core => lib}/mr.c   |  6 +++---
 .../net/ethernet/mellanox/mlx5/{core => lib}/pd.c   |  6 +++---
 .../net/ethernet/mellanox/mlx5/{core => lib}/port.c |  8 ++++----
 .../net/ethernet/mellanox/mlx5/lib}/port.h          |  2 +-
 .../net/ethernet/mellanox/mlx5/{core => lib}/qp.c   | 11 +++++------
 .../net/ethernet/mellanox/mlx5/lib}/qp.h            |  4 ++--
 .../net/ethernet/mellanox/mlx5/{core => lib}/rl.c   |  6 +++---
 .../net/ethernet/mellanox/mlx5/{core => lib}/srq.c  | 10 +++++-----
 .../net/ethernet/mellanox/mlx5/lib}/srq.h           |  2 +-
 .../ethernet/mellanox/mlx5/{core => lib}/transobj.c |  6 +++---
 .../net/ethernet/mellanox/mlx5/lib}/transobj.h      |  2 +-
 .../net/ethernet/mellanox/mlx5/{core => lib}/uar.c  |  6 +++---
 .../ethernet/mellanox/mlx5/{core => lib}/vport.c    |  6 +++---
 .../net/ethernet/mellanox/mlx5/lib}/vport.h         |  4 ++--
 .../net/ethernet/mellanox/mlx5/{core => }/main.c    | 16 ++++++++--------
 .../mellanox/mlx5/{core/mlx5_core.h => mlx5.h}      |  0
 .../ethernet/mellanox/mlx5/{core => }/pagealloc.c   |  6 +++---
 .../mellanox/mlx5/{core => sriov}/eswitch.c         | 12 ++++++------
 .../mellanox/mlx5/{core => sriov}/eswitch.h         |  2 +-
 .../mlx5/{core => sriov}/eswitch_offloads.c         | 12 ++++++------
 .../ethernet/mellanox/mlx5/{core => sriov}/sriov.c  |  6 +++---
 78 files changed, 216 insertions(+), 211 deletions(-)
 rename drivers/net/ethernet/mellanox/mlx5/{core => }/Kconfig (100%)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/Makefile
 rename drivers/net/ethernet/mellanox/mlx5/{core => }/cmd.c (99%)
 delete mode 100644 drivers/net/ethernet/mellanox/mlx5/core/Makefile
 rename drivers/net/ethernet/mellanox/mlx5/{core => }/debugfs.c (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => }/dev.c (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/en_arfs.c => en/arfs.c} (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/en_clock.c => en/clock.c} (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/en_common.c => en/common.c} (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/en_dcbnl.c => en/dcbnl.c} (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => en}/en.h (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/en_ethtool.c => en/ethtool.c} (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/en_fs.c => en/fs.c} (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/en_fs_ethtool.c => en/fs_ethtool.c} (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/en_main.c => en/main.c} (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/en_rep.c => en/rep.c} (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/en_rx.c => en/rx.c} (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/en_rx_am.c => en/rx_am.c} (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/en_selftest.c => en/selftest.c} (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/en_stats.h => en/stats.h} (100%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/en_tc.c => en/tc.c} (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/en_tc.h => en/tc.h} (100%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/en_tx.c => en/tx.c} (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/en_txrx.c => en/txrx.c} (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => en}/vxlan.c (98%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => en}/vxlan.h (97%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => en}/wq.c (98%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => en}/wq.h (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => }/eq.c (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/fs_cmd.c => fs/cmd.c} (98%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/fs_cmd.h => fs/cmd.h} (100%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/fs_core.c => fs/core.c} (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/fs_core.h => fs/core.h} (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/fs_counters.c => fs/counters.c} (98%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => }/health.c (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => }/lag.c (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => lib}/alloc.c (99%)
 rename {include/linux/mlx5 => drivers/net/ethernet/mellanox/mlx5/lib}/cmd.h (100%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => lib}/cq.c (98%)
 rename {include/linux/mlx5 => drivers/net/ethernet/mellanox/mlx5/lib}/cq.h (99%)
 rename {include/linux/mlx5 => drivers/net/ethernet/mellanox/mlx5/lib}/device.h (99%)
 rename {include/linux/mlx5 => drivers/net/ethernet/mellanox/mlx5/lib}/doorbell.h (100%)
 rename {include/linux/mlx5 => drivers/net/ethernet/mellanox/mlx5/lib}/driver.h (99%)
 rename {include/linux/mlx5 => drivers/net/ethernet/mellanox/mlx5/lib}/fs.h (98%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => lib}/fw.c (98%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => lib}/mad.c (96%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => lib}/mcg.c (96%)
 rename {include/linux/mlx5 => drivers/net/ethernet/mellanox/mlx5/lib}/mlx5_ifc.h (100%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => lib}/mr.c (98%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => lib}/pd.c (96%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => lib}/port.c (99%)
 rename {include/linux/mlx5 => drivers/net/ethernet/mellanox/mlx5/lib}/port.h (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => lib}/qp.c (98%)
 rename {include/linux/mlx5 => drivers/net/ethernet/mellanox/mlx5/lib}/qp.h (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => lib}/rl.c (98%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => lib}/srq.c (99%)
 rename {include/linux/mlx5 => drivers/net/ethernet/mellanox/mlx5/lib}/srq.h (98%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => lib}/transobj.c (99%)
 rename {include/linux/mlx5 => drivers/net/ethernet/mellanox/mlx5/lib}/transobj.h (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => lib}/uar.c (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => lib}/vport.c (99%)
 rename {include/linux/mlx5 => drivers/net/ethernet/mellanox/mlx5/lib}/vport.h (98%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => }/main.c (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/mlx5_core.h => mlx5.h} (100%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => }/pagealloc.c (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => sriov}/eswitch.c (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => sriov}/eswitch.h (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => sriov}/eswitch_offloads.c (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => sriov}/sriov.c (98%)
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
