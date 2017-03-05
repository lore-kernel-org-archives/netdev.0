From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sat, 04 Mar 2017 16:50:00 -0800 (PST)
Message-ID: <20170304.165000.776929617922192240.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix double-free in batman-adv, from Sven Eckelmann.

2) Fix packet stats for fast-RX path, from Joannes Berg.

3) Netfilter's ip_route_me_harder() doesn't handle request sockets
   properly, fix from Florian Westphal.

4) Fix sendmsg deadlock in rxrpc, from David Howells.

5) Add missing RCU locking to transport hashtable scan, from
   Xin Long.

6) Fix potential packet loss in mlxsw driver, from Ido Schimmel.

7) Fix race in NAPI handling between poll handlers and busy polling,
   from Eric Dumazet.

8) TX path in vxlan and geneve need proper RCU locking, from Jakub
   Kicinski.

9) SYN processing in DCCP and TCP need to disable BH, from Eric
   Dumazet.

10) Properly handle net_enable_timestamp() being invoked from IRQ
    context, also from Eric Dumazet.

11) Fix crash on device-tree systems in xgene driver, from Alban
    Bedel.

12) Do not call sk_free() on a locked socket, from Arnaldo Carvalho de
    Melo.

13) Fix use-after-free in netvsc driver, from Dexuan Cui.

14) Fix max MTU setting in bonding driver, from WANG Cong.

15) xen-netback hash table can be allocated from softirq
    context, so use GFP_ATOMIC.  From Anoob Soman.

16) Fix MAC address change bug in bgmac driver, from Hari Vyas.

17) strparser needs to destroy strp_wq on module exit, from WANG Cong.

Please pull, thanks a lot!

The following changes since commit 2d6be4abf514fc26c83d239c7f31da1f95e4a31d:

  Merge tag 'for-linus-4.11' of git://git.code.sf.net/p/openipmi/linux-ipmi (2017-02-28 21:06:30 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to f78ef7cd9a0686b979679d0de061c6dbfd8d649e:

  strparser: destroy workqueue on module exit (2017-03-03 20:43:26 -0800)

----------------------------------------------------------------
Alban Bedel (1):
      drivers: net: xgene: Fix crash on DT systems

Alexander Duyck (1):
      ixgbe: Limit use of 2K buffers on architectures with 256B or larger cache lines

Alexander Potapenko (1):
      net: don't call strlen() on the user buffer in packet_bind_spkt()

Anoob Soman (1):
      xen-netback: Use GFP_ATOMIC to allocate hash

Arnaldo Carvalho de Melo (2):
      dccp: Unlock sock before calling sk_free()
      net: Introduce sk_clone_lock() error path routine

Baruch Siach (1):
      MAINTAINERS: Orphan usb/net/hso driver

Christophe Leroy (1):
      netfilter: nf_conntrack_sip: fix wrong memory initialisation

Colin Ian King (1):
      net: usb: asix_devices: fix missing return code check on call to asix_write_medium_mode

Dan Carpenter (1):
      net/mlx4: && vs & typo

David Howells (2):
      rxrpc: Fix deadlock between call creation and sendmsg/recvmsg
      rxrpc: Fix potential NULL-pointer exception

David S. Miller (13):
      Merge branch 'vxlan-geneve-rcu-fixes'
      Merge tag 'mac80211-for-davem-2017-02-28' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'amd-xgbe-fixes'
      Merge tag 'batadv-net-for-davem-20170301' of git://git.open-mesh.org/linux-merge
      Merge tag 'wireless-drivers-for-davem-2017-03-02' of git://git.kernel.org/.../kvalo/wireless-drivers
      Merge tag 'mac80211-for-davem-2017-03-02' of git://git.kernel.org/.../jberg/mac80211
      Merge branch '10GbE' of git://git.kernel.org/.../jkirsher/net-queue
      Merge branch 'xen-netback-fixes'
      Merge branch 'bgmac-fixes'
      Merge branch 'nfp-fixes'
      Merge tag 'linux-can-fixes-for-4.11-20170303' of git://git.kernel.org/.../mkl/linux-can
      Merge branch 'sfx-fixes'
      Merge git://git.kernel.org/.../pablo/nf

Dexuan Cui (1):
      netvsc: fix use-after-free in netvsc_change_mtu()

Dmitry Torokhov (1):
      drivers: net: ethernet: remove incorrect __exit markups

Edward Cree (2):
      sfc: avoid max() in array size
      sfc: fix IPID endianness in TSOv2

Emmanuel Grumbach (1):
      mac80211: fix power saving clients handling in iwlwifi

