From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 16 Jan 2017 21:52:27 -0500 (EST)
Message-ID: <20170116.215227.789919041260264867.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Handle multicast packets properly in fast-RX path of mac80211,
   from Johannes Berg.

2) Because of a logic bug, the user can't actually force SW
   checksumming on r8152 devices.  This makes diagnosis of hw
   checksumming bugs really annoying.  Fix from Hayes Wang.

3) VXLAN route lookup does not take the source and destination ports
   into account, which means IPSEC policies cannot be matched
   properly.  Fix from Martynas Pumputis.

4) Do proper RCU locking in netvsc callbacks, from Stephen Hemminger.

5) Fix SKB leaks in mlxsw driver, from Arkadi Sharshevsky.

6) If lwtunnel_fill_encap() fails, we do not abort the netlink message
   construction properly in fib_dump_info(), from David Ahern.

7) Do not use kernel stack for DMA buffers in atusb driver, from
   Stefan Schmidt.

8) Openvswitch conntack actions need to maintain a correct checksum,
   fix from Lance Richardson.

9) ax25_disconnect() is missing a check for ax25->sk being NULL, in fact
   it already checks this, but not in all of the necessary spots.  Fix
   from Basil Gunn.

10) Action GET operations in the packet scheduler can erroneously bump
    the reference count of the entry, making it unreleasable.  Fix
    from Jamal Hadi Salim.  Jamal gives a great set of example command
    lines that trigger this in the commit message.

Please pull, thanks a lot!

