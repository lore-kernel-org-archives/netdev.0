From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 29 Aug 2016 01:44:54 -0400 (EDT)
Message-ID: <20160829.014454.1639600863534418545.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: 8bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Segregate namespaces properly in conntrack dumps, from Liping
   Zhang.

2) tcp listener refcount fix in netfilter tproxy, from Eric
   Dumazet.

3) Fix timeouts in qed driver due to xmit_more, from Yuval Mintz.

4) Fix use-after-free in tcp_xmit_retransmit_queue().

5) Userspace header fixups (use of __u32, missing includes, etc.)
   from Mikko Rapeli.

6) Further refinements to fragmentation wrt. gso and tunnels, from
   Shmulik Ladkani.

7) Trigger poll correctly for zero length UDP packets, from Eric
   Dumazet.

8) TCP window scaling fix, also from Eric Dumazet.

9) SLAB_DESTROY_BY_RCU is not relevant any more for UDP sockets.

10) Module refcount leak in qdisc_create_dflt(), from Eric Dumazet.

11) Fix deadlock in cp_rx_poll() of 8139cp driver, from Gao Feng.

12) Memory leak in rhashtable's alloc_bucket_locks(), from Eric
    Dumazet.

13) Add new device ID to alx driver, from Owen Lin.

Please pull, thanks a lot!

The following changes since commit 184ca823481c99dadd7d946e5afd4bb921eab30d:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2016-08-17 17:26:58 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to b99b43bb4bdf1d361f7487cf03d803082bbf9101:

  Add Killer E2500 device ID in alx driver. (2016-08-29 00:23:50 -0400)

----------------------------------------------------------------
Alexander Duyck (1):
      ixgbe: Do not clear RAR entry when clearing VMDq for SAN MAC

Amir Vadai (1):
      net/mlx5: Update last-use statistics for flow rules

Andrew Rybchenko (1):
      sfc: fix potential stack corruption from running past stat bitmask

Anjali Singhai Jain (1):
      i40e: Change some init flow for the client

Colin Ian King (2):
      net: tehuti: fix typo: "eneble" -> "enable"
      net: hns: dereference ppe_cb->ppe_common_cb if it is non-null

Daniel Borkmann (1):
      Bluetooth: split sk_filter in l2cap_sock_recv_cb

Daniel Romell (1):
      net: xilinx: emaclite: Fallback to random MAC address.

David Ahern (1):
      net: diag: Fix refcnt leak in error path destroying socket

David Daney (1):
      net: thunderx: Fix OOPs with ethtool --register-dump

David S. Miller (5):
      Merge git://git.kernel.org/.../pablo/nf
      Merge branch 'kaweth-oopses'
      Merge branch 'mlx5-fixes'
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/bluetooth
      Merge branch 'mlx5-series'

Eran Ben Elisha (2):
      net/mlx5e: Fix ethtool -g/G rx ring parameter report with striding RQ
      net/mlx5: Add error prints when validate ETS failed

Eric Dumazet (7):
      netfilter: tproxy: properly refcount tcp listeners
      tcp: fix use after free in tcp_xmit_retransmit_queue()
      udp: fix poll() issue with zero sized packets
      tcp: properly scale window in tcp_v[46]_reqsk_send_ack()
      udp: get rid of SLAB_DESTROY_BY_RCU allocations
      qdisc: fix a module refcount leak in qdisc_create_dflt()
      rhashtable: fix a memory leak in alloc_bucket_locks()

Fabio Estevam (1):
      net: lpc_eth: Check clk_prepare_enable() error

Florian Fainelli (2):
      net: dsa: bcm_sf2: Fix race condition while unmasking interrupts
      Documentation: networking: dsa: Remove platform device TODO

Frederic Dalleau (1):
      Bluetooth: Fix memory leak at end of hci requests

Gao Feng (2):
      l2tp: Fix the connect status check in pppol2tp_getname
      8139cp: Fix one possible deadloop in cp_rx_poll

Hadar Hen Zion (2):
      net/mlx5e: Use correct flow dissector key on flower offloading
      net/mlx5e: Retrieve the switchdev id from the firmware only once

Hariprasad Shenai (1):
      cxgb4: Fixes resource allocation for ULD's in kdump kernel

Ido Schimmel (1):
      mlxsw: spectrum: Add missing flood to router port

Jamal Hadi Salim (1):
      net sched: fix encoding to use real length

Jamie Lentin (1):
      net: mv88e6xxx: Fix ingress rate removal for mv6131 chips

Jiri Pirko (2):
      mlxsw: spectrum_buffers: Fix pool value handling in mlxsw_sp_sb_tc_pool_bind_set
      team: loadbalance: push lacpdus to exact delivery

Kamal Heib (1):
      net/mlx5e: Fix memory leak if refreshing TIRs fails

Lance Richardson (1):
      sctp: fix overrun in sctp_diag_dump_one()

