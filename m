From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 12 Aug 2015 23:06:12 -0700 (PDT)
Message-ID: <20150812.230612.868690964421376371.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Workaround hw bug when acquiring PCI bos ownership of iwlwifi
   devices, from Emmanuel Grumbach.

2) Falling back to vmalloc in conntrack should not emit a warning,
   from Pablo Neira Ayuso.

3) Fix NULL deref when rtlwifi driver is used as an AP, from Luis
   Felipe Dominguez Vega.

4) Rocker doesn't free netdev on device removal, from Ido Schimmel.

5) UDP multicast early sock demux has route handling races, from
   Eric Dumazet.

6) Fix L4 checksum handling in openvswitch, from Glenn Griffin.

7) Fix use-after-free in skb_set_peeked, from Herbert Xu.

8) Don't advertize NETIF_F_FRAGLIST in virtio_net driver, this can
   lead to fraglists longer than the driver can support.  From Jason
   Wang.

9) Fix mlx5 on non-4k-pagesize systems, from Carol L Soto.

10) Fix interrupt storm in bna driver, from Ivan Vecera.

11) Don't propagate -EBUSY from netlink_insert(), from Daniel
    Borkmann.

12) Fix inet request sock leak, from Eric Dumazet.

13) Fix TX interrupt masking and marking in TX descriptors of fs_enet
    driver, from LEROY Christophe.

14) Get rid of rule optimizer in gianfar driver, it's buggy and unlikely
    to get fixed any time soon.  From Jakub Kicinski.

Please pull, thanks a lot!

The following changes since commit 7c764cec3703583247c4ab837c652975a3d41f4b:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2015-07-31 17:10:56 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net 

for you to fetch changes up to e6d006938c9bda7ffd22af9d3e1257fd75941fb7:

  cosa: missing error code on failure in probe() (2015-08-12 16:53:11 -0700)

----------------------------------------------------------------
Antonio Quartulli (1):
      batman-adv: avoid DAT to mess up LAN state

Avraham Stern (1):
      iwlwifi: mvm: Fix regular scan priority

Benjamin Poirier (1):
      net-timestamp: Update skb_complete_tx_timestamp comment

Carol L Soto (1):
      net/mlx5_core: Set log_uar_page_sz for non 4K page size architecture

Dan Carpenter (4):
      netfilter: nf_conntrack: checking for IS_ERR() instead of NULL
      rds: fix an integer overflow test in rds_info_getsockopt()
      cxgb4: missing curly braces in t4_setup_debugfs()
      cosa: missing error code on failure in probe()

Daniel Borkmann (1):
      netlink: make sure -EBUSY won't escape from netlink_insert

David S. Miller (8):
      Merge tag 'wireless-drivers-for-davem-2015-08-04' of git://git.kernel.org/.../kvalo/wireless-drivers
      Merge branch 'be2net-fixes'
      Merge tag 'batman-adv-fix-for-davem' of git://git.open-mesh.org/linux-merge
      Merge branch 'mvpp2-fixes'
      Merge branch 'bnx2x-fixes'
      Merge git://git.kernel.org/.../pablo/nf
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/bluetooth
      Merge branch 'gianfar-fixes'

Emmanuel Grumbach (2):
      iwlwifi: pcie: fix prepare card flow
      iwlwifi: pcie: fix stuck queue detection for sleeping clients

Eric Dumazet (4):
      fq_codel: explicitly reset flows in ->reset()
      udp: fix dst races with multicast early demux
      inet: fix races with reqsk timers
      inet: fix possible request socket leak

Fabio Estevam (1):
      mkiss: Fix error handling in mkiss_open()

Florian Fainelli (1):
      net: dsa: Do not override PHY interface if already configured

Florian Westphal (1):
      ipv6: don't reject link-local nexthop on other interface

Glenn Griffin (1):
      openvswitch: Fix L4 checksum handling when dealing with IP fragments

