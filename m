From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH for-next 00/14][PULL request] Mellanox mlx5 core driver updates 2016-10-25
Date: Tue, 25 Oct 2016 18:00:03 +0300
Message-ID: <1477407617-20745-1-git-send-email-saeedm@mellanox.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Tal Alon <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave and Doug,

This series contains some low level and API updates for mlx5 core
driver interface and mlx5_ifc.h, to be shared as base code for net-next
and rdma mlx5 4.10 submissions.

>From Artemy Kovalyov:
  - Update hardware struct mlx5_ifc_xrqc_bits
  - Ensure SRQ physical address structure endianness
  - Add KSM mlx5_ifc hardware bits support

>From Eugenia Emantayev:
  - Fix length of async_event_mask
  - MTPPS (Pulse-per-second) hardware events and registers support

>From Gal Pressman:
  - Add PPCNT physical layer statistical group infrastructure
  - Add MPCNT register infrastructure

>From Huy Nguyen:
  - Port module event hardware structures

>From Leon Romanovsky:
  - Report multi packet WQE hardware capabilities

>From Mohamad Haj Yahia:
  - Add support to s-tag in mlx5 firmware interface
  - Introduce TSAR (Transmit Scheduling Arbiter) manipulation firmware commands

>From Saeed Mahameed:
  - mlx5 IB: Skip handling unknown mlx5 events
  - Set driver version infrastructure
  - Add ConnectX-5 PCIe 4.0 VF device ID

The following changes since commit 1001354ca34179f3db924eb66672442a173147dc:
    Linux 4.9-rc1

are available in the git repository at:
    git://git.kernel.org/pub/scm/linux/kernel/git/leon/linux-rdma.git tags/shared-for-4.10-1

for you to fetch changes up to 46f6d2a982cd83679b18d0bebe2425fe65552c58:
    net/mlx5: Add ConnectX-5 PCIe 4.0 VF device ID

Thanks,
Saeed & Leon.

Artemy Kovalyov (3):
  net/mlx5: Update struct mlx5_ifc_xrqc_bits
  net/mlx5: Ensure SRQ physical address structure endianness
  net/mlx5: Add KSM support

Eugenia Emantayev (2):
  net/mlx5: Fix length of async_event_mask
  net/mlx5: MTPPS (Pulse-per-second) events and registers support

Gal Pressman (2):
  net/mlx5: Add PPCNT physical layer statistical group infrastructure
  net/mlx5: Add MPCNT register infrastructure

Huy Nguyen (1):
  net/mlx5: Port module event hardware structures

Leon Romanovsky (1):
  net/mlx5: Report multi packet WQE capabilities

Mohamad Haj Yahia (2):
  net/mlx5: Add support to s-tag in mlx5 firmware interface
  net/mlx5: Introduce TSAR manipulation firmware commands

Saeed Mahameed (3):
  IB/mlx5: Skip handling unknown events
  net/mlx5: Set driver version infrastructure
  net/mlx5: Add ConnectX-5 PCIe 4.0 VF device ID

 drivers/infiniband/hw/mlx5/main.c                  |   6 +-
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c      |  13 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c    |  10 +-
 .../ethernet/mellanox/mlx5/core/en_fs_ethtool.c    |   4 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    |   4 +-
 drivers/net/ethernet/mellanox/mlx5/core/eq.c       |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  |  12 +-
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |   1 +
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |   7 +
 drivers/net/ethernet/mellanox/mlx5/core/rl.c       |  65 +++
 include/linux/mlx5/device.h                        |  35 ++
 include/linux/mlx5/driver.h                        |   4 +
 include/linux/mlx5/mlx5_ifc.h                      | 440 ++++++++++++++++++++-
 include/linux/mlx5/port.h                          |   3 +
 include/linux/mlx5/srq.h                           |   2 +-
 15 files changed, 572 insertions(+), 36 deletions(-)

-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
