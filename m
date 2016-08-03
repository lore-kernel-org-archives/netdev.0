From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 02 Aug 2016 21:42:33 -0700 (PDT)
Message-ID: <20160802.214233.1619734018053305525.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60422 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751573AbcHCEpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 00:45:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Fix several cases of missing of_node_put() calls in various networking
   drivers.  From Peter Chen.

2) Don't try to remove unconfigured VLANs in qed driver, from Yuval Mintz.

3) Unbalanced locking in TIPC error handling, from Wei Yongjun.

4) Fix lockups in CPDMA driver, from Grygorii Strashko.

5) More MACSEC refcount et al. fixes, from Sabrina Dubroca.

6) Fix MAC address setting in r8169 during runtime suspend, from
   Chun-Hao Lin.

7) Various printf format specifier fixes, from Heinrich Schuchardt.

Please pull, thanks a lot!

The following changes since commit 797cee982eef9195736afc5e7f3b8f613c41d19a:

  Merge branch 'stable-4.8' of git://git.infradead.org/users/pcmoore/audit (2016-07-29 17:54:17 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net 

for you to fetch changes up to 1d2c2024dcb7aeb2555db4bfd7f991d247ba0508:

  qed: Fail driver load in 100g MSI mode. (2016-08-01 22:13:59 -0700)

----------------------------------------------------------------
Alexander Stein (1):
      phy/micrel: Change phy_id_mask for KSZ8721

Chun-Hao Lin (4):
      r8169: fix kernel log spam when set or get hardware wol setting.
      r8169: add checking driver's runtime pm status in rtl8169_get_ethtool_stats()
      r8169: fix nic may not work after changing mac address.
      8139too: fix system hang when there is a tx timeout event.

Colin Ian King (1):
      net: tulip: fix spelling mistake: "attemping" -> "attempting"

David S. Miller (5):
      Merge branch 'qed-fixes'
      Merge branch 'cpsw-fixes'
      Merge branch 'macsec-fixes'
      Merge branch 'r8169-fixes'
      Merge branch 'net-of_node_put'

Florian Fainelli (1):
      net: dsa: bcm_sf2: Unwind errors in correct order

Grygorii Strashko (4):
      net: ethernet: ti: cpdma: fix lockup in cpdma_ctlr_destroy()
      drivers: net: cpsw: fix wrong regs access in cpsw_remove
      drivers: net: cpsw: use of_platform_depopulate()
      ARM: OMAP2+: omap_device: fix crash on omap_device removal

Hariprasad Shenai (1):
      cxgb4/cxgb4vf: Fixes regression in perf when tx vlan offload is disabled

Peter Chen (15):
      ethernet: altera: add missing of_node_put
      ethernet: apm: xgene: add missing of_node_put after calling of_parse_phandle
      ethernet: arc: emac_main: add missing of_node_put after calling of_parse_phandle
      ethernet: aurora: nb8800: add missing of_node_put after calling of_parse_phandle
      ethernet: cavium: octeon: add missing of_node_put after calling of_parse_phandle
      ethernet: hisilicon: hns: hns_dsaf_mac: add missing of_node_put after calling of_parse_phandle
      ethernet: hisilicon: hns: hns_dsaf_main: add missing of_node_put after calling of_parse_phandle
      ethernet: marvell: mvneta: add missing of_node_put after calling of_parse_phandle
      ethernet: marvell: mvpp2: add missing of_node_put after calling of_parse_phandle
      ethernet: marvell: pxa168_eth: add missing of_node_put after calling of_parse_phandle
      ethernet: renesas: ravb_main: add missing of_node_put after calling of_parse_phandle
      ethernet: renesas: sh_eth: add missing of_node_put after calling of_parse_phandle
      ethernet: stmicro: stmmac: dwmac-socfpga: add missing of_node_put after calling of_parse_phandle
      ethernet: stmicro: stmmac: add missing of_node_put after calling of_parse_phandle
      ethernet: ti: davinci_emac: add missing of_node_put after calling of_parse_phandle

Sabrina Dubroca (3):
      macsec: fix reference counting on RXSC in macsec_handle_frame
      macsec: RXSAs don't need to hold a reference on RXSCs
      macsec: fix negative refcnt on parent link

Soheil Hassas Yeganeh (1):
      tcp: consider recv buf for the initial window scale

Sudarsana Reddy Kalluru (1):
      qed: Fail driver load in 100g MSI mode.

Wei Yongjun (4):
      tipc: fix imbalance read_unlock_bh in __tipc_nl_add_monitor()
      drivers: net: phy: xgene: Remove redundant dev_err call in xgene_mdio_probe()
      net: ipv6: use list_move instead of list_del/list_add
      qed: Fix error return code in qed_resc_alloc()

