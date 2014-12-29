From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 29 Dec 2014 16:33:50 -0500 (EST)
Message-ID: <20141229.163350.894472797499864548.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix double SKB free in bluetooth 6lowpan layer, from Jukka
   Rissanen.

2) Fix receive checksum handling in enic driver, from Govindarajulu
   Varadarajan.

3) Fix NAPI poll list corruption in virtio_net and caif_virtio, from
   Herbert Xu.  Also, add code to detect drivers that have this
   mistake in the future.

4) Fix doorbell endianness handling in mlx4 driver, from Amir Vadai.

5) Don't clobber IP6CB() before xfrm6_policy_check() is called in
   TCP input path,f rom Nicolas Dichtel.

6) Fix MPLS action validation in openvswitch, from Pravin B Shelar.

7) Fix double SKB free in vxlan driver, also from Pravin.

8) When we scrub a packet, which happens when we are switching the
   context of the packet (namespace, etc.), we should reset the
   secmark.  From Thomas Graf.

9) ->ndo_gso_check() needs to do more than return true/false, it
   also has to allow the driver to clear netdev feature bits in
   order for the caller to be able to proceed properly.  From=09
   Jesse Gross.

Please pull, thanks a lot!

The following changes since commit d790be3863b28fd22e0781c1a3ddefcbfd5f=
7086:

  Merge tag 'modules-next-for-linus' of git://git.kernel.org/pub/scm/li=
nux/kernel/git/rusty/linux (2014-12-18 20:55:41 -0800)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to dc97a1a9477f969e34b38ca9d9cd231cb93ebea2=
:

  genetlink: A genl_bind() to an out-of-range multicast group should no=
t WARN(). (2014-12-29 16:31:49 -0500)

----------------------------------------------------------------
Al Viro (3):
      Bluetooth: hidp_connection_add() unsafe use of l2cap_pi()
      Bluetooth: cmtp: cmtp_add_connection() should verify that it's de=
aling with l2cap socket
      Bluetooth: bnep: bnep_add_connection() should verify that it's de=
aling with l2cap socket

Amir Vadai (1):
      net/mlx4_en: Doorbell is byteswapped in Little Endian archs

Antonio Quartulli (1):
      batman-adv: avoid NULL dereferences and fix if check

Appana Durga Kedareswara Rao (1):
      net: xilinx: Remove unnecessary temac_property in the driver

Dan Collins (1):
      packet: Fixed TPACKET V3 to signal poll when block is closed rath=
er than every packet

Daniel Gl=F6ckner (1):
      net: s6gmac: remove driver

David S. Miller (6):
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth=
/bluetooth
      Merge branch 'openvswitch-net'
      Merge tag 'wireless-drivers-for-davem-2014-12-26' of git://git.ke=
rnel.org/.../kvalo/wireless-drivers
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth=
/bluetooth
      Merge branch 'netlink_multicast'
      genetlink: A genl_bind() to an out-of-range multicast group shoul=
d not WARN().

Eliad Peller (1):
      iwlwifi: mvm: clear IN_HW_RESTART flag on stop()

Emmanuel Grumbach (3):
      iwlwifi: pcie: re-ACK all interrupts after device reset
      iwlwifi: don't double free a pointer if no FW was found
      iwlwifi: add new device IDs for 3165

Govindarajulu Varadarajan (1):
      enic: fix rx skb checksum

Haiyang Zhang (1):
      hyperv: Fix some variable name typos in send-buffer init/revoke

Hariprasad Shenai (1):
      cxgb4vf: Fix ethtool get_settings for VF driver

Herbert Xu (6):
      virtio_net: Fix napi poll list corruption
      caif: Fix napi poll list corruption
      net: Move napi polling code out of net_rx_action
      net: Detect drivers that reschedule NAPI and exhaust budget
      net: Always poll at least one device in net_rx_action
      net: Rearrange loop in net_rx_action

Huacai Chen (1):
      stmmac: Don't init ptp again when resume from suspend/hibernation

Jason Wang (1):
      net: drop the packet when fails to do software segmentation or he=
ader check

Jay Vosburgh (1):
      net/core: Handle csum for CHECKSUM_COMPLETE VXLAN forwarding

Jesse Gross (1):
      net: Generalize ndo_gso_check to ndo_features_check

Jia-Ju Bai (3):
      8139too: Fix the lack of pci_disable_device
      8139too: Add netif_napi_del in the driver
      ne2k-pci: Add pci_disable_device in error handling

Johan Hedberg (1):
      Bluetooth: Fix accepting connections when not using mgmt

Johan Hovold (1):
      net: phy: micrel: use generic config_init for KSZ8021/KSZ8031

Johannes Berg (6):
      netlink: rename netlink_unbind() to netlink_undo_bind()
      genetlink: pass only network namespace to genl_has_listeners()
      netlink: update listeners directly when removing socket
      netlink: call unbind when releasing socket
      genetlink: pass multicast bind/unbind to families
      netlink/genetlink: pass network namespace to bind/unbind

Jukka Rissanen (1):
      Bluetooth: 6lowpan: Do not free skb when packet is dropped

Kalle Valo (1):
      Merge tag 'iwlwifi-fixes-for-kalle-2014-12-18' of git://git.kerne=
l.org/.../iwlwifi/iwlwifi-fixes

Li RongQing (1):
      sunvnet: fix a memory leak in vnet_handle_offloads

Liad Kaufman (1):
      iwlwifi: pcie: limit fw chunk sizes given to fh

Marcel Holtmann (1):
      Bluetooth: Fix controller configuration with HCI_QUIRK_INVALID_BD=
ADDR

Mika Westerberg (1):
      brcmfmac: Do not crash if platform data is not populated

