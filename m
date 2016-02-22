From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sun, 21 Feb 2016 23:07:52 -0500 (EST)
Message-ID: <20160221.230752.254208727879789647.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Looks like a lot, but mostly driver fixes scattered all over
as usual.  Of note:

1) Add conditional sched in nf conntrack in cleanup to avoid
   NMI watchdogs.  From Florian Westphal.

2) Fix deadlock in nfnetlink cttimeout, also from Floarian.

3) Fix handling of slaves in bonding ARP monitor validation, from
   Jay Vosburgh.

4) Callers of ip_cmsg_send() are responsible for freeing IP options,
   some were not doing so.  Fix from Eric Dumazet.

5) Fix per-cpu bugs in mvneta driver, from Gregory CLEMENT.

6) Fix vlan handling in mv88e6xxx DSA driver, from Vivien Didelot.

7) bcm7xxx PHY driver bug fixes from Florian Fainelli.

8) Avoid unaligned accesses to protocol headers wrt. GRE, from
   Alexander Duyck.

9) SKB leaks and other problems in arc_emac driver, from Alexander
   Kochetkov.

10) tcp_v4_inbound_md5_hash() releases listener socket instead of
    request socket on error path, oops.  Fix from Eric Dumazet.

11) Missing socket release in pppoe_rcv_core() that seems to have
    existed basically forever.  From Guillaume Nault.

12) Missing slave_dev unregister in dsa_slave_create() error path,
    from Florian Fainelli.

13) crypto_alloc_hash() never returns NULL, fix return value check
    in __tcp_alloc_md5sig_pool.  From Insu Yun.

14) Properly expire exception route entries in ipv4, from Xin Long.

15) Fix races in tcp/dccp listener socket dismantle, from Eric
    Dumazet.

16) Don't set IFF_TX_SKB_SHARING in vxlan, geneve, or GRE, it's
    not legal.  These drivers modify the SKB on transmit. From
    Jiri Benc.

17) Fix regression in the initialziation of netdev->tx_queue_len.
    From Phil Sutter.

18) Missing unlock in tipc_nl_add_bc_link() error path, from Insu Yun.

19) SCTP port hash sizing does not properly ensire that table is
    a power of two in size.  From Neil Horman.

20) Fix initializing of software copy of MAC address in fmvj18x_cs
    driver, from Ken Kawasaki.

Please pull, thanks a lot!

