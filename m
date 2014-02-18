From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 18 Feb 2014 18:34:21 -0500 (EST)
Message-ID: <20140218.183421.1907590648974367512.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) kvaser CAN driver has fixed limits of some of it's table, validate t=
hat
   we won't exceed those limits at probe time.  Fix from Olivier Sobrie=
=2E

2) Fix rtl8192ce disabling interrupts for too long, from Olivier Langlo=
is.

3) Fix botched shift in ath5k driver, from Dan Carpenter.

4) Fix corruption of deferred packets in TIPC, from Erik Hugne.

5) Fix newlink error path in macvlan driver, from Cong Wang.

6) Fix netpoll deadlock in bonding, from Ding Tianhong.

7) Handle GSO packets properly in forwarding path when fragmentation
   is necessary on egress, from Florian Westphal.

8) Fix axienet build errors, from Michal Simek.

9) Fix refcounting of ubufs on tx in vhost net driver, from Michael
   S. Tsirkin.

10) Carrier status isn't set properly in hyperv driver, from Haiyang
    Zhang.

11) Missing pci_disable_device() in tulip_remove_one), from Ingo Molnar=
=2E

12) AF_PACKET qdisc bypass mode doesn't adhere to driver provided TX
    queue selection method.  Add a fallback method mechanism to fix
    this bug, from Daniel Borkmann.

13) Fix regression in link local route handling on GRE tunnels, from
    Nicolas Dichtel.

14) Bonding can assign dup aggregator IDs in some sequences of
    configuration, fix by making the allocation counter per-bond
    instead of global.  From Jiri Bohac.

15) sctp_connectx() needs compat translations, from Daniel Borkmann.

16) Fix of_mdio PHY interrupt parsing, from Ben Dooks.

Please pull, thanks a lot!

The following changes since commit 738b52bb9845da183b6ff46a8f685b56a633=
79d1:

  Merge tag 'microblaze-3.14-rc3' of git://git.monstr.eu/linux-2.6-micr=
oblaze (2014-02-11 12:24:35 -0800)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net master

for you to fetch changes up to 22f08ad9721d4d1a92061b60026144627a60d644=
:

  MAINTAINERS: add entry for the PHY library (2014-02-18 18:13:40 -0500=
)

----------------------------------------------------------------
Aleksander Morgado (1):
      net: qmi_wwan: add support for Cinterion PXS8 and PHS8

Antonio Quartulli (9):
      batman-adv: fix soft-interface MTU computation
      batman-adv: fix TT-TVLV parsing on OGM reception
      batman-adv: release vlan object after checking the CRC
      batman-adv: properly check pskb_may_pull return value
      batman-adv: avoid potential race condition when adding a new neig=
hbour
      batman-adv: fix TT CRC computation by ensuring byte order
      batman-adv: free skb on TVLV parsing success
      batman-adv: avoid double free when orig_node initialization fails
      batman-adv: fix potential kernel paging error for unicast transmi=
ssions

Ben Dooks (1):
      of_mdio: fix phy interrupt passing

Cong Wang (2):
      macvlan: unregister net device when netdev_upper_dev_link() fails
      net: correct error path in rtnl_newlink()

Dan Carpenter (2):
      ath5k: shifting the wrong variable for AR5K_AR5210
      af_packet: remove a stray tab in packet_set_ring()

Daniel Borkmann (4):
      netdevice: add queue selection fallback handler for ndo_select_qu=
eue
      netdevice: move netdev_cap_txqueue for shared usage to header
      packet: check for ndo_select_queue during queue selection
      net: sctp: fix sctp_connectx abi for ia32 emulation/compat mode

David S. Miller (3):
      Merge tag 'linux-can-fixes-for-3.14-20140212' of git://gitorious.=
org/linux-can/linux-can
      Merge tag 'batman-adv-fix-for-davem' of git://git.open-mesh.org/l=
inux-merge
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wir=
eless

Duan Jiong (2):
      ipv4: distinguish EHOSTUNREACH from the ENETUNREACH
      ipv4: fix counter in_slow_tot

Emil Goode (2):
      net: asix: add missing flag to struct driver_info
      usbnet: remove generic hard_header_len check

Emmanuel Grumbach (1):
      iwlwifi: disable TX AMPDU by default for iwldvm

Erik Hugne (1):
      tipc: fix message corruption bug for deferred packets

