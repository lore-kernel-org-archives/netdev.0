From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [for-next 0/30][PULL request] Mellanox mlx5 core driver updates 2016-08-20
Date: Sat, 20 Aug 2016 23:11:43 +0300
Message-ID: <1471723933-5894-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Tal Alon <talal@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34036 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751269AbcHTUMn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 20 Aug 2016 16:12:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave and Doug,

This series contains several low level and API updates for mlx5 core
driver to be shared as base code for net-next and rdma mlx5 4.9 submissions.

>From Saeed, ten patches that refactors old layouts of firmware commands which 
were manually generated before we introduced the mlx5_ifc, now all of the firmware
commands inbox/outbox layouts moved to use mlx5_ifc and we remove the old
manually generated structures.  Plus to those ten patches, we add two patches
that unifies mlx5 commands execution interface and improve the driver log messages
in that area.

>From Hadar and Ilya, added the needed hardware bits and infrastructure for
minimum inline headers setting and encap/decap commands and capabilities,
needed for E-Switch offloads.

>From Alex and Artemy, Update mlx5_ifc for modify RQ and XRC bits.

>From Noa, Expose mlx5 link modes so they can be used in RDMA tree for rdma tools.

>From Aviv, LAG support needed for RDMA.
    - Add needed hardware structures, layouts and interface 
    - mlx5 core driver LAG implementation
    - Introduce mlx5 core driver LAG API for mlx5_ib

>From Maor, add two low level patches for mlx5 hardware sniffer QP
infrastructure bits and capabilities, plus added the name space for sniffer
steering tables.  Needed for RDMA subtree.

This series applies on top latest net-next and rdma/master, and smoothly merges with
the latest "Mellanox 100G mlx5 fixes 2016-08-16" series already applied into net branch.

The following changes since commit 29b4817d4018df78086157ea3a55c1d9424a7cfc:
    Linux 4.8-rc1

are available in the git repository at:
    git://git.kernel.org/pub/scm/linux/kernel/git/leon/linux-rdma.git tags/shared-for-4.9

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

Hadar Hen Zion (2):
  net/mlx5: Enable setting minimum inline header mode for VFs
  net/mlx5: Update mlx5_ifc.h for vxlan encap/decap

Ilya Lesokhin (1):
  net/mlx5: Introduce alloc_encap and dealloc_encap commands

Maor Gottlieb (2):
  net/mlx5: Introduce sniffer steering hardware capabilities
  net/mlx5: Add sniffer namespaces

Noa Osherovich (2):
  net/mlx5: Expose mlx5e_link_mode
  net/mlx5: Separate query_port_proto_oper for IB and EN

Saeed Mahameed (12):
  net/mlx5: Init/Teardown hca commands via mlx5 ifc
  net/mlx5: Access register and MAD IFC commands via mlx5 ifc
  net/mlx5: PD and UAR commands via mlx5 ifc
  net/mlx5: MCG commands via mlx5 ifc
  net/mlx5: Pages management commands via mlx5 ifc
  net/mlx5: EQ commands via mlx5 ifc
  {net,IB}/mlx5: CQ commands via mlx5 ifc
  {net,IB}/mlx5: MKey/PSV commands via mlx5 ifc
  {net,IB}/mlx5: QP/XRCD commands via mlx5 ifc
  {net,IB}/mlx5: Modify QP commands via mlx5 ifc
  net/mlx5: Unify and improve command interface
  net/mlx5: Improve driver log messages

 drivers/infiniband/hw/mlx5/cq.c                    | 110 ++--
 drivers/infiniband/hw/mlx5/main.c                  |  13 +-
 drivers/infiniband/hw/mlx5/mlx5_ib.h               |   2 +-
 drivers/infiniband/hw/mlx5/mr.c                    | 184 ++++---
 drivers/infiniband/hw/mlx5/qp.c                    | 189 +++----
 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c      | 273 +++++-----
 drivers/net/ethernet/mellanox/mlx5/core/cq.c       | 109 ++--
 drivers/net/ethernet/mellanox/mlx5/core/debugfs.c  |  50 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  34 --
 .../net/ethernet/mellanox/mlx5/core/en_common.c    |  23 +-
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |   3 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  55 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c   |   4 +-
 drivers/net/ethernet/mellanox/mlx5/core/eq.c       |  80 ++-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  |  98 ++--
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c   | 232 ++++----
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h   |   8 +
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  | 118 +++-
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h  |  10 +
 drivers/net/ethernet/mellanox/mlx5/core/fw.c       |  43 +-
 drivers/net/ethernet/mellanox/mlx5/core/lag.c      | 602 +++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/mad.c      |  41 +-
 drivers/net/ethernet/mellanox/mlx5/core/main.c     | 145 +++--
 drivers/net/ethernet/mellanox/mlx5/core/mcg.c      |  72 +--
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |  44 +-
 drivers/net/ethernet/mellanox/mlx5/core/mr.c       | 189 +++----
 .../net/ethernet/mellanox/mlx5/core/pagealloc.c    | 156 ++----
 drivers/net/ethernet/mellanox/mlx5/core/pd.c       |  61 +--
 drivers/net/ethernet/mellanox/mlx5/core/port.c     | 181 +++----
 drivers/net/ethernet/mellanox/mlx5/core/qp.c       | 299 +++++-----
 drivers/net/ethernet/mellanox/mlx5/core/rl.c       |  11 +-
 drivers/net/ethernet/mellanox/mlx5/core/sriov.c    |  19 +-
 drivers/net/ethernet/mellanox/mlx5/core/srq.c      |  49 +-
 drivers/net/ethernet/mellanox/mlx5/core/transobj.c | 183 +++----
 drivers/net/ethernet/mellanox/mlx5/core/uar.c      |  67 +--
 drivers/net/ethernet/mellanox/mlx5/core/vport.c    |  94 ++--
 drivers/net/ethernet/mellanox/mlx5/core/vxlan.c    |  29 +-
 include/linux/mlx5/cq.h                            |   6 +-
 include/linux/mlx5/device.h                        | 441 +--------------
 include/linux/mlx5/driver.h                        |  31 +-
 include/linux/mlx5/fs.h                            |   6 +
 include/linux/mlx5/mlx5_ifc.h                      | 297 +++++++++-
 include/linux/mlx5/port.h                          |  40 +-
 include/linux/mlx5/qp.h                            | 128 +----
 include/linux/mlx5/vport.h                         |   2 +
 46 files changed, 2493 insertions(+), 2340 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/lag.c

-- 
2.7.4
