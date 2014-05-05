From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 05 May 2014 17:42:46 -0400 (EDT)
Message-ID: <20140505.174246.398015695126465358.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) e1000e computes header length incorrectly wrt. vlans, fix from Vlad =
Yasevich.

2) ns_capable() check in sock_diag netlink code, from Andrew Lutomirski=
=2E

3) Fix invalid queue pairs handling in virtio_net, from Amos Kong.

4) Checksum offloading busted in sxgbe driver due to incorrect descript=
or
   layout, fix from Byungho An.

5) Fix build failure with SMC_DEBUG set to 2 or larger, from Zi Shen Li=
m.

6) Fix uninitialized A and X registers in BPF interpreter, from Alexei
   Starovoitov.

7) Fix arch dependencies of candence driver.

8) Fix netlink capabilities checking tree-wide, from Eric W. Biederman.

9) Don't dump IFLA_VF_PORTS if netlink request didn't ask for it in
   IFLA_EXT_MASK, from David Gibson.

10) IPV6 FIB dump restart doesn't handle table changes that happen
    meanwhile, causing the code to loop forever or emit dups, fix from
    Kumar Sandararajan.

11) Memory leak on VF removal in bnx2x, from Yuval Mintz.

12) Bug fixes for new Altera TSE driver from Vince Bridgers.

13) Fix route lookup key in SCTP, from Xugeng Zhang.

14) Use BH blocking spinlocks in SLIP, as per a similar fix to
    CAN/SLCAN driver.  From Oliver Hartkopp.

15) TCP doesn't bump retransmit counters in some code paths, fix from
    Eric Dumazet.

16) Clamp delayed_ack in tcp_cubic to prevent theoretical divides by
    zero.  Fix from Liu Yu.

17) Fix locking imbalance in error paths of HHF packet scheduler, from
    John Fastabend.

18) Properly reference the transport module when vsock_core_init() runs=
,
    from Andy King.

19) Fix buffer overflow in cdc_ncm driver, from Bj=F8rn Mork.

20) IP_ECN_decapsulate() doesn't see a correct SKB network header in
    ip_tunnel_rcv(), fix from Ying Cai.

Please pull, thanks a lot!

