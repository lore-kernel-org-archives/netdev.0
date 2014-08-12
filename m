From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 11 Aug 2014 21:12:15 -0700 (PDT)
Message-ID: <20140811.211215.14746231568007827.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Several networking final fixes and tidies for the merge window:

1) Changes during the merge window unintentionally took away the abilit=
y
   to build bluetooth modular, fix from Geert Uytterhoeven.

2) Several phy_node reference count bug fixes from Uwe Kleine-K=F6nig.

3) Fix ucc_geth build failures, also from Uwe Kleine-K=F6nig.

4) Fix klog false positivies when netlink messages go to network
   taps, by properly resetting the network header.  Fix from
   Daniel Borkmann.

5) Sizing estimate of VF netlink messages is too small, from Jiri Benc.

6) New APM X-Gene SoC ethernet driver, from Iyappan Subramanian.

7) VLAN untagging is erroneously dependent upon whether the VLAN module
   is loaded or not, but there are generic dependencies that matter wrt=
=2E
   what can be expected as the SKB enters the stack.  Make the basic
   untagging generic code, and do it unconditionally.  From Vlad
   Yasevich.

8) xen-netfront only has so many slots in it's transmit queue so
   linearize packets that have too many frags.  From Zoltan Kiss.

9) Fix suspend/resume PHY handling in bcmgenet driver, from Florian
   Fainelli.

Please pull, thanks a lot!