Xin Long (4):
      sctp: fix the issue sctp requeue auth chunk incorrectly
      sctp: allow delivering notifications after receiving SHUTDOWN
      sctp: allow receiving msg when TCP-style sk is in CLOSED state
      sctp: change to use TCP_CLOSE_WAIT as SCTP_SS_CLOSING

Yuval Mintz (6):
      qede: Don't try removing unconfigured vlans
      qed: Fix removal of spoof checking for VFs
      qed: Don't over-do producer cleanup for Rx
      qede: Reset statistics on explicit down
      qed: Correct min bandwidth for 100g
      qed: Prevent over-usage of vlan credits by PF

xypron.glpk@gmx.de (13):
      net: caif: use correct format specifier
      net: ethernet: ax88796: avoid null pointer dereference
      net: amd-xgbe: use correct format specifier
      net: bcm63xx: avoid possible null pointer dereference
      net: bna: use correct type specifications
      net: bna: use correct type specifier (2)
      net: enic: use correct type specifier
      net: s2io: simplify logical constraint
      net: qlge: remove superfluous statement
      wan/fsl_ucc_hdlc: avoid possible NULL pointer dereference
      qed: do not use unitialized variable
      dsa: b53: remove redundant if
      net: qlcnic: avoid superfluous assignement

 arch/arm/mach-omap2/omap_device.c                     |  2 +-
 drivers/net/caif/caif_spi.c                           |  4 ++--
 drivers/net/dsa/b53/b53_mmap.c                        |  3 +--
 drivers/net/dsa/bcm_sf2.c                             |  5 +++--
 drivers/net/ethernet/8390/ax88796.c                   |  3 ++-
 drivers/net/ethernet/altera/altera_tse_main.c         |  1 +
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c              |  2 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c        |  1 +
 drivers/net/ethernet/arc/emac_main.c                  | 15 +++++++++++----
 drivers/net/ethernet/aurora/nb8800.c                  |  2 ++
 drivers/net/ethernet/broadcom/bcm63xx_enet.c          |  2 +-
 drivers/net/ethernet/brocade/bna/bnad_debugfs.c       |  6 ++++--
 drivers/net/ethernet/cavium/octeon/octeon_mgmt.c      |  3 +++
 drivers/net/ethernet/chelsio/cxgb4/sge.c              |  2 +-
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c            |  2 +-
 drivers/net/ethernet/cisco/enic/enic_main.c           |  4 ++--
 drivers/net/ethernet/dec/tulip/de4x5.c                |  2 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c     |  9 ++++++---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c    |  7 ++++---
 drivers/net/ethernet/marvell/mvneta.c                 |  1 +
 drivers/net/ethernet/marvell/mvpp2.c                  |  2 ++
 drivers/net/ethernet/marvell/pxa168_eth.c             |  1 +
 drivers/net/ethernet/neterion/s2io.c                  |  2 +-
 drivers/net/ethernet/qlogic/qed/qed_dev.c             |  5 +++--
 drivers/net/ethernet/qlogic/qed/qed_l2.c              | 13 ++++++++++---
 drivers/net/ethernet/qlogic/qed/qed_main.c            |  7 ++++++-
 drivers/net/ethernet/qlogic/qed/qed_sriov.c           |  2 +-
 drivers/net/ethernet/qlogic/qed/qed_vf.c              |  4 ++--
 drivers/net/ethernet/qlogic/qede/qede_main.c          | 12 ++++++++----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.h       |  1 -
 drivers/net/ethernet/qlogic/qlge/qlge_main.c          |  1 -
 drivers/net/ethernet/realtek/8139too.c                | 12 ++++++++----
 drivers/net/ethernet/realtek/r8169.c                  | 37 +++++++++++++++++++++++++++++++++----
 drivers/net/ethernet/renesas/ravb_main.c              |  1 +
 drivers/net/ethernet/renesas/sh_eth.c                 |  1 +
 drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c   | 36 ++++++++++++++++++++++++++----------
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c     |  1 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c |  7 +++++--
 drivers/net/ethernet/ti/cpsw.c                        | 19 +++++++++----------
 drivers/net/ethernet/ti/davinci_cpdma.c               |  3 ---
 drivers/net/ethernet/ti/davinci_emac.c                |  1 +
 drivers/net/macsec.c                                  | 16 +++++++++++-----
 drivers/net/phy/mdio-xgene.c                          |  4 +---
 drivers/net/phy/micrel.c                              |  4 ++--
 drivers/net/wan/fsl_ucc_hdlc.c                        |  3 ++-
 include/net/sctp/constants.h                          |  2 +-
 net/ipv4/tcp_output.c                                 |  3 ++-
 net/ipv6/addrconf.c                                   |  3 +--
 net/sctp/output.c                                     |  3 ++-
 net/sctp/socket.c                                     |  2 +-
 net/sctp/ulpqueue.c                                   |  4 +++-
 net/tipc/monitor.c                                    |  2 +-
 52 files changed, 195 insertions(+), 95 deletions(-)