Liping Zhang (5):
      netfilter: conntrack: do not dump other netns's conntrack entries via proc
      netfilter: nfnetlink_log: add "nf-logger-3-1" module alias name
      netfilter: nfnetlink_acct: report overquota to the right netns
      netfilter: nfnetlink_acct: fix race between nfacct del and xt_nfacct destroy
      netfilter: cttimeout: fix use after free error when delete netns

Luiz Augusto von Dentz (2):
      Bluetooth: Fix bt_sock_recvmsg when MSG_TRUNC is not set
      Bluetooth: Fix hci_sock_recvmsg when MSG_TRUNC is not set

Maor Gottlieb (1):
      net/mlx5: Increase number of ethtool steering priorities

Marcelo Ricardo Leitner (1):
      sctp: linearize early if it's not GSO

Mike Manning (1):
      net: ipv6: Remove addresses for failures with strict DAD

Mikko Rapeli (8):
      include/uapi/linux/if_pppox.h: include linux/if.h
      include/uapi/linux/if_tunnel.h: include linux/if.h, linux/ip.h and linux/in6.h
      include/uapi/linux/if_pppol2tp.h: include linux/in.h and linux/in6.h
      include/uapi/linux/if_pppox.h: include linux/in.h and linux/in6.h
      include/uapi/linux/openvswitch.h: use __u32 from linux/types.h
      include/uapi/linux/atm_zatm.h: include linux/time.h
      include/uapi/linux/openvswitch.h: use __u32 from linux/types.h
      include/uapi/linux/ipx.h: fix conflicting defitions with glibc netipx/ipx.h

Mohamad Haj Yahia (1):
      net/mlx5: Fix pci error recovery flow

Oliver Neukum (2):
      kaweth: fix firmware download
      kaweth: fix oops upon failed memory allocation

Or Gerlitz (3):
      net/mlx5: E-Switch, Return the correct devlink e-switch mode
      net/mlx5: E-Switch, Set the send-to-vport rules in the correct table
      net/mlx5: E-Switch, Avoid ACLs in the offloads mode

Owen Lin (1):
      Add Killer E2500 device ID in alx driver.

Paul Blakey (1):
      net/mlx5: Added missing check of msg length in verifying its signature

Rabin Vincent (1):
      dwc_eth_qos: fix interrupt enable race

Rafa©© Mi©©ecki (1):
      net: bgmac: fix reversed check for MII registration error

Russell King (1):
      net: smc91x: fix SMC accesses

Saeed Mahameed (5):
      net/mlx5e: Set port MTU on netdev creation rather on open
      net/mlx5e: Limit UMR length to the device's limitation
      net/mlx5e: Don't wait for RQ completions on close
      net/mlx5e: Don't post fragmented MPWQE when RQ is disabled
      net/mlx5e: Don't wait for SQ completions on close

Shmulik Ladkani (1):
      net: ip_finish_output_gso: Allow fragmenting segments of tunneled skbs if their DF is unset

Shrikrishna Khare (1):
      vmxnet3: fix tx data ring copy for variable size

Soheil Hassas Yeganeh (1):
      tun: fix transmit timestamp support

Tariq Toukan (2):
      net/mlx5e: Optimization for MTU change
      net/mlx5e: Add ethtool counter for TX xmit_more

Wei Yongjun (1):
      tipc: fix the error handling in tipc_udp_enable()

Xander Huff (2):
      phy: micrel: Reenable interrupts during resume for ksz9031
      Revert "phy: IRQ cannot be shared"

Xunlei Pang (1):
      fib_trie: Fix the description of pos and bits

Yotam Gigi (1):
      mlxsw: router: Enable neighbors to be created on stacked devices

Yuval Mintz (2):
      qede: Fix Tx timeout due to xmit_more
      qed: FLR of active VFs might lead to FW assert