The following changes since commit c05235d50f681bf685e7290cae05ab3b4fa4=
93f3:

  Merge tag 'gpio-v4.5-2' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linusw/linux-gpio (2016-02-11 11:25:55 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net=20

for you to fetch changes up to d856626d3b051a3ad7139ba59463b692c131f844=
:

  Merge tag 'linux-can-fixes-for-4.5-20160221' of git://git.kernel.org/=
pub/scm/linux/kernel/git/mkl/linux-can (2016-02-21 22:51:55 -0500)

----------------------------------------------------------------
Alexander Duyck (1):
      net: Copy inner L3 and L4 headers as unaligned on GRE TEB

Alexander Kochetkov (3):
      net: arc_emac: fix koops caused by sk_buff free
      net: arc_emac: reset txbd_curr and txbd_dirty pointers to zero
      net: arc_emac: fix sk_buff leak

Amir Vadai (1):
      net/mlx4_en: Count HW buffer overrun only once

Amitoj Kaur Chawla (3):
      net: cavium: liquidio: Return correct error code
      net: mvpp2: Return correct error codes
      lance: Return correct error code

Andrew Lunn (1):
      batman-adv: Avoid endless loop in bat-on-bat netdevice check

Anton Protopopov (6):
      netfilter: nft_counter: fix erroneous return values
      iwlwifi: pcie: fix erroneous return value
      appletalk: fix erroneous return value
      net: caif: fix erroneous return value
      mISDN: prevent possible NULL pointer dereference
      rtnl: RTM_GETNETCONF: fix wrong return value

Arnd Bergmann (4):
      netfilter: tee: select NF_DUP_IPV6 unconditionally
      net: am79c961a: avoid %? in inline assembly
      bridge: mdb: avoid uninitialized variable warning
      USB: cdc_subset: only build when one driver is enabled

Bj=F8rn Mork (1):
      qmi_wwan: add "4G LTE usb-modem U901"

Chun-Hao Lin (1):
      r8169:fix system hange problem.

Clemens Gruber (1):
      phy: marvell: Fix and unify reg-init behavior

Colin Ian King (1):
      net: cavium: liquidio: fix check for in progress flag

Daniel Jurgens (1):
      net/mlx4_core: Do not BUG_ON during reset when PCI is offline

David Rivshin (1):
      drivers: net: cpsw-phy-sel: add dev_warn() for unsupported PHY mo=
de

David S. Miller (18):
      Merge branch 'mvneta-fixes'
      Merge git://git.kernel.org/.../pablo/nf
      Merge branch 'ravb-fixes'
      Merge branch 'bcm7xxx-fixes'
      Merge branch 'mlx5-fixes'
      Merge branch 'arc_emac-fixes'
      Merge branch 'bnxt_en-fixes'
      Merge branch 'mlx4-fixes'
      Merge branch 'mlxsw-fixes'
      Merge branch 'thunderx-fixes'
      Merge branch 'mlxsw-fixes'
      Merge tag 'batman-adv-fix-for-davem' of git://git.open-mesh.org/l=
inux-merge
      Merge tag 'wireless-drivers-for-davem-2016-02-18' of git://git.ke=
rnel.org/.../kvalo/wireless-drivers
      Merge branch 'bnxt_en-fixes'
      Merge branch 'netcp-fixes'
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth=
/bluetooth
      Merge branch 'bnx2x-848xx-phy-fixes'
      Merge tag 'linux-can-fixes-for-4.5-20160221' of git://git.kernel.=
org/.../mkl/linux-can

David Wragg (1):
      geneve: Refine MTU limit

Dmitry V. Levin (1):
      unix_diag: fix incorrect sign extension in unix_lookup_by_ino

Douglas Anderson (1):
      Bluetooth: hci_core: Avoid mixing up req_complete and req_complet=
e_skb

Emil Goode (1):
      wlcore: Fix regression in wlcore_set_partition()

Emmanuel Grumbach (2):
      iwlwifi: dvm: remove a wrong dependency on m
      iwlwifi: pcie: fix RF-Kill vs. firmware load race

Eran Ben Elisha (1):
      net/mlx4_core: Fix potential corruption in counters database

Eric Dumazet (4):
      ipv4: fix memory leaks in ip_cmsg_send() callers
      tcp: do not set rtt_min to 1
      tcp: md5: release request socket instead of listener
      tcp/dccp: fix another race at listener dismantle

Eugenia Emantayev (2):
      net/mlx4_en: Choose time-stamping shift value according to HW fre=
quency
      net/mlx4_en: Avoid changing dev->features directly in run-time

=46lorian Fainelli (5):
      net: phy: bcm7xxx: Fix shadow mode 2 disabling
      net: phy: bcm7xxx: Fix 40nm EPHY features
      net: phy: bcm7xxx: Fix bcm7xxx_config_init() check
      net: phy: bcm7xxx: Remove wildcard entries
      net: dsa: Unregister slave_dev in error path

=46lorian Westphal (2):
      netfilter: conntrack: resched in nf_ct_iterate_cleanup
      netfilter: cttimeout: fix deadlock due to erroneous unlock/lock c=
onversion

Geert Uytterhoeven (1):
      ravb: Update DT binding example for final CPG/MSSR bindings

Gerhard Uttenthaler (1):
      can: ems_usb: Fix possible tx overflow

Gregory CLEMENT (7):
      net: mvneta: Fix for_each_present_cpu usage
      net: mvneta: Fix the CPU choice in mvneta_percpu_elect
      net: mvneta: Use on_each_cpu when possible
      net: mvneta: Remove unused code
      net: mvneta: Modify the queue related fields from each cpu
      net: mvneta: The mvneta_percpu_elect function should be atomic
      net: mvneta: Fix race condition during stopping

Guillaume Nault (1):
      pppoe: fix reference counting in PPPoE proxy

Hariprasad Shenai (1):
      cxgb4: Add pci device id for chelsio t540 lom adapter

Huy Nguyen (1):
      net/mlx4_core: Set UAR page size to 4KB regardless of system page=
 size

Ian Campbell (1):
      MAINTAINERS: Drop myself as xen netback maintainer

Ido Schimmel (4):
      mlxsw: Treat local port 64 as valid
      mlxsw: spectrum: Set STP state when leaving 802.1D bridge
      mlxsw: reg: Add the Switch Port Acceptable Frame Types register
      mlxsw: spectrum: Allow for PVID deletion

Insu Yun (3):
      tcp: correctly crypto_alloc_hash return check
      et131x: check return value of dma_alloc_coherent
      tipc: unlock in error path

Jaedon Shin (1):
      net: bcmgenet: Fix internal PHY link state

Jamal Hadi Salim (1):
      net_sched fix: reclassification needs to consider ether protocol =
changes

Jay Vosburgh (2):
      bonding: Fix ARP monitor validation
      bonding: don't use stale speed and duplex information

Jiri Benc (4):
      vxlan: clear IFF_TX_SKB_SHARING
      geneve: clear IFF_TX_SKB_SHARING
      gre: clear IFF_TX_SKB_SHARING
      vxlan: do not use fdb in metadata mode

Jon Paul Maloy (1):
      tipc: fix premature addition of node to lookup table

Kalle Valo (1):
      Merge tag 'iwlwifi-for-kalle-2016-02-15' of https://git.kernel.or=
g/.../iwlwifi/iwlwifi-fixes

Karicheri, Muralidharan (3):
      net: ti: netcp: restore get/set_pad_info() functionality
      soc: ti: knav_dma: rename pad in struct knav_dma_desc to sw_data
      net: netcp: rework the code for get/set sw_data in dma desc

Ken Kawasaki (2):
      pcnet_cs: add new id
      fmvj18x_cs: fix incorrect indexing of dev->dev_addr[] when copyin=
g the MAC address

Larry Finger (1):
      rtlwifi: fix broken VHT support

Laura Abbott (1):
      vsock: Fix blocking ops call in prepare_to_wait

Luca Coelho (1):
      iwlwifi: mvm: don't allow sched scans without matches to be start=
ed

Mark Tomlinson (1):
      l2tp: Fix error creating L2TP tunnels

Matan Barak (1):
      net/mlx5: Use offset based reserved field names in the IFC header=
 file

Michael Chan (8):
      bnxt_en: Fix ethtool autoneg logic.
      bnxt_en: Cleanup and Fix flow control setup logic
      bnxt_en: Remove 20G support and advertise only 40GbaseCR4.
      bnxt_en: Fix implementation of tx push operation.
      bnxt_en: Reduce default ring sizes.
      bnxt_en: Poll link at the end of __bnxt_open_nic().
      bnxt_en: Remove unnecessary call to update PHY settings.
      bnxt_en: Failure to update PHY is not fatal condition.

Michael McConville (1):
      dscc4: Undefined signed int shift

Neil Horman (1):
      sctp: Fix port hash table size computation

Nikolay Aleksandrov (1):
      net: make netdev_for_each_lower_dev safe for device removal

Oren Givon (1):
      iwlwifi: fix name of ucode loaded for 8265 series

Pablo Neira Ayuso (1):
      netfilter: nfnetlink: use original skbuff when acking batches

Paolo Abeni (1):
      lwt: fix rx checksum setting for lwt devices tunneling over ipv6

Paul Bolle (1):
      ser_gigaset: use container_of() instead of detour

Phil Sutter (1):
      IFF_NO_QUEUE: Fix for drivers not calling ether_setup()

Phil Turnbull (1):
      netfilter: nfnetlink: correctly validate length of batch messages

Rainer Weikusat (3):
      af_unix: Don't set err in unix_stream_read_generic unless there w=
as an error
      af_unix: Guard against other =3D=3D sk in unix_dgram_sendmsg
      af_unix: Don't use continue to re-execute unix_stream_read_generi=
c loop

Robert Jarzmik (2):
      net: smc91x: propagate irq return code
      net: ethernet: davicom: fix devicetree irq resource

Saeed Mahameed (2):
      net/mlx5e: Remove select queue ndo initialization
      net/mlx5e: Use static constant netdevice ndos

Sascha Hauer (2):
      net: dsa: mv88e6xxx: Add support for Marvell 88E6240
      net: dsa: remove phy_disconnect from error path

Sergei Shtylyov (2):
      ravb: kill duplicate setting of CCC.CSEL
      ravb: skip gPTP start/stop on R-Car gen3

Shrikrishna Khare (1):
      Driver: Vmxnet3: Update Rx ring 2 max size

Steve Wise (1):
      cxgb3: fix up vpd strings for kstrto*()

Sunil Goutham (3):
      net: thunderx: Fix for multiqset not configured upon interface to=
ggle
      net: thunderx: Fix for HW TSO not enabled for secondary qsets
      net: thunderx: Fix receive packet stats

Sven Eckelmann (2):
      batman-adv: Only put gw_node list reference when removed
      batman-adv: Only put orig_node_vlan list reference when removed

Vitaly Kuznetsov (1):
      hv_netvsc: Restore needed_headroom request

Vivien Didelot (2):
      net: dsa: mv88e6xxx: fix software VLAN deletion
      net: dsa: mv88e6xxx: do not leave reserved VLANs

Woojung.Huh@microchip.com (1):
      phy: keep pause flags in phy driver features

Xin Long (1):
      route: check and remove route cache when we get route

Yuval Mintz (5):
      bnx2x: Fix link-forcing for KR2
      bnx2x: Fix 84833 RX CRC
      bnx2x: Correct 84858 PHY fw version
      bnx2x: Fix led setting for 84858 phy.
      bnx2x: Fix 84833 phy command handler

 Documentation/devicetree/bindings/net/renesas,ravb.txt   |    4 +-
 MAINTAINERS                                              |    1 -
 drivers/infiniband/hw/mlx4/qp.c                          |    7 +-
 drivers/isdn/gigaset/ser-gigaset.c                       |    9 +-
 drivers/isdn/hardware/mISDN/netjet.c                     |    2 +-
 drivers/net/bonding/bond_main.c                          |   40 +-
 drivers/net/can/usb/ems_usb.c                            |   14 +-
 drivers/net/dsa/mv88e6352.c                              |    1 +
 drivers/net/dsa/mv88e6xxx.c                              |   27 +-
 drivers/net/ethernet/8390/pcnet_cs.c                     |    1 +
 drivers/net/ethernet/agere/et131x.c                      |    2 +-
 drivers/net/ethernet/amd/am79c961a.c                     |   64 +-
 drivers/net/ethernet/amd/lance.c                         |    4 +-
 drivers/net/ethernet/arc/emac_main.c                     |   74 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c         |  299 ++++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h          |    6 +
 drivers/net/ethernet/broadcom/bnxt/bnxt.c                |   71 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.h                |   15 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c        |   46 +-
 drivers/net/ethernet/broadcom/genet/bcmgenet.c           |    3 +-
 drivers/net/ethernet/cavium/liquidio/lio_main.c          |    4 +-
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c       |    2 +-
 drivers/net/ethernet/cavium/thunder/nicvf_main.c         |   18 +-
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c       |    8 +-
 drivers/net/ethernet/cavium/thunder/nicvf_queues.h       |    3 +-
 drivers/net/ethernet/chelsio/cxgb3/t3_hw.c               |   34 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h       |    1 +
 drivers/net/ethernet/davicom/dm9000.c                    |   34 +-
 drivers/net/ethernet/fujitsu/fmvj18x_cs.c                |    4 +-
 drivers/net/ethernet/marvell/mvneta.c                    |  184 +--
 drivers/net/ethernet/marvell/mvpp2.c                     |    4 +-
 drivers/net/ethernet/mellanox/mlx4/catas.c               |   11 +-
 drivers/net/ethernet/mellanox/mlx4/cq.c                  |    4 +-
 drivers/net/ethernet/mellanox/mlx4/en_clock.c            |   25 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c           |    9 +-
 drivers/net/ethernet/mellanox/mlx4/en_port.c             |    4 +-
 drivers/net/ethernet/mellanox/mlx4/en_resources.c        |    3 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c               |    4 +-
 drivers/net/ethernet/mellanox/mlx4/eq.c                  |    7 +-
 drivers/net/ethernet/mellanox/mlx4/main.c                |   56 +-
 drivers/net/ethernet/mellanox/mlx4/pd.c                  |   12 +-
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c    |   10 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c        |   44 +-
 drivers/net/ethernet/mellanox/mlxsw/port.h               |    2 +-
 drivers/net/ethernet/mellanox/mlxsw/reg.h                |   58 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c           |   10 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h           |    1 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c |   69 +-
 drivers/net/ethernet/realtek/r8169.c                     |   14 +-
 drivers/net/ethernet/renesas/ravb_main.c                 |   16 +-
 drivers/net/ethernet/smsc/smc91x.c                       |    4 +-
 drivers/net/ethernet/ti/cpsw-phy-sel.c                   |   12 +-
 drivers/net/ethernet/ti/netcp_core.c                     |  105 +-
 drivers/net/geneve.c                                     |   31 +-
 drivers/net/hyperv/netvsc_drv.c                          |    3 +
 drivers/net/phy/bcm7xxx.c                                |   43 +-
 drivers/net/phy/marvell.c                                |   15 +-
 drivers/net/phy/phy_device.c                             |    2 +-
 drivers/net/ppp/pppoe.c                                  |    2 +
 drivers/net/usb/Kconfig                                  |   10 +
 drivers/net/usb/Makefile                                 |    2 +-
 drivers/net/usb/qmi_wwan.c                               |    1 +
 drivers/net/vmxnet3/vmxnet3_defs.h                       |    2 +-
 drivers/net/vmxnet3/vmxnet3_int.h                        |    4 +-
 drivers/net/vxlan.c                                      |    9 +-
 drivers/net/wan/dscc4.c                                  |    2 +-
 drivers/net/wireless/intel/iwlwifi/Kconfig               |    1 -
 drivers/net/wireless/intel/iwlwifi/iwl-8000.c            |   42 +-
 drivers/net/wireless/intel/iwlwifi/iwl-drv.c             |    6 +-
 drivers/net/wireless/intel/iwlwifi/mvm/scan.c            |    4 +
 drivers/net/wireless/intel/iwlwifi/pcie/internal.h       |    9 +
 drivers/net/wireless/intel/iwlwifi/pcie/rx.c             |    8 +-
 drivers/net/wireless/intel/iwlwifi/pcie/trans.c          |  188 +--
 drivers/net/wireless/realtek/rtlwifi/rc.c                |    5 +
 drivers/net/wireless/ti/wlcore/io.c                      |    8 +-
 drivers/net/wireless/ti/wlcore/io.h                      |    4 +-
 include/linux/mlx4/device.h                              |   13 +
 include/linux/mlx5/mlx5_ifc.h                            | 2968 ++++++=
++++++++++++++++-----------------------
 include/linux/netdevice.h                                |    2 +-
 include/linux/soc/ti/knav_dma.h                          |    4 +-
 include/net/inet_connection_sock.h                       |    5 +-
 include/net/ip_fib.h                                     |    1 +
 net/appletalk/ddp.c                                      |    2 +-
 net/batman-adv/gateway_client.c                          |    7 +-
 net/batman-adv/hard-interface.c                          |   25 +
 net/batman-adv/translation-table.c                       |    6 +-
 net/bluetooth/hci_core.c                                 |    6 +-
 net/bridge/br_mdb.c                                      |    4 +-
 net/caif/cfrfml.c                                        |    2 +-
 net/core/dev.c                                           |    8 +-
 net/core/flow_dissector.c                                |    7 +
 net/dccp/ipv4.c                                          |   14 +-
 net/dccp/ipv6.c                                          |   14 +-
 net/dsa/slave.c                                          |    2 +-
 net/ipv4/devinet.c                                       |    2 +-
 net/ipv4/inet_connection_sock.c                          |   14 +-
 net/ipv4/ip_gre.c                                        |    5 +-
 net/ipv4/ip_sockglue.c                                   |    2 +
 net/ipv4/ping.c                                          |    4 +-
 net/ipv4/raw.c                                           |    4 +-
 net/ipv4/route.c                                         |   77 +-
 net/ipv4/tcp.c                                           |    2 +-
 net/ipv4/tcp_input.c                                     |    5 +-
 net/ipv4/tcp_ipv4.c                                      |   20 +-
 net/ipv4/udp.c                                           |    4 +-
 net/ipv6/addrconf.c                                      |    2 +-
 net/ipv6/ip6_gre.c                                       |    1 +
 net/ipv6/netfilter/nf_nat_masquerade_ipv6.c              |   74 +-
 net/ipv6/tcp_ipv6.c                                      |   14 +-
 net/l2tp/l2tp_netlink.c                                  |   18 +-
 net/netfilter/Kconfig                                    |    2 +-
 net/netfilter/nf_conntrack_core.c                        |    5 +
 net/netfilter/nfnetlink.c                                |   16 +-
 net/netfilter/nfnetlink_cttimeout.c                      |    2 +-
 net/netfilter/nft_counter.c                              |    4 +-
 net/netfilter/xt_TEE.c                                   |    4 +-
 net/openvswitch/vport-vxlan.c                            |    2 +-
 net/sched/sch_api.c                                      |    1 +
 net/sctp/protocol.c                                      |   46 +-
 net/tipc/link.c                                          |    4 +-
 net/tipc/node.c                                          |   12 +-
 net/unix/af_unix.c                                       |   26 +-
 net/unix/diag.c                                          |    2 +-
 net/vmw_vsock/af_vsock.c                                 |   19 +-
 124 files changed, 3110 insertions(+), 2240 deletions(-)
