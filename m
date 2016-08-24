From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [for-next 00/15][PULL request] Mellanox mlx5 core driver updates 2016-08-24
Date: Wed, 24 Aug 2016 13:38:59 +0300
Message-ID: <1472035154-14517-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Tal Alon <talal@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Majd Dibbiny <majd@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:59769 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752902AbcHXKl0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 06:41:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave and Doug,

This series contains some low level and API updates for mlx5 core
driver interface and mlx5_ifc.h, plus mlx5 LAG core driver support,
to be shared as base code for net-next and rdma mlx5 4.9 submissions.

>From Alex and Artemy, Update mlx5_ifc for modify RQ and XRC bits.

>From Noa, Expose mlx5 link modes so they can be used in RDMA tree for rdma tools.

>From Aviv, LAG support needed for RDMA.
    - Add needed hardware structures, layouts and interface
    - mlx5 core driver LAG implementation
    - Introduce mlx5 core driver LAG API for mlx5_ib

>From Maor, add two low level patches for mlx5 hardware sniffer QP
infrastructure bits and capabilities, plus added the namespace for sniffer
steering tables.  Needed for RDMA subtree.

The following changes since commit 575ddf5888eaf8f271cb3df7b0806cb2db2c333a:
    net/mlx5: Introduce alloc_encap and dealloc_encap commands

are available in the git repository at:
    git://git.kernel.org/pub/scm/linux/kernel/git/leon/linux-rdma.git tags/shared-for-4.9-2

for you to fetch changes up to 87d22483ce68e609818d61e3a65361f5634c6cd6:
    net/mlx5: Add sniffer namespaces

Thanks,
Saeed & Leon.

Alex Vesker (1):
  net/mlx5: Modify RQ bitmask from mlx5 ifc

Artemy Kovalyov (1):
  net/mlx5: Update struct mlx5_ifc_xrqc_bits

Aviv Heller (9):
  net/mlx5: Add HW interfaces used by LAG
  net/mlx5: Implement RoCE LAG feature
  net/mlx5: Get RoCE netdev
  net/mlx5e: Avoid port remapping of mlx5e netdev TISes
  net/mlx5: LAG and SRIOV cannot be used together
  net/mlx5: LAG demux flow table support
  net/mlx5: Add LAG flow steering namespace
  net/mlx5: Vport LAG creation support
  net/mlx5: Configure IB devices according to LAG state

Maor Gottlieb (2):
  net/mlx5: Introduce sniffer steering hardware capabilities
  net/mlx5: Add sniffer namespaces

Noa Osherovich (2):
  net/mlx5: Expose mlx5e_link_mode
  net/mlx5: Separate query_port_proto_oper for IB and EN

 drivers/infiniband/hw/mlx5/main.c                  |   3 +-
 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c      |  12 +
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  34 --
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  10 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c   |  56 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h   |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  | 100 +++-
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h  |  10 +
 drivers/net/ethernet/mellanox/mlx5/core/lag.c      | 602 +++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |  54 +-
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |  27 +
 drivers/net/ethernet/mellanox/mlx5/core/port.c     |  32 +-
 drivers/net/ethernet/mellanox/mlx5/core/sriov.c    |  12 +
 include/linux/mlx5/device.h                        |  12 +
 include/linux/mlx5/driver.h                        |  11 +-
 include/linux/mlx5/fs.h                            |   6 +
 include/linux/mlx5/mlx5_ifc.h                      | 181 ++++++-
 include/linux/mlx5/port.h                          |  40 +-
 19 files changed, 1105 insertions(+), 100 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/lag.c

-- 
2.7.4