Eric Dumazet (4):
      net: solve a NAPI race
      tcp/dccp: block BH for SYN processing
      net: net_enable_timestamp() can be called from irq contexts
      ipv6: orphan skbs in reassembly unit

Ethan Zonca (2):
      can: gs_usb: Don't use stack memory for USB transfers
      can: gs_usb: fix coding style

Felix Fietkau (1):
      mac80211: don't handle filtered frames within a BA session

Felix Jia (1):
      net/ipv6: avoid possible dead locking on addr_gen_mode sysctl

Florian Westphal (1):
      netfilter: use skb_to_full_sk in ip_route_me_harder

Ganesh Goudar (1):
      cxgb4: update latest firmware version supported

Gary Lin (1):
      bpf: update the comment about the length of analysis

Hari Vyas (1):
      net: ethernet: bgmac: mac address change bug

Ido Schimmel (1):
      mlxsw: spectrum_router: Avoid potential packets loss

Jakub Kicinski (4):
      vxlan: lock RCU on TX path
      geneve: lock RCU on TX path
      nfp: don't tell FW about the reserved buffer space
      nfp: correct DMA direction in XDP DMA sync

Johannes Berg (4):
      mac80211: fix packet statistics for fast-RX
      mac80211_hwsim: check HWSIM_ATTR_RADIO_NAME length
      mac80211: use driver-indicated transmitter STA only for data frames
      average: change to declare precision, not factor

Jon Mason (1):
      net: ethernet: bgmac: init sequence bug

Lendacky, Thomas (3):
      amd-xgbe: Stop the PHY before releasing interrupts
      amd-xgbe: Be sure to set MDIO modes on device (re)start
      amd-xgbe: Don't overwrite SFP PHY mod_absent settings

Linus Lüssing (1):
      batman-adv: Fix transmission of final, 16th fragment

Liping Zhang (1):
      net: route: add missing nla_policy entry for RTA_MARK attribute

Marc Kleine-Budde (2):
      can: usb_8dev: Fix memory leak of priv->cmd_msg_buffer
      can: flexcan: fix typo in comment

Matt Chen (1):
      mac80211: flush delayed work when entering suspend

Mike Manning (1):
      net: bridge: allow IPv6 when multicast flood is disabled

Pablo Neira Ayuso (2):
      netfilter: nft_set_rbtree: incorrect assumption on lower interval lookups
      netfilter: nf_tables: don't call nfnetlink_set_err() if nfnetlink_send() fails

Paolo Abeni (1):
      ixgbe: update the rss key on h/w, when ethtool ask for it

Paul Durrant (2):
      xen-netback: keep a local pointer for vif in backend_disconnect()
      xen-netback: don't vfree() queues under spinlock

Peter Downs (1):
      openvswitch: actions: fixed a brace coding style warning

Sara Sharon (3):
      mac80211: don't reorder frames with SN smaller than SSN
      mac80211: shorten debug message
      mac80211: fix typo in debug print

Sven Eckelmann (1):
      batman-adv: Fix double free during fragment merge error

Thomas Gleixner (1):
      mac80211_hwsim: Replace bogus hrtimer clockid

WANG Cong (4):
      ipv6: check for ip6_null_entry in __ip6_del_rt_siblings()
      ipv6: ignore null_entry in inet6_rtm_getroute() too
      bonding: use ETH_MAX_MTU as max mtu
      strparser: destroy workqueue on module exit

Waldemar Rymarkiewicz (1):
      ath10k: search SMBIOS for OEM board file extension

Wei Wang (1):
      tcp: fix potential double free issue for fastopen_req

Xin Long (1):
      sctp: call rcu_read_lock before checking for duplicate transport nodes

Yotam Gigi (1):
      bridge: Fix error path in nbp_vlan_init