Zefir Kurtisi (2):
      gianfar: prevent fragmentation in DSA environments
      gianfar: fix size of scatter-gathered frames

 Documentation/networking/dsa/dsa.txt                       |  20 --------
 arch/arm/mach-pxa/idp.c                                    |   3 +-
 arch/arm/mach-pxa/xcep.c                                   |   3 +-
 arch/arm/mach-realview/core.c                              |   3 +-
 arch/arm/mach-sa1100/pleb.c                                |   2 +-
 arch/blackfin/mach-bf561/boards/cm_bf561.c                 |   3 +-
 arch/blackfin/mach-bf561/boards/ezkit.c                    |   3 +-
 drivers/net/dsa/bcm_sf2.h                                  |   2 +-
 drivers/net/dsa/mv88e6xxx/chip.c                           |   8 ++-
 drivers/net/ethernet/atheros/alx/main.c                    |   2 +
 drivers/net/ethernet/atheros/alx/reg.h                     |   1 +
 drivers/net/ethernet/broadcom/bgmac-bcma.c                 |   2 +-
 drivers/net/ethernet/cavium/thunder/nic_reg.h              |   1 -
 drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c        |   5 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c            |  10 ++--
 drivers/net/ethernet/freescale/gianfar.c                   |  20 +++++---
 drivers/net/ethernet/freescale/gianfar.h                   |   3 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c          |   3 +-
 drivers/net/ethernet/intel/i40e/i40e_client.c              |  41 +++++++++++-----
 drivers/net/ethernet/intel/i40e/i40e_main.c                |   1 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c            |   4 +-
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c              |  85 ++++++++++++++++++++------------
 drivers/net/ethernet/mellanox/mlx5/core/en.h               |  21 ++++----
 drivers/net/ethernet/mellanox/mlx5/core/en_common.c        |   7 +--
 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c         |  21 ++++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c       |  93 ++++++++++++++++++++++++++++++++---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c          | 112 ++++++++++++++++++++----------------------
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c           |   5 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c            |  41 ++++++----------
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h         |   4 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c            |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c            |  68 ++++++++++++-------------
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c          |   6 ++-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c          |  16 +++---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h          |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c |  26 +++++++---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c          |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c      |  11 ++++-
 drivers/net/ethernet/mellanox/mlx5/core/main.c             |  59 +++++++++++-----------
 drivers/net/ethernet/mellanox/mlxsw/port.h                 |   1 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c             |  43 +++++++++++++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c     |  12 ++---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c      |   2 +-
 drivers/net/ethernet/nxp/lpc_eth.c                         |  20 ++++----
 drivers/net/ethernet/qlogic/qed/qed.h                      |  11 ++++-
 drivers/net/ethernet/qlogic/qede/qede_main.c               |   5 +-
 drivers/net/ethernet/realtek/8139cp.c                      |   2 +-
 drivers/net/ethernet/sfc/ef10.c                            |   3 +-
 drivers/net/ethernet/smsc/smc91x.c                         |   7 +++
 drivers/net/ethernet/smsc/smc91x.h                         |  65 ++++++++++++++++--------
 drivers/net/ethernet/synopsys/dwc_eth_qos.c                |  17 ++++---
 drivers/net/ethernet/tehuti/tehuti.c                       |   2 +-
 drivers/net/ethernet/xilinx/xilinx_emaclite.c              |   8 +--
 drivers/net/phy/micrel.c                                   |   2 +-
 drivers/net/phy/phy.c                                      |   6 ++-
 drivers/net/team/team_mode_loadbalance.c                   |  15 ++++++
 drivers/net/tun.c                                          |   6 +--
 drivers/net/usb/kaweth.c                                   |  10 ++--
 drivers/net/vmxnet3/vmxnet3_drv.c                          |   4 +-
 drivers/net/vmxnet3/vmxnet3_int.h                          |   4 +-
 include/linux/netfilter/nfnetlink_acct.h                   |   4 +-
 include/linux/smc91x.h                                     |  10 ++++
 include/net/tcp.h                                          |   2 +
 include/uapi/linux/atm_zatm.h                              |   1 +
 include/uapi/linux/if_pppol2tp.h                           |   3 +-
 include/uapi/linux/if_pppox.h                              |   3 ++
 include/uapi/linux/if_tunnel.h                             |   3 ++
 include/uapi/linux/ipx.h                                   |  13 ++++-
 include/uapi/linux/libc-compat.h                           |  26 ++++++++++
 include/uapi/linux/openvswitch.h                           |   6 +--
 lib/rhashtable.c                                           |   7 +--
 net/bluetooth/af_bluetooth.c                               |   2 +-
 net/bluetooth/hci_request.c                                |   2 +
 net/bluetooth/hci_sock.c                                   |   2 +-
 net/bluetooth/l2cap_core.c                                 |   8 +++
 net/bluetooth/l2cap_sock.c                                 |  14 +++++-
 net/ipv4/fib_trie.c                                        |   4 +-
 net/ipv4/ip_tunnel_core.c                                  |   8 +--
 net/ipv4/tcp.c                                             |   2 -
 net/ipv4/tcp_diag.c                                        |   7 ++-
 net/ipv4/tcp_ipv4.c                                        |   8 ++-
 net/ipv4/udp.c                                             |  13 +++--
 net/ipv4/udplite.c                                         |   1 -
 net/ipv6/addrconf.c                                        |  34 ++++++++-----
 net/ipv6/tcp_ipv6.c                                        |   8 ++-
 net/ipv6/udp.c                                             |   1 -
 net/ipv6/udplite.c                                         |   1 -
 net/l2tp/l2tp_ppp.c                                        |   2 +-
 net/netfilter/nf_conntrack_standalone.c                    |   4 ++
 net/netfilter/nfnetlink_acct.c                             |  17 ++++---
 net/netfilter/nfnetlink_cttimeout.c                        |  16 +++---
 net/netfilter/nfnetlink_log.c                              |   1 +
 net/netfilter/xt_TPROXY.c                                  |   4 ++
 net/netfilter/xt_nfacct.c                                  |   2 +-
 net/sched/act_ife.c                                        |  18 ++++---
 net/sched/sch_generic.c                                    |   9 ++--
 net/sctp/input.c                                           |  11 +++--
 net/sctp/inqueue.c                                         |  13 -----
 net/sctp/sctp_diag.c                                       |   6 ++-
 net/tipc/udp_media.c                                       |   5 +-
 100 files changed, 813 insertions(+), 453 deletions(-)