The following changes since commit ba836a6f5ab1243ff5e08a941a2d1de8b31244e1:

  Merge branch 'akpm' (patches from Andrew) (2017-01-11 11:15:15 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net 

for you to fetch changes up to 0faa9cb5b3836a979864a6357e01d2046884ad52:

  net sched actions: fix refcnt when GETing of action after bind (2017-01-16 19:43:19 -0500)

----------------------------------------------------------------
Andrey Smirnov (1):
      at86rf230: Allow slow GPIO pins for "rstn"

Arkadi Sharshevsky (2):
      mlxsw: spectrum: Fix memory leak at skb reallocation
      mlxsw: switchx2: Fix memory leak at skb reallocation

Arnd Bergmann (2):
      cpmac: remove hopeless #warning
      net/mlx5e: Fix a -Wmaybe-uninitialized warning

Basil Gunn (1):
      ax25: Fix segfault after sock connection timeout

Beni Lev (1):
      cfg80211: consider VHT opmode on station update

Cedric Izoard (1):
      mac80211: Fix headroom allocation when forwarding mesh pkt

Daniel Borkmann (1):
      bpf: rework prog_digest into prog_tag

David Ahern (2):
      net: lwtunnel: Handle lwtunnel_fill_encap failure
      net: ipv4: fix table id in getroute response

David Lebrun (1):
      ipv6: sr: fix several BUGs when preemption is enabled

David S. Miller (4):
      Merge branch 'mlxsw-fixes'
      Merge tag 'mac80211-for-davem-2017-01-13' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/bluetooth
      Merge branch 'mlx4-core-fixes'

Elad Raz (1):
      mlxsw: pci: Fix EQE structure definition

Emmanuel Grumbach (1):
      mac80211: fix the TID on NDPs sent as EOSP carrier

Eric Dumazet (1):
      mlx4: do not call napi_schedule() without care

Felix Fietkau (1):
      mac80211: initialize SMPS field in HT capabilities

Florian Fainelli (1):
      net: systemport: Decouple flow control from __bcm_sysport_tx_reclaim

Hangbin Liu (1):
      mld: do not remove mld souce list info when set link down

Heiner Kallweit (1):
      net: stmmac: don't use netdev_[dbg, info, ..] before net_device is registered

Ivan Vecera (3):
      be2net: fix status check in be_cmd_pmac_add()
      be2net: don't delete MAC on close on unprivileged BE3 VFs
      be2net: fix MAC addr setting on privileged BE3 VFs

Jack Morgenstein (3):
      net/mlx4_core: Fix racy CQ (Completion Queue) free
      net/mlx4_core: Fix when to save some qp context flags for dynamic VST to VGT transitions
      net/mlx4_core: Eliminate warning messages for SRQ_LIMIT under SRIOV

Jakub Sitnicki (1):
      ip6_tunnel: Account for tunnel header in tunnel MTU

Jamal Hadi Salim (1):
      net sched actions: fix refcnt when GETing of action after bind

Johannes Berg (3):
      mac80211: implement multicast forwarding on fast-RX path
      mac80211: calculate min channel width correctly
      mac80211: recalculate min channel width on VHT opmode changes

Karicheri, Muralidharan (1):
      net: phy: dp83867: allow RGMII_TXID/RGMII_RXID interface types

Kazuya Mizuguchi (1):
      ravb: Remove Rx overflow log messages

Lance Richardson (1):
      openvswitch: maintain correct checksum state in conntrack actions

Martynas Pumputis (1):
      vxlan: Set ports in flow key when doing route lookups

Masaru Nagai (1):
      ravb: do not use zero-length alignment DMA descriptor

Michal Kazior (1):
      mac80211: prevent skb/txq mismatch

Parthasarathy Bhuvaragan (1):
      tipc: allocate user memory with GFP_KERNEL flag

Shannon Nelson (1):
      tcp: fix tcp_fastopen unaligned access complaints on sparc

Stefan Schmidt (4):
      ieee802154: atusb: do not use the stack for buffers to make them DMA able
      ieee802154: atusb: make sure we set a randaom extended address if fetching fails
      ieee802154: atusb: do not use the stack for address fetching to make it DMA able
      ieee802154: atusb: fix driver to work with older firmware versions

Timur Tabi (1):
      net: qcom/emac: grab a reference to the phydev on ACPI systems

Vadim Lomovtsev (1):
      net: thunderx: acpi: fix LMAC initialization

hayeswang (1):
      r8152: fix the sw rx checksum is unavailable

stephen hemminger (1):
      netvsc: add rcu_read locking to netvsc callback

 Documentation/devicetree/bindings/net/ti,dp83867.txt  |  6 ++++--
 drivers/net/ethernet/broadcom/bcmsysport.c            | 25 ++++++++++++++++++-------
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c     | 11 ++++++-----
 drivers/net/ethernet/emulex/benet/be_cmds.c           |  2 +-
 drivers/net/ethernet/emulex/benet/be_main.c           | 18 +++++++++++++++---
 drivers/net/ethernet/mellanox/mlx4/cq.c               | 38 ++++++++++++++++++++------------------
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c        |  5 ++++-
 drivers/net/ethernet/mellanox/mlx4/eq.c               | 23 ++++++++++++++---------
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c |  5 +++--
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c       | 11 +++++++----
 drivers/net/ethernet/mellanox/mlxsw/pci_hw.h          |  8 ++++----
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c        |  1 +
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c        |  1 +
 drivers/net/ethernet/qualcomm/emac/emac-phy.c         |  7 +++++++
 drivers/net/ethernet/qualcomm/emac/emac.c             |  6 ++----
 drivers/net/ethernet/renesas/ravb_main.c              | 21 +++++++++++++++------
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c     | 19 ++++++++++---------
 drivers/net/ethernet/ti/cpmac.c                       |  2 +-
 drivers/net/hyperv/netvsc_drv.c                       |  3 +++
 drivers/net/ieee802154/at86rf230.c                    |  4 ++--
 drivers/net/ieee802154/atusb.c                        | 59 +++++++++++++++++++++++++++++++++++++++++++----------------
 drivers/net/phy/dp83867.c                             |  8 ++++++--
 drivers/net/usb/r8152.c                               |  7 ++++++-
 drivers/net/vxlan.c                                   | 13 ++++++++++---
 include/linux/bpf.h                                   |  2 +-
 include/linux/filter.h                                |  6 ++++--
 include/linux/tcp.h                                   |  7 ++++++-
 include/uapi/linux/nl80211.h                          |  4 +++-
 include/uapi/linux/pkt_cls.h                          |  2 +-
 include/uapi/linux/tc_act/tc_bpf.h                    |  2 +-
 kernel/bpf/core.c                                     | 14 ++++++++------
 kernel/bpf/syscall.c                                  |  8 ++++----
 kernel/bpf/verifier.c                                 |  2 +-
 net/ax25/ax25_subr.c                                  |  2 +-
 net/ipv4/fib_semantics.c                              | 11 +++++++----
 net/ipv4/route.c                                      |  2 +-
 net/ipv4/tcp_fastopen.c                               |  2 +-
 net/ipv6/ip6_tunnel.c                                 |  4 ++--
 net/ipv6/mcast.c                                      | 51 ++++++++++++++++++++++++++++++---------------------
 net/ipv6/route.c                                      |  3 ++-
 net/ipv6/seg6_hmac.c                                  |  2 +-
 net/ipv6/seg6_iptunnel.c                              |  4 ++++
 net/mac80211/chan.c                                   |  3 ---
 net/mac80211/iface.c                                  | 21 +++++++++++++++++++++
 net/mac80211/main.c                                   | 13 +++++++++----
 net/mac80211/rate.c                                   |  2 ++
 net/mac80211/rx.c                                     | 38 +++++++++++++++++++++-----------------
 net/mac80211/sta_info.c                               |  4 ++--
 net/mac80211/tx.c                                     | 17 +++++++----------
 net/mac80211/vht.c                                    |  4 +++-
 net/openvswitch/conntrack.c                           |  6 ++++--
 net/sched/act_api.c                                   |  5 ++---
 net/sched/act_bpf.c                                   |  5 ++---
 net/sched/cls_bpf.c                                   |  4 ++--
 net/tipc/discover.c                                   |  4 ++--
 net/tipc/link.c                                       |  2 +-
 net/tipc/msg.c                                        | 16 ++++++++--------
 net/tipc/msg.h                                        |  2 +-
 net/tipc/name_distr.c                                 |  2 +-
 net/wireless/nl80211.c                                | 15 +++++++++++++++
 60 files changed, 384 insertions(+), 210 deletions(-)