=46X Le Bail (1):
      ipv4: ipconfig.c: add parentheses in an if statement

=46lorian Fainelli (2):
      net: of_mdio: fix of_set_phy_supported after driver probing
      MAINTAINERS: add entry for the PHY library

=46lorian Westphal (2):
      net: core: introduce netif_skb_dev_features
      net: ip, ipv6: handle gso skbs in forwarding path

Gerrit Renker (1):
      dccp: re-enable debug macro

Haiyang Zhang (1):
      hyperv: Fix the carrier status setting

Heiko Schocher (1):
      drivers: net: cpsw: fix buggy loop condition

Ingo Molnar (1):
      drivers/net: tulip_remove_one needs to call pci_disable_device()

Jan Luebbe (1):
      net: fix macvtap type name in Kconfig

Jingoo Han (1):
      USB2NET: SR9800: use %zu for size_t

Jiri Bohac (1):
      bonding: 802.3ad: make aggregator_identifier bond-private

John W. Linville (2):
      Merge git://git.kernel.org/.../iwlwifi/iwlwifi-fixes
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Liu Junliang (1):
      USB2NET: Fix Default to 'y' for SR9800 Device Driver, setting to =
'n'

Matija Glavinic Pecotic (1):
      net: sctp: Fix a_rwnd/rwnd management to reflect real state of th=
e receiver's buffer

Michael S. Tsirkin (2):
      vhost: fix ref cnt checking deadlock
      vhost: fix a theoretical race in device cleanup

Michal Simek (2):
      net: axienet: Fix compilation error
      net: axienet: Fix compilation warnings

Mike Galbraith (1):
      net,bonding: fix bond_options.c direct rwlock.h include

Nicolas Dichtel (1):
      gre: add link local route when local addr is any

Olivier Langlois (2):
      rtlwifi: rtl8192ce: Fix too long disable of IRQs
      rtlwifi: Fix incorrect return from rtl_ps_enable_nic()

Olivier Sobrie (1):
      can: kvaser_usb: check number of channels returned by HW

Paul Gortmaker (1):
      Documentation/networking: delete orphaned 3c505.txt file.

Russell King (1):
      NET: fec: only enable napi if we are successful

Russell King - ARM Linux (1):
      hostap: fix "hostap: proc: Use remove_proc_subtree()"

Simon Wunderlich (1):
      batman-adv: fix potential orig_node reference leak

Srinivas Kandagatla (1):
      net: stmmac:sti: Add STi SOC glue driver.

Stanislaw Gruszka (1):
      rtl8187: fix regression on MIPS without coherent DMA

Stefan S=F8rensen (1):
      net:phy:dp83640: Move all HW initialization to dp83640_config_ini=
t

Thomas Petazzoni (1):
      net: ethernet: update dependency and help text of mvneta

Tommie Gannert (1):
      irtty-sir.c: Do not set_termios() on irtty_close()

Uwe Kleine-K=F6nig (1):
      net: cpsw: catch of_get_phy_mode failing and propagate error

Vijay Subramanian (1):
      net: sched: Cleanup PIE comments

dingtianhong (1):
      bonding: Fix deadlock in bonding driver when using netpoll

wangweidong (2):
      sctp: fix a missed .data initialization
      sctp: optimize the sctp_sysctl_net_register

 .../devicetree/bindings/net/sti-dwmac.txt          |  58 ++++
 Documentation/networking/3c505.txt                 |  45 ---
 MAINTAINERS                                        |  11 +
 drivers/net/Kconfig                                |   2 +-
 drivers/net/bonding/bond_3ad.c                     |   6 +-
 drivers/net/bonding/bond_3ad.h                     |   1 +
 drivers/net/bonding/bond_main.c                    |   9 +-
 drivers/net/bonding/bond_options.c                 |   2 +-
 drivers/net/can/usb/kvaser_usb.c                   |   2 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |   4 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    |   2 +-
 drivers/net/ethernet/dec/tulip/tulip_core.c        |   1 +
 drivers/net/ethernet/freescale/fec_main.c          |   4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |   6 +-
 drivers/net/ethernet/lantiq_etop.c                 |   2 +-
 drivers/net/ethernet/marvell/Kconfig               |   6 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c         |   4 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h       |   2 +-
 drivers/net/ethernet/stmicro/stmmac/Kconfig        |  11 +
 drivers/net/ethernet/stmicro/stmmac/Makefile       |   1 +
 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c    | 330 +++++++++++++=