Hauke Mehrtens (1):
      b43: fix extpa_gain check for 2GHz

Herbert Xu (1):
      net: Fix skb_set_peeked use-after-free bug

Ian Campbell (1):
      net: thunderx: remove effective "default y" from Kconfig if ARCH_THUNDER=y

Ido Schimmel (1):
      rocker: free netdevice during netdevice removal

Ivan Vecera (2):
      r8169: enforce RX_MULTI_EN on rtl8168ep/8111ep chips
      bna: fix interrupts storm caused by erroneous packets

Jakub Kicinski (3):
      gianfar: correct filer table writing
      gianfar: correct list membership accounting
      gianfar: remove faulty filer optimizer

Jakub Pawlowski (1):
      Bluetooth: fix MGMT_EV_NEW_LONG_TERM_KEY event

Jason Wang (1):
      virtio-net: drop NETIF_F_FRAGLIST

Jia-Ju Bai (1):
      3c59x: Fix resource leaks in vortex_open

Joe Stringer (1):
      netfilter: conntrack: Use flags in nf_ct_tmpl_alloc()

Kalesh AP (3):
      be2net: enable IFACE filters only after creating RXQs
      be2net: post buffers before destroying RXQs in Lancer
      be2net: protect eqo->affinity_mask from getting freed twice

Kalle Valo (1):
      Merge tag 'iwlwifi-for-kalle-2015-07-30' of https://git.kernel.org/.../iwlwifi/iwlwifi-fixes

LEROY Christophe (2):
      net: fs_enet: explicitly remove I flag on TX partial frames
      net: fs_enet: mask interrupts for TX partial frames.

Larry Finger (1):
      rtlwifi: rtl8723be: Add module parameter for MSI interrupts

Lucas Stach (1):
      net: fec: fix initial runtime PM refcount

Luis Felipe Dominguez Vega (1):
      rtlwifi: Fix NULL dereference when PCI driver used as an AP

Marcin Wojtas (3):
      net: mvpp2: remove excessive spinlocks from driver initialization
      net: mvpp2: enable proper per-CPU TX buffers unmapping
      net: mvpp2: replace TX coalescing interrupts with hrtimer

Marek Lindner (2):
      batman-adv: fix kernel crash due to missing NULL checks
      batman-adv: protect tt_local_entry from concurrent delete events

Mathieu Olivari (1):
      stmmac: dwmac-ipq806x: fix static checker warning

Mike Looijmans (1):
      rsi: Fix failure to load firmware after memory leak fix and fix the leak

Nikolay Aleksandrov (2):
      bridge: netlink: account for the IFLA_BRPORT_PROXYARP attribute size and policy
      bridge: netlink: account for the IFLA_BRPORT_PROXYARP_WIFI attribute size and policy

Oleg Nesterov (1):
      net: pktgen: don't abuse current->state in pktgen_thread_worker()

Pablo Neira Ayuso (1):
      netfilter: nf_conntrack: silence warning on falling back to vmalloc()

Phil Sutter (2):
      netfilter: ip6t_SYNPROXY: fix NULL pointer dereference
      netfilter: SYNPROXY: fix sending window update to client

Ross Lagerwall (2):
      xen-netback: Allocate fraglist early to avoid complex rollback
      xen/netback: Wake dealloc thread after completing zerocopy work

Simon Wunderlich (1):
      batman-adv: initialize up/down values when adding a gateway

Venkat Venkatsubra (1):
      bonding: Gratuitous ARP gets dropped when first slave added

WANG Cong (1):
      act_mirred: avoid calling tcf_hash_release() when binding

WingMan Kwok (1):
      net: netcp: fix unused interface rx buffer size configuration

