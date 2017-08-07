From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [pull request][for-next 0/8] Mellanox, mlx5 shared 2017-08-07
Date: Mon,  7 Aug 2017 13:18:00 +0300
Message-ID: <20170807101808.22924-1-saeedm@mellanox.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave & Doug,

This series contains some low level updates for mlx5 core driver,
to be shared as base code for net-next and rdma for-next mlx5
4.14 submissions.

Please find more information in the tag message below.

Please pull and let me know if there's any porblem.

Side note:
This series merges cleanly with current net-next, but it will conflict with Jiri's patch
"mlx5e: push cls_flower and mqprio setup_tc processing into separate functions"
Which is under review.
since this is shared code and must go to both rdma and net-next it has to be
based on 4.13-rc4, so there is not much I can do about this.

Thanks,
Saeed.

--

The following changes since commit aae4e7a8bc44722fe70d58920a36916b1043195e:

  Linux 4.13-rc4 (2017-08-06 18:44:49 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mellanox/linux.git tags/mlx5-shared-2017-08-07

for you to fetch changes up to a8ffcc741acb3c7f3dcf4c7d001209aa0995a5f1:

  net/mlx5: Increase the maximum flow counters supported (2017-08-07 10:47:07 +0300)

----------------------------------------------------------------
mlx5-shared-2017-08-07

This series includes some mlx5 updates for both net-next and rdma trees.

>From Saeed,
Core driver updates to allow selectively building the driver with
or without some large driver components, such as
	- E-Switch (Ethernet SRIOV support).
	- Multi-Physical Function Switch (MPFs) support.
For that we split E-Switch and MPFs functionalities into separate files.

>From Erez,
Delay mlx5_core events when mlx5 interfaces, namely mlx5_ib, registration
is taking place and until it completes.

>From Rabie,
Increase the maximum supported flow counters.

----------------------------------------------------------------
Erez Shitrit (1):
      net/mlx5: Delay events till ib registration ends

Rabie Loulou (2):
      net/mlx5: Fix counter list hardware structure
      net/mlx5: Increase the maximum flow counters supported

Saeed Mahameed (5):
      net/mlx5e: Rearrange netdevice ops structures
      net/mlx5e: NIC netdev init flow cleanup
      net/mlx5: Unify vport manager capability check
      net/mlx5: Separate between E-Switch and MPFS
      net/mlx5: Add CONFIG_MLX5_ESWITCH Kconfig

 drivers/net/ethernet/mellanox/mlx5/core/Kconfig    |  21 +++
 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |  11 +-
 drivers/net/ethernet/mellanox/mlx5/core/dev.c      |  73 +++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c    |  17 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  97 ++++------
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c   |  13 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.h   |   9 +
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |   2 +
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.h    |   7 +
 drivers/net/ethernet/mellanox/mlx5/core/eq.c       |   8 +-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  | 209 +++++----------------
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h  |  78 ++------
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c |   6 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c   |  12 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h   |  10 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h  |   2 +-
 .../net/ethernet/mellanox/mlx5/core/fs_counters.c  |  13 +-
 drivers/net/ethernet/mellanox/mlx5/core/lib/mpfs.c | 201 ++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/lib/mpfs.h |  95 ++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |  37 ++--
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |   4 +
 drivers/net/ethernet/mellanox/mlx5/core/sriov.c    |  14 +-
 include/linux/mlx5/driver.h                        |   5 +
 include/linux/mlx5/mlx5_ifc.h                      |  17 +-
 24 files changed, 597 insertions(+), 364 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/lib/mpfs.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/lib/mpfs.h
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
