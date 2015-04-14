From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V2 00/12] net/mlx5: ConnectX-4 100G Ethernet driver
Date: Tue, 14 Apr 2015 11:20:23 +0300
Message-ID: <1428999635-15025-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:41949 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752155AbbDNIVV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2015 04:21:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Changes from V1:
- Added patch 1/12 ("net/mlx5_core,mlx5_ib: Do not use vmap() on coherent
  memory")

Changes from V0:
- Removed V0 Patch 1/11 ("net/mlx5_core: Virtually extend work/completion queue
  buffers by one page") due to misuse of DMA API. Thanks Dave.
- Patch 1/11 ("net/mlx5_core: Set irq affinity hints"):
  - Use kcalloc instead of kzalloc
  - Fix build error when CONFIG_CPUMASK_OFFSTACK=n. Driver loading will fail
    now if cpumask allocation is failing.
  - Using dev_to_node helper. Thanks, Ido.  
- Patch 3/11 ("net/mlx5_core: HW data structs/types definitions preparation for
  mlx5 ehternet driver")
  - Removed Mellanox internal comment at the head of the file. Thanks Joe
- Patch 6/11 ("net/mlx5_core: Implement get/set port status")
  - Use direct return of function's result. Thanks Sergei.
- Added Patch 8/11 ("net/mlx5_core: Set/Query port MTU commands")
- Patch 9/11 ("net/mlx5: Ethernet Datapath files") 
  - Use rq->wqe_sz instead of skb_end_offset. Thanks Ido.
  - Use dma_wmb() when possible instead of wmb(). Thanks Alex.
  - Fix checkpatch issues
- Patch 10/11 ("net/mlx5: ethernet resources handling")
  - checkpatch issues
  - Added missing include
- Patch 11/11 ("net/mlx5: Ethernet driver") 
  - checkpatch issues
  - fixed typo
  - Modified use of affinity hint
  - Using dev_to_node helper. Thanks, Ido.  
  - Use new hardware commands from Patch 8/11 ("net/mlx5_core: Set/Query port
    MTU commands") to get/set port MTU in hardware.
  - Removed NETIF_F_SG since hardware ring wraparound is not supported
  - Use dma_wmb() when possible instead of wmb(). Thanks Alex.

This patchset introduces support in Mellanox ConnectX-4 100G Ethernet NIC.
Unlike the ConnectX-3 driver, this driver is built of a single module (there is
no mlx5_en). It is the Ethernet driver and also the low level driver for the
infiniband driver - mlx5_ib.

Many features are still missing from the driver, but all the basic
functionalities are there already.

Notes:
-  Patch 4/11 ("net/mlx5_core: HW data structs/types definitions preparation
   for mlx5 ehternet driver") is too big for the mail server. It is hard to split
   it, since it is a generated code. I'm sending it as is, so you get it
   as part of the patches.  I also place it on a public git [1], to enable
   reviewing it from the mailing list.

Patchset was applied on top of commit 6e8a9d9 ("Merge branch 'for-davem' of
git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs")

[1] - http://git.openfabrics.org/?p=~amirv/linux.git;a=shortlog;h=refs/heads/mlx5e_v1  

Thanks to Achiad, Saeed, Yevheny, Or and the whole team for making this happen,
Amir

Amir Vadai (4):
  net/mlx5_core,mlx5_ib: Do not use vmap() on coherent memory
  net/mlx5: Ethernet Datapath files
  net/mlx5: Ethernet resources handling
  net/mlx5: Ethernet driver

Rana Shahout (2):
  net/mlx5_core: Implement get/set port status
  net/mlx5_core: Modify CQ moderation parameters

Saeed Mahameed (6):
  net/mlx5_core: Set irq affinity hints
  net/mlx5_core: Add EQ renaming mechanism
  net/mlx5_core: HW data structs/types definitions preparation for mlx5
    ehternet driver
  net/mlx5_core/ib: New device capabilities handling.
  net/mlx5_core: Implement get and set functions of ptys register fields
  net/mlx5_core: Set/Query port MTU commands

 drivers/infiniband/hw/mlx5/cq.c                    |   11 +-
 drivers/infiniband/hw/mlx5/mad.c                   |    2 +-
 drivers/infiniband/hw/mlx5/main.c                  |  113 +-
 drivers/infiniband/hw/mlx5/mlx5_ib.h               |    6 +-
 drivers/infiniband/hw/mlx5/mr.c                    |    3 +-
 drivers/infiniband/hw/mlx5/odp.c                   |   47 +-
 drivers/infiniband/hw/mlx5/qp.c                    |   86 +-
 drivers/infiniband/hw/mlx5/srq.c                   |    9 +-
 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |    3 +-
 drivers/net/ethernet/mellanox/mlx5/core/alloc.c    |   96 +-
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c      |   17 +-
 drivers/net/ethernet/mellanox/mlx5/core/cq.c       |   18 +
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  520 ++
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  679 ++
 .../ethernet/mellanox/mlx5/core/en_flow_table.c    |  858 +++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 1920 ++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |  249 +
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |  344 +
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c  |  107 +
 drivers/net/ethernet/mellanox/mlx5/core/eq.c       |   23 +-
 .../net/ethernet/mellanox/mlx5/core/flow_table.c   |  422 ++
 drivers/net/ethernet/mellanox/mlx5/core/fw.c       |   90 +-
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |  294 +-
 drivers/net/ethernet/mellanox/mlx5/core/mcg.c      |    2 +-
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |   20 +-
 drivers/net/ethernet/mellanox/mlx5/core/port.c     |  165 +
 drivers/net/ethernet/mellanox/mlx5/core/transobj.c |  169 +
 drivers/net/ethernet/mellanox/mlx5/core/transobj.h |   47 +
 drivers/net/ethernet/mellanox/mlx5/core/uar.c      |   44 +-
 drivers/net/ethernet/mellanox/mlx5/core/vport.c    |  111 +
 drivers/net/ethernet/mellanox/mlx5/core/vport.h    |   41 +
 drivers/net/ethernet/mellanox/mlx5/core/wq.c       |  186 +
 drivers/net/ethernet/mellanox/mlx5/core/wq.h       |  171 +
 include/linux/mlx5/cq.h                            |    3 +
 include/linux/mlx5/device.h                        |  179 +-
 include/linux/mlx5/driver.h                        |  108 +-
 include/linux/mlx5/flow_table.h                    |   54 +
 include/linux/mlx5/mlx5_ifc.h                      | 6622 +++++++++++++++++++-
 include/linux/mlx5/qp.h                            |   25 +
 39 files changed, 13293 insertions(+), 571 deletions(-)
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
