From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 20 Dec 2016 16:02:22 -0500 (EST)
Message-ID: <20161220.160222.2264807042516808022.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Use rb_entry() instead of hardcoded container_of(), from Geliang Tang.

2) Use correct memory barriers in stammac driver, from Pavel Machek.

3) Fix assoc bind address handling in SCTP, from Xin Long.

4) Make the length check for UFO handling consistent between
   __ip_append_data() and ip_finish_output(), from Zheng Li.

5) HSI driver compatible strings were busted fro hix5hd2, from Dongpo
   Li.

6) Handle devm_ioremap() errors properly in cavium driver, from Arvind
   Yadav.

Please pull, thanks a lot!

The following changes since commit 52f40e9d657cc126b766304a5dd58ad73b02ff46:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2016-12-17 20:17:04 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to a763f78cea845c91b8d91f93dabf70c407635dc5:

  RDS: use rb_entry() (2016-12-20 14:22:49 -0500)

----------------------------------------------------------------
Arvind Yadav (1):
      net: ethernet: cavium: octeon: octeon_mgmt: Handle return NULL error from devm_ioremap

David S. Miller (4):
      Merge branch 'phy-broken-modes'
      Merge branch 'fsl-fixes'
      Merge branch 'hix5hd2_gmac-compatible-string'
      Merge branch 'sctp-fixes'

Dongpo Li (2):
      net: hix5hd2_gmac: fix compatible strings name
      ARM: dts: hix5hd2: don't change the existing compatible string

Geliang Tang (4):
      net/mlx5: use rb_entry()
      net_sched: sch_fq: use rb_entry()
      net_sched: sch_netem: use rb_entry()
      RDS: use rb_entry()

Jarno Rajahalme (1):
      openvswitch: Add a missing break statement.

Madalin Bucur (4):
      fsl/fman: fix 1G support for QSGMII interfaces
      powerpc: fsl/fman: remove fsl,fman from of_device_ids[]
      fsl/fman: A007273 only applies to PPC SoCs
      fsl/fman: enable compilation on ARM64

Pavel Machek (1):
      stmmac: fix memory barriers

Tobias Klauser (1):
      ethernet: sfc: Add Kconfig entry for vendor Solarflare

WingMan Kwok (2):
      net: netcp: ethss: fix errors in ethtool ops
      net: netcp: ethss: fix 10gbe host port tx pri map configuration

Xin Long (2):
      sctp: reduce indent level in sctp_copy_local_addr_list
      sctp: not copying duplicate addrs to the assoc's bind address list

jbrunet (3):
      net: phy: fix sign type error in genphy_config_eee_advert
      net: phy: use boolean dt properties for eee broken modes
      dt: bindings: net: use boolean dt properties for eee broken modes

zheng li (1):
      ipv4: Should use consistent conditional judgement for ip fragment in __ip_append_data and ip_finish_output

 Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt | 13 ++++++++-----
 Documentation/devicetree/bindings/net/phy.txt                    | 10 ++++++++--
 arch/arm/boot/dts/hisi-x5hd2.dtsi                                |  4 ++--
 arch/powerpc/platforms/85xx/corenet_generic.c                    |  3 ---
 drivers/net/ethernet/Kconfig                                     |  1 -
 drivers/net/ethernet/cavium/octeon/octeon_mgmt.c                 |  6 ++++++
 drivers/net/ethernet/freescale/fman/Kconfig                      |  2 +-
 drivers/net/ethernet/freescale/fman/fman.c                       | 15 +++++++++++++++
 drivers/net/ethernet/freescale/fman/mac.c                        |  1 +
 drivers/net/ethernet/hisilicon/hix5hd2_gmac.c                    | 13 +++++++------
 drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c            |  2 +-
 drivers/net/ethernet/sfc/Kconfig                                 | 21 +++++++++++++++++++++
 drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c               |  4 ++--
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c                   |  2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c                |  8 ++++----
 drivers/net/ethernet/ti/netcp_ethss.c                            | 24 ++++++++++++++++++------
 drivers/net/phy/phy_device.c                                     | 22 +++++++++++++++++-----
 include/dt-bindings/net/mdio.h                                   | 19 -------------------
 net/ipv4/ip_output.c                                             |  2 +-
 net/openvswitch/flow_netlink.c                                   |  1 +
 net/rds/rdma.c                                                   |  2 +-
 net/sched/sch_fq.c                                               | 14 +++++++-------
 net/sched/sch_netem.c                                            |  2 +-
 net/sctp/bind_addr.c                                             |  3 +++
 net/sctp/protocol.c                                              | 40 ++++++++++++++++++++++------------------
 25 files changed, 148 insertions(+), 86 deletions(-)
 delete mode 100644 include/dt-bindings/net/mdio.h
