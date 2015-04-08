From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 00/11] net/mlx5: ConnectX-4 100G Ethernet driver
Date: Wed,  8 Apr 2015 17:51:14 +0300
Message-ID: <1428504685-8945-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:36596 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932176AbbDHOwC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Apr 2015 10:52:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchset introduces support in Mellanox ConnectX-4 100G Ethernet NIC.
Unlike the ConnectX-3 driver, this driver is built of a single module (there is
no mlx5_en). It is the Ethernet driver and also the low level driver for the
infiniband driver - mlx5_ib.

Many features are still missing from the driver, but all the basic
functionalities are there already.


Notes:
1. There are some minor checkpatch warnings that will be fixed for V1
2. In Patch 1/11 ("net/mlx5_core: Set irq affinity hints") there is a misuse of cpumask_var_t
   will be fixed for V1
3. Patch 4/11 ("net/mlx5_core: HW data structs/types definitions preparation
   for mlx5 ehternet driver") is too big for the mail server. It is hard to split
   it, since it is a generated code. I'm sending it as is, so you get it
   as part of the patches.  I also place it on a public git [1], to enable
   reviewing it from the mailing list.

Patchset was applied on top of ee90b81 ("hv_netvsc: Fix the packet free when it
is in skb headroom")

[1] - http://git.openfabrics.org/?p=~amirv/linux.git;a=shortlog;h=refs/heads/mlx5e   

Thanks to Achiad, Saeed, Yevheny, Or and the whole team for making this happen,
Amir

Achiad Shochat (1):
  net/mlx5_core: Virtually extend work/completion queue buffers by one
    page

Amir Vadai (3):
  net/mlx5: Ethernet Datapath files
  net/mlx5: Ethernet resources handling
  net/mlx5: Ethernet driver

Rana Shahout (2):
  net/mlx5_core: Implement get/set port status
  net/mlx5_core: Modify CQ moderation parameters

Saeed Mahameed (5):
  net/mlx5_core: Set irq affinity hints
  net/mlx5_core: Add EQ renaming mechanism
  net/mlx5_core: HW data structs/types definitions preparation for mlx5
    ehternet driver
  net/mlx5_core/ib: New device capabilities handling.
  net/mlx5_core: Implement get and set functions of ptys register fields

 drivers/infiniband/hw/mlx5/cq.c                    |    8 +-
 drivers/infiniband/hw/mlx5/mad.c                   |    2 +-
 drivers/infiniband/hw/mlx5/main.c                  |  113 +-
 drivers/infiniband/hw/mlx5/mlx5_ib.h               |    6 +-
 drivers/infiniband/hw/mlx5/mr.c                    |    3 +-
 drivers/infiniband/hw/mlx5/odp.c                   |   47 +-
 drivers/infiniband/hw/mlx5/qp.c                    |   84 +-
 drivers/infiniband/hw/mlx5/srq.c                   |    7 +-
 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |    3 +-
 drivers/net/ethernet/mellanox/mlx5/core/alloc.c    |  126 +-
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c      |   17 +-
 drivers/net/ethernet/mellanox/mlx5/core/cq.c       |   18 +
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  518 ++
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  680 ++
 .../ethernet/mellanox/mlx5/core/en_flow_table.c    |  858 +++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 1879 ++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |  249 +
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |  350 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c  |  107 +
 drivers/net/ethernet/mellanox/mlx5/core/eq.c       |   20 +-
 .../net/ethernet/mellanox/mlx5/core/flow_table.c   |  420 ++
 drivers/net/ethernet/mellanox/mlx5/core/fw.c       |   90 +-
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |  280 +-
 drivers/net/ethernet/mellanox/mlx5/core/mcg.c      |    2 +-
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |   20 +-
 drivers/net/ethernet/mellanox/mlx5/core/port.c     |  111 +
 drivers/net/ethernet/mellanox/mlx5/core/transobj.c |  169 +
 drivers/net/ethernet/mellanox/mlx5/core/transobj.h |   47 +
 drivers/net/ethernet/mellanox/mlx5/core/uar.c      |   44 +-
 drivers/net/ethernet/mellanox/mlx5/core/vport.c    |  110 +
 drivers/net/ethernet/mellanox/mlx5/core/vport.h    |   41 +
 drivers/net/ethernet/mellanox/mlx5/core/wq.c       |  189 +
 drivers/net/ethernet/mellanox/mlx5/core/wq.h       |  171 +
 include/linux/mlx5/cq.h                            |    3 +
 include/linux/mlx5/device.h                        |  179 +-
 include/linux/mlx5/driver.h                        |   97 +-
 include/linux/mlx5/flow_table.h                    |   54 +
 include/linux/mlx5/mlx5_ifc.h                      | 6627 +++++++++++++++++++-
 include/linux/mlx5/qp.h                            |   25 +
 39 files changed, 13245 insertions(+), 529 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en.h
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_main.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/flow_table.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/transobj.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/transobj.h
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/vport.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/vport.h
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/wq.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/wq.h
 create mode 100644 include/linux/mlx5/flow_table.h

-- 
1.9.3