The following changes since commit 33caee39925b887a99a2400dc5c980097c35=
73f9:

  Merge branch 'akpm' (patchbomb from Andrew Morton) (2014-08-06 21:14:=
42 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 61dac43ee6bedd8507294c7af8959157b686c221=
:

  Merge branch 'bcmgenet' (2014-08-11 15:10:17 -0700)

----------------------------------------------------------------

Andreas Ruprecht (1):
      net: ethernet: qlogic: qlcnic: Remove duplicate object file from =
Makefile

Anish Bhatt (1):
      cxgb4: IEEE fixes for DCBx state machine

Daniel Borkmann (1):
      netlink: reset network header before passing to taps

David S. Miller (3):
      Merge git://git.kernel.org/.../pablo/nf
      Merge branch 'apm_xgene'
      Merge branch 'bcmgenet'

=46lorian Fainelli (4):
      net: bcmgenet: request and enable main clock earlier
      net: bcmgenet: correctly suspend and resume PHY device
      net: bcmgenet: update UMAC_CMD only when link is detected
      net: bcmgenet: correctly resume adapter from Wake-on-LAN

Geert Uytterhoeven (1):
      6lowpan: Allow 6LoWPAN to be modular

Hariprasad Shenai (1):
      cxgb4: Update FW version string to match FW binary version

Himangi Saraogi (10):
      drivers/net: ethernet: Remove typedef for struct and enum
      drivers/net: Remove typedefs pcnet_dev_t and hw_info_t
      drivers/net: Remove typedef axnet_dev_t
      dm9000: Remove typedef board_info_t
      ethernet: amd: Remove typedef local_info_t
      com20020_cs: Remove typedef com20020_dev_t
      atmel: Remove typedef atmel_priv_ioctl
      airo_cs: Remove typedef local_info_t
      hdlc: Remove typedefs from struct names
      wan: wanxl: Remove typedefs from struct names

Iyappan Subramanian (4):
      MAINTAINERS: Add entry for APM X-Gene SoC ethernet driver
      Documentation: dts: Add bindings for APM X-Gene SoC ethernet driv=
er
      dts: Add bindings for APM X-Gene SoC ethernet driver
      drivers: net: Add APM X-Gene SoC ethernet driver support.

Jean Sacren (3):
      amd: xgbe: fix duplicate #include of linux/phy.h
      openvswitch: fix duplicate #include headers
      batman: fix duplicate #include of multicast.h

Jiri Benc (1):
      rtnetlink: fix VF info size

Julia Lawall (6):
      solos-pci: fix error return code
      drivers/atm/atmtcp.c: fix error return code
      netfilter: nf_tables: fix error return code
      net: axienet: delete unneeded test before of_node_put
      ll_temac: delete unneeded test before of_node_put
      fec_mpc52xx: delete unneeded test before of_node_put

Michael Schmitz (1):
      m68k/atari: EtherNEC - ethernet support (ne)

Niv Yehezkel (1):
      ipv4: removed redundant conditional

Pablo Neira Ayuso (3):
      netfilter: nf_tables: uninitialize element key/data from the comm=
it path
      netfilter: nf_tables: don't update chain with unset counters
      netfilter: don't use mutex_lock_interruptible()

Rickard Strandqvist (2):
      net: ethernet: ti: cpmac.c: Cleaning up missing null-terminate af=
ter strncpy call
      net: ethernet: myricom: myri10ge: myri10ge.c: Cleaning up missing=
 null-terminate after strncpy call

Sanjeev Sharma (1):
      smsc: replace WARN_ON() with WARN_ON_SMP()

Uwe Kleine-K=F6nig (10):
      net: gianfar: no need to check parameter being !=3D NULL for of_n=
ode_put
      net: mvneta: Fix reference counting for phy_node
      net: gianfar: fix reference counting for phy_node
      net: bcmgenet: fix reference counting for phy node
      net: fs_enet: fix reference counting for phy_node
      net: ucc_geth: drop acquired references in probe error path and r=
emove
      net: ucc_geth: make probe consistently acquire a reference to the=
 phy node
      net: ucc_geth: Don't use the MAC as PHY without a fixed link
      net: ucc_geth: fix build failure
      net: fec: Support phys probed from devicetree and fixed-link

Vlad Yasevich (1):
      net: Always untag vlan-tagged traffic on input.

Zoltan Kiss (3):
      xen-netback: Fix vif->disable handling
      xen-netback: Don't deschedule NAPI when carrier off
      xen-netfront: Fix handling packets on compound pages with skb_lin=
earize

 Documentation/devicetree/bindings/net/apm-xgene-enet.txt |  66 ++++
 Documentation/devicetree/bindings/net/fsl-fec.txt        |  29 +-
 MAINTAINERS                                              |   8 +
 arch/arm64/boot/dts/apm-mustang.dts                      |   4 +
 arch/arm64/boot/dts/apm-storm.dtsi                       |  30 +-
 drivers/atm/atmtcp.c                                     |   1 +
 drivers/atm/solos-pci.c                                  |   1 +
 drivers/net/arcnet/com20020_cs.c                         |  16 +-
 drivers/net/ethernet/8390/Kconfig                        |   3 +-
 drivers/net/ethernet/8390/axnet_cs.c                     |  26 +-
 drivers/net/ethernet/8390/ne.c                           |   2 +
 drivers/net/ethernet/8390/pcnet_cs.c                     |  68 ++--
 drivers/net/ethernet/Kconfig                             |   1 +
 drivers/net/ethernet/Makefile                            |   1 +
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c                 |   1 -
 drivers/net/ethernet/apm/Kconfig                         |   1 +
 drivers/net/ethernet/apm/Makefile                        |   5 +
 drivers/net/ethernet/apm/xgene/Kconfig                   |   9 +
 drivers/net/ethernet/apm/xgene/Makefile                  |   6 +
 drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c      | 125 +++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c           | 728 +++++++=
+++++++++++++++++++++++++++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h           | 337 +++++++=
++++++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c         | 951 +++++++=
++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h         | 135 +++++++=
+
 drivers/net/ethernet/broadcom/genet/bcmgenet.c           |  37 ++-
 drivers/net/ethernet/broadcom/genet/bcmmii.c             |  14 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h               |  11 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c           | 260 +++++++=
++++----
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.h           |  10 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c          |   2 +
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h            |  12 +-
 drivers/net/ethernet/davicom/dm9000.c                    |  92 +++---
 drivers/net/ethernet/freescale/fec.h                     |   1 +
 drivers/net/ethernet/freescale/fec_main.c                |  76 +++--
 drivers/net/ethernet/freescale/fec_mpc52xx.c             |   3 +-
 drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c    |   2 +-
 drivers/net/ethernet/freescale/gianfar.c                 |  16 +-
 drivers/net/ethernet/freescale/ucc_geth.c                |  24 +-
 drivers/net/ethernet/fujitsu/fmvj18x_cs.c                |  34 +-
 drivers/net/ethernet/marvell/mvneta.c                    |   9 +-
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c         |   1 +
 drivers/net/ethernet/qlogic/qlcnic/Makefile              |   2 +-
 drivers/net/ethernet/smsc/smsc911x.h                     |   2 +-
 drivers/net/ethernet/ti/cpmac.c                          |   1 +
 drivers/net/ethernet/xilinx/ll_temac_main.c              |   3 +-
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c        |   3 +-
 drivers/net/ethernet/xircom/xirc2ps_cs.c                 |  40 +--
 drivers/net/wan/hdlc_fr.c                                |  63 ++--
 drivers/net/wan/wanxl.c                                  |  63 ++--
 drivers/net/wireless/airo_cs.c                           |  25 +-
 drivers/net/wireless/atmel.c                             |   8 +-
 drivers/net/xen-netback/interface.c                      |   6 +-
 drivers/net/xen-netback/netback.c                        |  10 +-
 drivers/net/xen-netfront.c                               |   7 +-
 include/linux/if_vlan.h                                  |   6 -
 include/linux/skbuff.h                                   |   1 +
 net/6lowpan/Kconfig                                      |   2 +-
 net/8021q/vlan_core.c                                    |  53 ---
 net/batman-adv/multicast.c                               |   1 -
 net/bridge/br_vlan.c                                     |   2 +-
 net/bridge/netfilter/ebtables.c                          |  10 +-
 net/core/dev.c                                           |   2 +-
 net/core/rtnetlink.c                                     |   3 +-
 net/core/skbuff.c                                        |  53 +++
 net/ipv4/route.c                                         |   2 -
 net/netfilter/core.c                                     |  11 +-
 net/netfilter/ipvs/ip_vs_ctl.c                           |  19 +-
 net/netfilter/nf_sockopt.c                               |   8 +-
 net/netfilter/nf_tables_api.c                            |  30 +-
 net/netfilter/x_tables.c                                 |  47 +--
 net/netlink/af_netlink.c                                 |   2 +-
 net/openvswitch/datapath.c                               |   2 -
 72 files changed, 3114 insertions(+), 531 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/apm-xgene-ene=
t.txt
 create mode 100644 drivers/net/ethernet/apm/Kconfig
 create mode 100644 drivers/net/ethernet/apm/Makefile
 create mode 100644 drivers/net/ethernet/apm/xgene/Kconfig
 create mode 100644 drivers/net/ethernet/apm/xgene/Makefile
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_main.c
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_main.h