Zhu Yanjun (2):
      rds: ib: add the static type to the variables
      rds: remove unnecessary returned value check

 MAINTAINERS                                           |   5 ++-
 drivers/net/bonding/bond_main.c                       |   1 +
 drivers/net/can/flexcan.c                             |   2 +-
 drivers/net/can/usb/gs_usb.c                          |  51 +++++++++++++++++++----------
 drivers/net/can/usb/usb_8dev.c                        |   9 ++----
 drivers/net/ethernet/amd/declance.c                   |  30 ++++++++---------
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c              |   2 +-
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c              |   4 +--
 drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c           |  24 ++++++++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c      |   6 ++++
 drivers/net/ethernet/broadcom/bgmac-platform.c        |  27 ++++++++++------
 drivers/net/ethernet/broadcom/bgmac.c                 |   6 +++-
 drivers/net/ethernet/broadcom/bgmac.h                 |  16 +++++++++
 drivers/net/ethernet/broadcom/sb1250-mac.c            |   4 +--
 drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h     |   6 ++--
 drivers/net/ethernet/faraday/ftgmac100.c              |   4 +--
 drivers/net/ethernet/faraday/ftmac100.c               |   4 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe.h              |   3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c      |   4 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c         |  22 ++++++++++---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c |  30 +++++++++++------
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c   |   7 ++--
 drivers/net/ethernet/seeq/sgiseeq.c                   |   4 +--
 drivers/net/ethernet/sfc/ef10.c                       |  12 +++----
 drivers/net/ethernet/sgi/meth.c                       |   4 +--
 drivers/net/geneve.c                                  |   2 ++
 drivers/net/hyperv/netvsc_drv.c                       |  15 ++++++---
 drivers/net/usb/asix_devices.c                        |   2 +-
 drivers/net/virtio_net.c                              |   2 +-
 drivers/net/vxlan.c                                   |   8 +++--
 drivers/net/wireless/ath/ath10k/core.c                | 101 +++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 drivers/net/wireless/ath/ath10k/core.h                |  19 +++++++++++
 drivers/net/wireless/ath/ath5k/ath5k.h                |   2 +-
 drivers/net/wireless/mac80211_hwsim.c                 |  28 ++++++++++++----
 drivers/net/wireless/ralink/rt2x00/rt2x00.h           |   2 +-
 drivers/net/xen-netback/hash.c                        |   2 +-
 drivers/net/xen-netback/xenbus.c                      |  31 +++++++++++-------
 include/linux/average.h                               |  61 ++++++++++++++++++++++------------
 include/linux/mlx4/driver.h                           |   2 +-
 include/linux/netdevice.h                             |  29 ++++++-----------
 include/net/netfilter/nf_tables.h                     |   6 ++--
 include/net/sock.h                                    |   1 +
 include/trace/events/rxrpc.h                          |   2 ++
 kernel/bpf/verifier.c                                 |   2 +-
 net/batman-adv/fragmentation.c                        |  20 ++++++------
 net/batman-adv/types.h                                |   2 +-
 net/bridge/br_forward.c                               |   3 +-
 net/bridge/br_vlan.c                                  |   2 +-
 net/core/dev.c                                        | 111 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++-----
 net/core/sock.c                                       |  16 ++++++---
 net/dccp/input.c                                      |  10 ++++--
 net/dccp/minisocks.c                                  |   5 +--
 net/ipv4/fib_frontend.c                               |   1 +
 net/ipv4/netfilter.c                                  |   7 ++--
 net/ipv4/tcp.c                                        |  15 +++++++--
 net/ipv4/tcp_input.c                                  |  10 ++++--
 net/ipv6/addrconf.c                                   |  22 +++++++++----
 net/ipv6/netfilter/nf_conntrack_reasm.c               |   1 +
 net/ipv6/route.c                                      |  21 +++++++++---
 net/mac80211/agg-rx.c                                 |   3 +-
 net/mac80211/ieee80211_i.h                            |   2 +-
 net/mac80211/pm.c                                     |   1 +
 net/mac80211/rx.c                                     |  31 +++++++++++++-----
 net/mac80211/sta_info.c                               |   4 +--
 net/mac80211/sta_info.h                               |   8 +++--
 net/mac80211/status.c                                 |   3 +-
 net/netfilter/nf_conntrack_sip.c                      |   2 --
 net/netfilter/nf_tables_api.c                         | 133 +++++++++++++++++++++++++++++++--------------------------------------------
 net/netfilter/nft_set_rbtree.c                        |   9 +++---
 net/openvswitch/actions.c                             |   3 +-
 net/openvswitch/conntrack.c                           |   1 -
 net/packet/af_packet.c                                |   8 +++--
 net/rds/ib.c                                          |  10 ++----
 net/rds/ib_mr.h                                       |   2 --
 net/rds/rds.h                                         |   2 +-
 net/rds/tcp.c                                         |   6 +---
 net/rds/transport.c                                   |   4 +--
 net/rxrpc/af_rxrpc.c                                  |  12 +++++--
 net/rxrpc/ar-internal.h                               |   1 +
 net/rxrpc/call_accept.c                               |  48 +++++++++++++++++++++++++++
 net/rxrpc/call_object.c                               |  18 +++++++++--
 net/rxrpc/input.c                                     |   1 +
 net/rxrpc/recvmsg.c                                   |  39 ++++++++++++++++++----
 net/rxrpc/sendmsg.c                                   |  58 ++++++++++++++++++++++++++-------
 net/sctp/input.c                                      |   3 ++
 net/strparser/strparser.c                             |   1 +
 86 files changed, 895 insertions(+), 368 deletions(-)
