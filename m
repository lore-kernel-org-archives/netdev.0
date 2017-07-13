From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 12 Jul 2017 17:08:45 -0700 (PDT)
Message-ID: <20170712.170845.68364827986057446.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Nothing super serious in here except perhaps the brcmfmac fix.

1) Fix 64-bit division in mlx5 IPSEC offload support, from Ilan Tayari and
   Arnd Bergmann.

2) Fix race in statistics gathering in bnxt_en driver, from Michael Chan.

3) Can't use a mutex in RCU reader protected section on tap driver,
   from Cong WANG.

4) Fix mdb leak in bridging code, from Eduardo Valentin.

5) Fix free of wrong pointer variable in nfp driver, from Dan Carpenter.

6) Buffer overflow in brcmfmac driver, from Arend van SPriel.

7) ioremap_nocache() return value needs to be checked in smsc911x
   driver, from Alexey Khoroshilov.

Please pull, thanks a lot.

The following changes since commit f263fbb8d60824993c1b64385056a3cfdbb21d45:

  Merge tag 'pci-v4.13-changes' of git://git.kernel.org/pub/scm/linux/kernel/git/helgaas/pci (2017-07-08 15:51:57 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net 

for you to fetch changes up to d93b07f8a689cde962d4f97668a74ab76f55734d:

  net: stmmac: revert "support future possible different internal phy mode" (2017-07-12 14:41:56 -0700)

----------------------------------------------------------------
Ahmad Fatoum (1):
      net: Fix minor code bug in timestamping.txt

Alexey Khoroshilov (1):
      smsc911x: Add check for ioremap_nocache() return code

Arend van Spriel (1):
      brcmfmac: fix possible buffer overflow in brcmf_cfg80211_mgmt_tx()

Arnd Bergmann (1):
      net/mlx5: IPSec, fix 64-bit division correctly

Bert Kenward (1):
      sfc: don't read beyond unicast address list

Christophe Jaillet (4):
      cisco: enic: Fic an error handling path in 'vnic_dev_init_devcmd2()'
      net: stmmac: Fix error handling path in 'alloc_dma_rx_desc_resources()'
      net: stmmac: Fix error handling path in 'alloc_dma_tx_desc_resources()'
      net: stmmac: Make 'alloc_dma_[rt]x_desc_resources()' look even closer

Dan Carpenter (2):
      nfp: freeing the wrong variable
      net: ipmr: ipmr_get_table() returns NULL

David S. Miller (5):
      Merge tag 'mlx5-fixes-2017-07-09' of https://git.kernel.org/.../saeed/linux
      Merge branch 'bnxt_en-Bug-fixes'
      Merge branch 'stmmac-dma-resources-fixes'
      Merge branch 'mlxsw-spectrum-Various-fixes'
      Merge branch 'net-doc-fixes'

Eduardo Valentin (1):
      bridge: mdb: fix leak on complete_info ptr on fail path

Guilherme G. Piccoli (1):
      cxgb4: fix BUG() on interrupt deallocating path of ULD

Huy Nguyen (1):
      net/mlx5e: Initialize CEE's getpermhwaddr address buffer to 0xff

Ido Schimmel (4):
      mlxsw: spectrum_router: Add missing rollback
      mlxsw: spectrum_router: Fix use-after-free in route replace
      mlxsw: spectrum_switchdev: Remove unused variable
      mlxsw: spectrum_switchdev: Check status of memory allocation

Ilan Tayari (6):
      net/mlx5: Add missing include in lib/gid.c
      net/mlx5: IPSec, Fix 64-bit division on 32-bit builds
      net/mlx5: FPGA, make mlx5_fpga_device_brb static
      net/mlx5: FPGA, Fix datatype mismatch
      net/mlx5: Build wq.o even if MLX5_CORE_EN is not selected
      net/mlx5: Add Makefiles for subdirectories

Kalderon, Michal (1):
      qed: Fix printk option passed when printing ipv6 addresses

LABBE Corentin (1):
      net: stmmac: revert "support future possible different internal phy mode"

Lin Yun Sheng (1):
      net: hns: Bugfix for Tx timeout handling in hns driver

Michael Chan (3):
      bnxt_en: Fix race conditions in .ndo_get_stats64().
      bnxt_en: Fix bug in ethtool -L.
      bnxt_en: Fix SRIOV on big-endian architecture.

WANG Cong (1):
      tap: convert a mutex to a spinlock

Yonghong Song (1):
      samples/bpf: fix a build issue

stephen hemminger (2):
      socket: add documentation for missing elements
      datagram: fix kernel-doc comments

 Documentation/networking/timestamping.txt                     |  6 ++----
 drivers/net/ethernet/broadcom/bnxt/bnxt.c                     | 42 +++++++++++++++++++++++++++++-------------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h                     |  4 +++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c             |  3 ++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c                 |  2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c               | 16 +++++++++++-----
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c                | 42 +++++++++++++++++++++++++-----------------
 drivers/net/ethernet/cisco/enic/vnic_dev.c                    |  9 +++++----
 drivers/net/ethernet/hisilicon/hns/hns_enet.c                 | 16 +++++++++-------
 drivers/net/ethernet/mellanox/mlx5/core/Makefile              |  4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/accel/Makefile        |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_accel/Makefile     |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_accel/ipsec_rxtx.c |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c            |  2 ++
 drivers/net/ethernet/mellanox/mlx5/core/fpga/Makefile         |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/fpga/core.c           |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/fpga/ipsec.c          |  4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/ipoib/Makefile        |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/lib/Makefile          |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/lib/gid.c             |  1 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c         |  4 ++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c      |  9 ++++++---
 drivers/net/ethernet/netronome/nfp/flower/metadata.c          |  2 +-
 drivers/net/ethernet/qlogic/qed/qed_iwarp.c                   |  6 +++---
 drivers/net/ethernet/sfc/ef10.c                               |  8 +++-----
 drivers/net/ethernet/smsc/smsc911x.c                          |  5 +++++
 drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c             | 10 +++-------
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c             | 14 +++++++-------
 drivers/net/tap.c                                             | 18 +++++++++---------
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c   |  5 +++++
 include/net/sock.h                                            |  3 +++
 net/bridge/br_mdb.c                                           |  3 ++-
 net/core/datagram.c                                           |  6 +++---
 net/ipv4/ipmr.c                                               |  4 ++--
 samples/bpf/Makefile                                          |  1 +
 tools/testing/selftests/bpf/Makefile                          |  1 -
 tools/testing/selftests/bpf/bpf_endian.h                      | 14 ++++++++++++++
 {samples => tools/testing/selftests}/bpf/bpf_helpers.h        |  0
 38 files changed, 172 insertions(+), 101 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/accel/Makefile
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_accel/Makefile
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/fpga/Makefile
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/ipoib/Makefile
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/lib/Makefile
 rename {samples => tools/testing/selftests}/bpf/bpf_helpers.h (100%)