++++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |   3 +
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   5 +
 drivers/net/ethernet/ti/cpsw.c                     |  11 +-
 drivers/net/ethernet/tile/tilegx.c                 |   2 +-
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c  |  13 +-
 drivers/net/hyperv/netvsc_drv.c                    |  53 +++-
 drivers/net/irda/irtty-sir.c                       |   1 -
 drivers/net/macvlan.c                              |   5 +-
 drivers/net/phy/dp83640.c                          |  13 +-
 drivers/net/team/team.c                            |   2 +-
 drivers/net/tun.c                                  |   2 +-
 drivers/net/usb/Kconfig                            |   1 -
 drivers/net/usb/asix_devices.c                     |   3 +-
 drivers/net/usb/ax88179_178a.c                     |   4 +
 drivers/net/usb/gl620a.c                           |   4 +
 drivers/net/usb/mcs7830.c                          |   5 +-
 drivers/net/usb/net1080.c                          |   4 +
 drivers/net/usb/qmi_wwan.c                         |   9 +-
 drivers/net/usb/rndis_host.c                       |   4 +
 drivers/net/usb/smsc75xx.c                         |   4 +
 drivers/net/usb/smsc95xx.c                         |   4 +
 drivers/net/usb/sr9800.c                           |   6 +-
 drivers/net/usb/usbnet.c                           |  25 +-
 drivers/net/wireless/ath/ath5k/phy.c               |   2 +-
 drivers/net/wireless/hostap/hostap_proc.c          |   2 +-
 drivers/net/wireless/iwlwifi/dvm/mac80211.c        |  22 +-
 drivers/net/wireless/iwlwifi/iwl-drv.c             |   2 +-
 drivers/net/wireless/iwlwifi/iwl-modparams.h       |  11 +-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |  22 +-
 drivers/net/wireless/mwifiex/main.c                |   2 +-
 drivers/net/wireless/rtl818x/rtl8187/rtl8187.h     |  10 +-
 drivers/net/wireless/rtlwifi/ps.c                  |   2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        |  18 +-
 drivers/of/of_mdio.c                               |  22 +-
 drivers/staging/bcm/Bcmnet.c                       |   2 +-
 drivers/staging/netlogic/xlr_net.c                 |   2 +-
 drivers/staging/rtl8188eu/os_dep/os_intfs.c        |   2 +-
 drivers/vhost/net.c                                |  47 +--
 include/linux/netdevice.h                          |  36 ++-
 include/linux/skbuff.h                             |  17 ++
 include/net/sctp/structs.h                         |  14 +-
 net/batman-adv/bat_iv_ogm.c                        |  30 +-
 net/batman-adv/hard-interface.c                    |  22 +-
 net/batman-adv/originator.c                        |  36 +++
 net/batman-adv/originator.h                        |   4 +
 net/batman-adv/routing.c                           |   4 +-
 net/batman-adv/send.c                              |   9 +-
 net/batman-adv/translation-table.c                 |  23 +-
 net/core/dev.c                                     |  22 +-
 net/core/flow_dissector.c                          |  20 +-
 net/core/rtnetlink.c                               |  19 +-
 net/dccp/ccids/lib/tfrc.c                          |   2 +-
 net/dccp/ccids/lib/tfrc.h                          |   1 +
 net/ipv4/ip_forward.c                              |  71 ++++-
 net/ipv4/ipconfig.c                                |   2 +-
 net/ipv4/route.c                                   |  13 +-
 net/ipv6/addrconf.c                                |   2 +
 net/ipv6/ip6_output.c                              |  17 +-
 net/mac80211/iface.c                               |   6 +-
 net/packet/af_packet.c                             |  26 +-
 net/sched/sch_pie.c                                |  21 +-
 net/sctp/associola.c                               |  82 ++---
 net/sctp/sm_statefuns.c                            |   2 +-
 net/sctp/socket.c                                  |  47 ++-
 net/sctp/sysctl.c                                  |  18 +-
 net/sctp/ulpevent.c                                |   8 +-
 net/tipc/core.h                                    |   1 +
 net/tipc/link.c                                    |   7 +
 89 files changed, 1081 insertions(+), 361 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/sti-dwmac.txt
 delete mode 100644 Documentation/networking/3c505.txt
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