Nicholas Mc Guire (1):
      net: incorrect use of init_completion fixup

Nicolas Dichtel (2):
      tcp6: don't move IP6CB before xfrm6_policy_check()
      neigh: remove next ptr from struct neigh_table

Paul Bolle (1):
      ipw2200: select CFG80211_WEXT

Prashant Sreedharan (1):
      tg3: tg3_disable_ints using uninitialized mailbox value to disabl=
e interrupts

Pravin B Shelar (6):
      mpls: Fix config check for mpls.
      mpls: Fix allowed protocols for mpls gso
      openvswitch: Fix MPLS action validation.
      openvswitch: Fix GSO with multiple MPLS label.
      openvswitch: Fix vport_send double free
      vxlan: Fix double free of skb.

Rickard Strandqvist (1):
      net: ethernet: micrel: ksz884x.c: Remove unused function

Sven Eckelmann (2):
      batman-adv: Calculate extra tail size based on queued fragments
      batman-adv: Unify fragment size calculation

Thomas Graf (1):
      net: Reset secmark when scrubbing packet

Toshiaki Makita (1):
      net: Fix stacked vlan offload features computation

Wengang Wang (1):
      bonding: change error message to debug message in __bond_release_=
one()

Wolfram Sang (1):
      net: ethernet: stmicro: stmmac: drop owner assignment from platfo=
rm_drivers

Wu Fengguang (1):
      openvswitch: fix odd_ptr_err.cocci warnings

stephen hemminger (1):
      in6: fix conflict with glibc

 drivers/net/bonding/bond_main.c                       |    2 +-
 drivers/net/caif/caif_virtio.c                        |    2 -
 drivers/net/ethernet/8390/ne2k-pci.c                  |    6 +-
 drivers/net/ethernet/Kconfig                          |   12 -
 drivers/net/ethernet/Makefile                         |    1 -
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c      |    8 +-
 drivers/net/ethernet/broadcom/tg3.c                   |   34 +--
 drivers/net/ethernet/brocade/bna/bnad_debugfs.c       |    2 +-
 drivers/net/ethernet/chelsio/cxgb4vf/adapter.h        |    4 +
 drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c   |  142 ++++++++-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h    |    2 +-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c        |   54 ++--
 drivers/net/ethernet/cisco/enic/enic_main.c           |   12 +-
 drivers/net/ethernet/emulex/benet/be_main.c           |    8 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c        |   10 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c            |   12 +-
 drivers/net/ethernet/micrel/ksz884x.c                 |    6 -
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c      |    8 +-
 drivers/net/ethernet/realtek/8139too.c                |    4 +-
 drivers/net/ethernet/s6gmac.c                         | 1058 ---------=
--------------------------------------------------------
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c     |   14 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c |    1 -
 drivers/net/ethernet/sun/sunvnet.c                    |    1 +
 drivers/net/ethernet/xilinx/xilinx_axienet.h          |    2 -
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c     |    4 -
 drivers/net/hyperv/hyperv_net.h                       |    1 +
 drivers/net/hyperv/netvsc.c                           |   15 +-
 drivers/net/phy/micrel.c                              |   18 +-
 drivers/net/virtio_net.c                              |    2 -
 drivers/net/vxlan.c                                   |   34 ++-
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c      |    4 +-
 drivers/net/wireless/ipw2x00/Kconfig                  |    3 +-
 drivers/net/wireless/iwlwifi/iwl-drv.c                |    2 +-
 drivers/net/wireless/iwlwifi/iwl-fh.h                 |    1 +
 drivers/net/wireless/iwlwifi/mvm/mac80211.c           |   15 +-
 drivers/net/wireless/iwlwifi/pcie/drv.c               |    4 +
 drivers/net/wireless/iwlwifi/pcie/trans.c             |   17 +-
 include/linux/netdevice.h                             |   20 +-
 include/linux/netlink.h                               |    4 +-
 include/net/genetlink.h                               |    9 +-
 include/net/neighbour.h                               |    1 -
 include/net/vxlan.h                                   |   28 +-
 include/uapi/linux/in6.h                              |    3 +-
 include/uapi/linux/libc-compat.h                      |    3 +
 kernel/audit.c                                        |    2 +-
 net/batman-adv/fragmentation.c                        |    4 +-
 net/batman-adv/gateway_client.c                       |    2 +-
 net/bluetooth/6lowpan.c                               |    1 -
 net/bluetooth/bnep/core.c                             |    3 +
 net/bluetooth/cmtp/core.c                             |    3 +
 net/bluetooth/hci_event.c                             |   16 +-
 net/bluetooth/hidp/core.c                             |    3 +-
 net/core/dev.c                                        |  175 ++++++---=
--
 net/core/skbuff.c                                     |    1 +
 net/ipv4/geneve.c                                     |    6 +-
 net/ipv6/tcp_ipv6.c                                   |   45 ++-
 net/mpls/mpls_gso.c                                   |    5 +-
 net/netfilter/nfnetlink.c                             |    2 +-
 net/netlink/af_netlink.c                              |   38 ++-
 net/netlink/af_netlink.h                              |    8 +-
 net/netlink/genetlink.c                               |   56 ++++
 net/openvswitch/actions.c                             |    3 +-
 net/openvswitch/datapath.c                            |    3 +-
 net/openvswitch/flow_netlink.c                        |   13 +-
 net/openvswitch/vport-geneve.c                        |    3 +
 net/openvswitch/vport-gre.c                           |   18 +-
 net/openvswitch/vport-vxlan.c                         |    2 +
 net/openvswitch/vport.c                               |    5 +-
 net/packet/af_packet.c                                |   11 +-
 69 files changed, 628 insertions(+), 1393 deletions(-)
 delete mode 100644 drivers/net/ethernet/s6gmac.c