The following changes since commit 6d4596905b65bf4c63c1a008f50bf385fa49=
f19b:

  Merge branch 'x86-urgent-for-linus' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/tip/tip (2014-04-19 10:41:43 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to c8ea5a22bd3b27d68ec2f95483ce8bfe7f114933=
:

  net: macb: Fix race between HW and driver (2014-05-05 17:11:18 -0400)

----------------------------------------------------------------
Alexander Stein (1):
      can: slcan: Fix spinlock variant

Alexei Starovoitov (1):
      net: filter: initialize A and X registers

Amos Kong (1):
      virtio_net: zero is an invald queue_pairs number

Andrew Lutomirski (1):
      net: Fix ns_capable check in sock_diag_put_filterinfo

Andy King (1):
      vsock: Make transport the proto owner

Balakumaran Kannan (1):
      net phy: Check for aneg completion before setting state to PHY_RU=
NNING

Ben Hutchings (2):
      net: Update my email address
      rtl8192cu: Fix unbalanced irq enable in error path of rtl92cu_hw_=
init()

Bj=F8rn Mork (8):
      net: qmi_wwan: add Sierra Wireless EM7355
      net: qmi_wwan: add Sierra Wireless MC73xx
      net: qmi_wwan: add Sierra Wireless MC7305/MC7355
      net: qmi_wwan: add Olivetti Olicard 500
      net: qmi_wwan: add Alcatel L800MA
      net: qmi_wwan: add a number of CMOTech devices
      net: qmi_wwan: add a number of Dell devices
      net: cdc_ncm: fix buffer overflow

Brendan Hickey (1):
      bpf_dbg: fix wrong register usage

Byungho An (5):
      net: sxgbe: rearrange dma descriptor
      net: sxgbe: Added phy_found error path
      net: sxgbe: sw reset moved to probe function
      net: sxgbe: Added rxqueue enable function
      net: sxgbe: Added set function for interrupt on complete

Claudiu Manoil (2):
      gianfar: Check if phydev present on ethtool -A
      gianfar: Avoid unnecessary reg accesses in adjust_link()

Colin Ian King (1):
      rtlwifi: rtl8188ee: initialize packet_beacon

David Ertman (4):
      e1000e: Workaround for dropped packets in Gig/100 speeds on 82579
      e1000e: Expand workaround for 10Mb HD throughput bug
      e1000e: Fix issue with link flap on 82579
      e1000e: Restrict MDIO Slow Mode workaround to relevant parts

David Gibson (2):
      rtnetlink: Warn when interface's information won't fit in our pac=
ket
      rtnetlink: Only supply IFLA_VF_PORTS information when RTEXT_FILTE=
R_VF is set

David S. Miller (12):
      Merge branch 'master' of git://git.kernel.org/.../jkirsher/net
      Merge branch 'qlcnic-net'
      Merge branch 'netlink-caps'
      netfilter: Fix warning in nfnetlink_receive().
      Merge branch 'rtnetlink_vf_ports'
      Merge branch 'bnx2x-net'
      Merge branch 'altera_tse'
      Merge tag 'linux-can-fixes-for-3.15-20140424' of git://gitorious.=
org/linux-can/linux-can
      Merge branch 'qmi_wwan'
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wir=
eless
      Merge branch 'mlx4'
      Merge branch 'master' of git://git.kernel.org/.../jkirsher/net

Eric Dumazet (1):
      tcp: increment retransmit counters in tlp and fast open

Eric W. Biederman (5):
      netlink: Rename netlink_capable netlink_allowed
      net: Move the permission check in sock_diag_put_filterinfo to pac=
ket_diag_dump
      net: Add variants of capable for use on on sockets
      net: Add variants of capable for use on netlink messages
      net: Use netlink_ns_capable to verify the permisions of netlink m=
essages

Eyal Perry (1):
      net/mlx4_core: Don't issue PCIe speed/width checks for VFs

Ezequiel Garcia (1):
      net: mvmdio: Check for a valid interrupt instead of an error

=46elix Fietkau (2):
      ath9k_hw: do not lower ANI setting below default on AR913x
      ath9k: remove tid->paused flag

=46lorian Fainelli (1):
      MAINTAINERS: SXGBE authors update

=46rancois Romieu (1):
      i40e: remove open-coded skb_cow_head

Geert Uytterhoeven (1):
      Altera TSE: ALTERA_TSE should depend on HAS_DMA

Gertjan van Wingerde (1):
      rt2x00: Remove myself as maintainer.

Hans de Goede (1):
      brcmfmac: Fix brcmf_chip_ai_coredisable not applying reset bits t=
o BCMA_IOCTL

Hariprasad Shenai (1):
      cxgb4: Update Kconfig to include Chelsio T5 adapter

Heiko St=FCbner (2):
      arc_emac: fix probe error path
      arc_emac: add clock handling

Hiroaki SHIMODA (1):
      e1000e: Enclose e1000e_pm_thaw() with CONFIG_PM_SLEEP

Hubert Chaumette (1):
      net/phy: micrel: fix bugged test on device tree loading for ksz90=
21

Jack Morgenstein (1):
      net/mlx4_core: Adjust port number in qp_attach wrapper when detac=
hing

Jacob Keller (1):
      i40e: fix Timesync Tx interrupt handler code

Jakub Kicinski (2):
      ixgbe: clean up Rx time stamping code
      e1000e/igb/ixgbe/i40e: fix message terminations

Jean Delvare (1):
      net: cadence: Fix architecture dependencies

Jesse Brandeburg (1):
      i40e: fix TCP flag replication for hardware offload

Jiri Pirko (1):
      team: forbid incorrect fall-through in notifier

Johan Hedberg (2):
      Bluetooth: Fix triggering BR/EDR L2CAP Connect too early
      Bluetooth: Fix redundant encryption request for reauthentication

John Fastabend (1):
      net: sched: lock imbalance in hhf qdisc

John W. Linville (2):
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth=
/bluetooth
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Julia Lawall (1):
      hisax/icc: add missing semicolon after label

Julian Anastasov (1):
      net: ipv6: more places need LOOPBACK_IFINDEX for flowi6_iif

KY Srinivasan (1):
      hyperv: Properly handle checksum offload

Karl Heiss (1):
      net: sctp: Don't transition to PF state when transport has exhaus=
ted 'Path.Max.Retrans'.

Kumar Sundararajan (1):
      ipv6: fib: fix fib dump restart

Larry Finger (1):
      rtlwifi: rtl8192se: Fix regression due to commit 1bf4bbb

Liu Yu (1):
      tcp_cubic: fix the range of delayed_ack

Marcel Holtmann (1):
      Revert "Bluetooth: Enable autosuspend for Intel Bluetooth device"

Masanari Iida (1):
      net: bonding: Fix format string mismatch in bond_sysfs.c

Matan Barak (1):
      net/mlx4_core: Fix slave id computation for single port VF

Max Schwarz (1):
      arc_emac: write initial MAC address from devicetree to hw

Mohammed Habibulla (1):
      Bluetooth: Add support for Lite-on [04ca:3007]

Narender Kumar (1):
      bnx2x: Fix failure to configure VF multicast filters

Nicolas Dichtel (1):
      vxlan: ensure to advertise the right fdb remote

Oliver Hartkopp (3):
      can: sja1000_isa: add locking for indirect register access mode
      can: fix return value from can_get_bittiming()
      slip: fix spinlock variant

Or Gerlitz (1):
      net/mlx4_core: Load the Eth driver first

Rajesh Borundia (1):
      qlcnic: Fix memory leak.

Rajkumar Manoharan (1):
      ath9k: fix race in setting ATH_OP_INVALID

Roland Dreier (1):
      cxgb4: Decode PCIe Gen3 link speed

Sony Chacko (1):
      qlcnic: Reset firmware API lock at driver load time

Soren Brinkmann (5):
      net: macb: Pass same size to DMA_UNMAP as used for DMA_MAP
      net: macb: Clear interrupt flags
      net: macb: Re-enable RX interrupt only when RX is done
      net: macb: Remove 'unlikely' optimization
      net: macb: Fix race between HW and driver

Stanislaw Gruszka (1):
      rt2x00: fix beaconing on USB

Thomas Gleixner (21):
      can: c_can_pci: Set the type of the IP core
      can: c_can: Fix startup logic
      can: c_can: Make bus off interrupt disable logic work
      can: c_can: Do not access skb after net_receive_skb()
      can: c_can: Handle state change correctly
      can: c_can: Fix berr reporting
      can: c_can: Always update error stats
      can: c_can: Simplify buffer reenabling
      can: c_can: Avoid status register update for D_CAN
      can: c_can: Get rid of pointless interrupts
      can: c_can: Disable rx split as workaround
      can: c_can: Work around C_CAN RX wreckage
      can: c_can: Cleanup irq enable/disable
      can: c_can: Cleanup c_can_read_msg_object()
      can: c_can: Cleanup setup of receive buffers
      can: c_can: Cleanup c_can_inval_msg_object()
      can: c_can: Cleanup c_can_msg_obj_put/get()
      can: c_can: Cleanup c_can_write_msg_object()
      can: c_can: Use proper u32 variables in c_can_write_msg_object()
      can: c_can: Remove tx locking
      can: c_can: Speed up tx buffer invalidation

Tim Harvey (2):
      ath9k: fix possible hang on flush
      ath9k: add a recv budget

Tobias Klauser (2):
      Altera TSE: Fix DMA secriptor length initialization
      Altera TSE: Add missing include to silence sparse warnings

Todd Fujinaka (1):
      igb: fix stats for i210 rx_fifo_errors

Toshiaki Makita (1):
      bridge: Handle IFLA_ADDRESS correctly when creating bridge device

Vince Bridgers (4):
      Altera TSE: Work around unaligned DMA receive packet issue with A=
ltera SGDMA
      Altera TSE: Set the Pause Quanta value to the IEEE default value
      Altera TSE: Fix Panic in probe routine when phy probe fails
      Altera TSE: Change driver name used by Ethtool

Vlad Yasevich (3):
      e1000e: Correctly include VLAN_HLEN when changing interface MTU
      mactap: Fix checksum errors for non-gso packets in bridge mode
      Revert "macvlan : fix checksums error when we are in bridge mode"

Wolfgang Grandegger (1):
      can: c_can_pci: enable PCI bus master only for MSI

Wolfram Sang (1):
      can: c_can: use proper type for 'instance'

Xufeng Zhang (1):
      sctp: reset flowi4_oif parameter on route lookup

Ying Cai (1):
      ip_tunnel: Set network header properly for IP_ECN_decapsulate()

Yuval Mintz (2):
      bnx2x: Memory leak during VF removal
      bnx2x: Fix vlan credit issues for VFs

Zi Shen Lim (2):
      smc91x: fix compile error when SMC_DEBUG >=3D 2
      smc91x: improve definition of debug macros

 Documentation/devicetree/bindings/net/arc_emac.txt       |  12 +-
 Documentation/networking/scaling.txt                     |   2 +-
 MAINTAINERS                                              |   2 -
 crypto/crypto_user.c                                     |   2 +-
 drivers/bluetooth/ath3k.c                                |   2 +
 drivers/bluetooth/btusb.c                                |   5 +-
 drivers/connector/cn_proc.c                              |   2 +-
 drivers/isdn/hisax/icc.c                                 |   2 +-
 drivers/net/bonding/bond_sysfs.c                         |   2 +-
 drivers/net/can/c_can/Kconfig                            |   7 +
 drivers/net/can/c_can/c_can.c                            | 660 +++++++=
++++++++++++++++++++++++-----------------------------------
 drivers/net/can/c_can/c_can.h                            |  23 +--
 drivers/net/can/c_can/c_can_pci.c                        |   9 +-
 drivers/net/can/c_can/c_can_platform.c                   |   2 +-
 drivers/net/can/dev.c                                    |   2 +-
 drivers/net/can/sja1000/sja1000_isa.c                    |  16 +-
 drivers/net/can/slcan.c                                  |   6 +-
 drivers/net/ethernet/altera/Kconfig                      |   1 +
 drivers/net/ethernet/altera/altera_msgdma.c              |   8 +-
 drivers/net/ethernet/altera/altera_msgdma.h              |   3 +-
 drivers/net/ethernet/altera/altera_sgdma.c               | 179 +++++++=
+++--------
 drivers/net/ethernet/altera/altera_sgdma.h               |   3 +-
 drivers/net/ethernet/altera/altera_tse.h                 |   6 +-
 drivers/net/ethernet/altera/altera_tse_ethtool.c         |   8 +-
 drivers/net/ethernet/altera/altera_tse_main.c            |  77 ++++---=
-
 drivers/net/ethernet/arc/emac.h                          |   2 +
 drivers/net/ethernet/arc/emac_main.c                     |  82 ++++++-=
--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c         |   2 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c        |  58 ++++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h        |   4 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c         |   2 +-
 drivers/net/ethernet/cadence/Kconfig                     |   4 +-
 drivers/net/ethernet/cadence/macb.c                      |  35 ++--
 drivers/net/ethernet/chelsio/Kconfig                     |  13 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c          |   2 +
 drivers/net/ethernet/freescale/gianfar.c                 | 223 +++++++=
++++-----------
 drivers/net/ethernet/freescale/gianfar_ethtool.c         |   3 +
 drivers/net/ethernet/intel/e1000e/ich8lan.c              |  71 ++++---
 drivers/net/ethernet/intel/e1000e/ich8lan.h              |   3 +
 drivers/net/ethernet/intel/e1000e/netdev.c               |   6 +-
 drivers/net/ethernet/intel/e1000e/phy.h                  |   1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c              |  14 +-
 drivers/net/ethernet/intel/i40e/i40e_nvm.c               |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_ptp.c               |   4 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c              |  22 +--
 drivers/net/ethernet/intel/igb/e1000_i210.c              |   2 +-
 drivers/net/ethernet/intel/igb/e1000_mac.c               |  13 +-
 drivers/net/ethernet/intel/igb/igb_main.c                |   4 +-
 drivers/net/ethernet/intel/igb/igb_ptp.c                 |   4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h                 |  21 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c          |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c            |   3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c             |   6 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c             |  40 ++--
 drivers/net/ethernet/marvell/mvmdio.c                    |   5 +-
 drivers/net/ethernet/mellanox/mlx4/main.c                |   7 +-
 drivers/net/ethernet/mellanox/mlx4/port.c                |  35 ++--
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c    |  23 +++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c         |   9 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c |   9 +-
 drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h        |   2 +
 drivers/net/ethernet/samsung/sxgbe/sxgbe_core.c          |  22 +++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.c          |  11 +-
 drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.h          |  42 ++---
 drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c           |  13 --
 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c          |  31 ++++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_mdio.c          |  14 +-
 drivers/net/ethernet/samsung/sxgbe/sxgbe_reg.h           |   4 +
 drivers/net/ethernet/smsc/smc91x.c                       |  25 +--
 drivers/net/hyperv/netvsc_drv.c                          |   4 +
 drivers/net/macvlan.c                                    |   3 -
 drivers/net/macvtap.c                                    |   9 +
 drivers/net/phy/micrel.c                                 |   6 +-
 drivers/net/phy/phy.c                                    |  11 ++
 drivers/net/slip/slip.c                                  |   6 +-
 drivers/net/team/team.c                                  |   2 +
 drivers/net/usb/cdc_ncm.c                                |   2 +-
 drivers/net/usb/qmi_wwan.c                               |  28 +++
 drivers/net/virtio_net.c                                 |   2 +-
 drivers/net/vxlan.c                                      |  38 ++--
 drivers/net/wireless/ath/ath9k/ahb.c                     |   4 -
 drivers/net/wireless/ath/ath9k/ani.c                     |   6 +
 drivers/net/wireless/ath/ath9k/ath9k.h                   |   1 -
 drivers/net/wireless/ath/ath9k/debug_sta.c               |   5 +-
 drivers/net/wireless/ath/ath9k/init.c                    |   3 +
 drivers/net/wireless/ath/ath9k/pci.c                     |   5 -
 drivers/net/wireless/ath/ath9k/recv.c                    |   9 +-
 drivers/net/wireless/ath/ath9k/xmit.c                    |  14 +-
 drivers/net/wireless/brcm80211/brcmfmac/chip.c           |   5 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c                  |  22 ++-
 drivers/net/wireless/rtlwifi/rtl8188ee/trx.c             |   2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c              |   2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c             |   6 +
 drivers/scsi/scsi_netlink.c                              |   2 +-
 include/linux/netlink.h                                  |   7 +
 include/linux/sock_diag.h                                |   2 +-
 include/net/af_vsock.h                                   |   6 +-
 include/net/sock.h                                       |   5 +
 kernel/audit.c                                           |   4 +-
 net/bluetooth/hci_conn.c                                 |   9 +-
 net/bluetooth/hci_event.c                                |   6 +
 net/bridge/br_netlink.c                                  |  15 ++
 net/can/gw.c                                             |   4 +-
 net/core/filter.c                                        |  16 +-
 net/core/rtnetlink.c                                     |  53 ++++--
 net/core/sock.c                                          |  49 +++++
 net/core/sock_diag.c                                     |   4 +-
 net/dcb/dcbnl.c                                          |   2 +-
 net/decnet/dn_dev.c                                      |   4 +-
 net/decnet/dn_fib.c                                      |   4 +-
 net/decnet/netfilter/dn_rtmsg.c                          |   2 +-
 net/ipv4/ip_tunnel.c                                     |   2 +
 net/ipv4/tcp_cubic.c                                     |   2 +-
 net/ipv4/tcp_output.c                                    |  14 +-
 net/ipv6/ip6_fib.c                                       |   3 +-
 net/ipv6/ip6mr.c                                         |   2 +-
 net/ipv6/netfilter/ip6t_rpfilter.c                       |   1 +
 net/ipv6/route.c                                         |   2 +
 net/netfilter/nfnetlink.c                                |   3 +-
 net/netlink/af_netlink.c                                 |  75 +++++++=
-
 net/netlink/genetlink.c                                  |   2 +-
 net/packet/diag.c                                        |   7 +-
 net/phonet/pn_netlink.c                                  |   8 +-
 net/sched/act_api.c                                      |   2 +-
 net/sched/cls_api.c                                      |   2 +-
 net/sched/sch_api.c                                      |   6 +-
 net/sched/sch_hhf.c                                      |  11 +-
 net/sctp/protocol.c                                      |   7 +-
 net/sctp/sm_sideeffect.c                                 |   7 +-
 net/tipc/netlink.c                                       |   2 +-
 net/vmw_vsock/af_vsock.c                                 |  47 +++--
 net/xfrm/xfrm_user.c                                     |   2 +-
 tools/net/bpf_dbg.c                                      |   2 +-
 133 files changed, 1496 insertions(+), 1043 deletions(-)