Yuval Mintz (2):
      bnx2x: Prevent null pointer dereference on SKB release
      bnx2x: Free NVRAM lock at end of each page

 drivers/net/bonding/bond_main.c                       |   1 +
 drivers/net/ethernet/3com/3c59x.c                     |  17 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c       |   2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c   |  16 +++
 drivers/net/ethernet/brocade/bna/bnad.c               |   2 +-
 drivers/net/ethernet/cavium/Kconfig                   |   3 -
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c    |   3 +-
 drivers/net/ethernet/emulex/benet/be_cmds.h           |   5 +
 drivers/net/ethernet/emulex/benet/be_main.c           | 187 ++++++++++++++++++++++------------
 drivers/net/ethernet/freescale/fec_main.c             |   1 +
 drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c |   3 +-
 drivers/net/ethernet/freescale/fs_enet/mac-fec.c      |   2 +-
 drivers/net/ethernet/freescale/gianfar_ethtool.c      | 345 +-------------------------------------------------------------
 drivers/net/ethernet/marvell/mvpp2.c                  | 244 ++++++++++++++++++++++++++++++--------------
 drivers/net/ethernet/mellanox/mlx5/core/main.c        |   2 +
 drivers/net/ethernet/realtek/r8169.c                  |   4 +-
 drivers/net/ethernet/rocker/rocker.c                  |   1 +
 drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x.c   |   4 +-
 drivers/net/ethernet/ti/netcp.h                       |   1 -
 drivers/net/ethernet/ti/netcp_core.c                  |  35 +++----
 drivers/net/hamradio/mkiss.c                          |   7 +-
 drivers/net/virtio_net.c                              |   4 +-
 drivers/net/wan/cosa.c                                |   3 +-
 drivers/net/wireless/b43/tables_nphy.c                |   2 +-
 drivers/net/wireless/iwlwifi/mvm/scan.c               |   2 +-
 drivers/net/wireless/iwlwifi/pcie/trans.c             |  22 +++-
 drivers/net/wireless/iwlwifi/pcie/tx.c                |  15 ++-
 drivers/net/wireless/rsi/rsi_91x_sdio_ops.c           |   8 +-
 drivers/net/wireless/rsi/rsi_91x_usb_ops.c            |   4 +
 drivers/net/wireless/rtlwifi/core.c                   |   7 +-
 drivers/net/wireless/rtlwifi/rtl8723be/sw.c           |   1 +
 drivers/net/xen-netback/interface.c                   |   6 ++
 drivers/net/xen-netback/netback.c                     |  62 +++++------
 include/linux/skbuff.h                                |   6 +-
 net/batman-adv/distributed-arp-table.c                |  18 +++-
 net/batman-adv/gateway_client.c                       |   2 +
 net/batman-adv/soft-interface.c                       |   3 +
 net/batman-adv/translation-table.c                    |  29 +++++-
 net/bluetooth/mgmt.c                                  |   2 +-
 net/bridge/br_netlink.c                               |   4 +
 net/core/datagram.c                                   |  13 +--
 net/core/pktgen.c                                     |   3 -
 net/core/request_sock.c                               |   8 +-
 net/dsa/slave.c                                       |   3 +-
 net/ipv4/inet_connection_sock.c                       |   2 +-
 net/ipv4/netfilter/ipt_SYNPROXY.c                     |   3 +-
 net/ipv4/tcp_ipv4.c                                   |   2 +-
 net/ipv4/udp.c                                        |  13 ++-
 net/ipv6/netfilter/ip6t_SYNPROXY.c                    |  19 ++--
 net/ipv6/route.c                                      |   6 +-
 net/ipv6/tcp_ipv6.c                                   |   2 +-
 net/netfilter/nf_conntrack_core.c                     |   8 +-
 net/netfilter/nf_synproxy_core.c                      |   4 +-
 net/netfilter/xt_CT.c                                 |   5 +-
 net/netlink/af_netlink.c                              |   5 +
 net/openvswitch/actions.c                             |  16 ++-
 net/rds/info.c                                        |   2 +-
 net/sched/act_mirred.c                                |   2 +
 net/sched/sch_fq_codel.c                              |  22 +++-
 59 files changed, 590 insertions(+), 633 deletions(-)
