From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sat, 08 Jul 2017 11:36:44 +0100 (WEST)
Message-ID: <20170708.113644.1272962770645338865.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Mostly fixing some light fallout from the changes that went into
the merge window.

1) Fix memory leaks on network namespace teardown in netfilter, from
   Liping Zhang.

2) When comparing ipv6 nexthops, we have to take the lightweight tunnel
   state into account as well.  From David Ahern.

3) Fix socket option object length check in the new TLS code, from
   Matthias Rosenfelder.

4) Fix memory leak in nfp driver flower support, from Jakub Kicinski.

5) Several netlink attribute validation fixes in cfg80211, from Srinivas
   Dasari.

6) Fix context array leak in virtio_net, from Jason Wang.

7) SKB use after free in hns driver, from Yusheng Lin.

8) Fix socket leak on accept() in RDS, from Sowmini Varadhan.  Also
   add a WARN_ON() to sock_graft() so other protocol stacks don't trip
   over this as well.

Please pull, thanks a lot!

The following changes since commit 9b51f04424e17051a89ab32d892ca66b2a104825:

  Merge branch 'parisc-4.13-2' of git://git.kernel.org/pub/scm/linux/kernel/git/deller/parisc-linux (2017-07-05 17:41:31 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to e8df760307830ca26cf380a9a4b36468a0352fa5:

  net: ethernet: mediatek: remove useless code in mtk_probe() (2017-07-08 11:27:55 +0100)

----------------------------------------------------------------
Christophe Jaillet (1):
      arcnet: com20020-pci: Fix an error handling path in 'com20020pci_probe()'

David Ahern (1):
      net: ipv6: Compare lwstate in detecting duplicate nexthops

David S. Miller (5):
      Merge git://git.kernel.org/.../pablo/nf
      Merge tag 'mac80211-for-davem-2017-07-07' of git://git.kernel.org/.../jberg/mac80211
      net: Update networking MAINTAINERS entry.
      Merge branch 'hns-fixes'
      Merge branch 'rds-tcp-sock_graft-leak'

Derek Chickles (1):
      liquidio: fix bug in soft reset failure detection

Geert Uytterhoeven (1):
      ptp: dte: Use LL suffix for 64-bit constants

Gustavo A. R. Silva (1):
      net: ethernet: mediatek: remove useless code in mtk_probe()

Jakub Kicinski (1):
      nfp: flower: add missing clean up call to avoid memory leaks

Jason Wang (1):
      virtio-net: fix leaking of ctx array

Liping Zhang (2):
      netfilter: nf_ct_dccp/sctp: fix memory leak after netns cleanup
      netfilter: ebt_nflog: fix unexpected truncated packet

Matthias Rosenfelder (1):
      TLS: Fix length check in do_tls_getsockopt_tx()

Nicolas Dichtel (1):
      doc: SKB_GSO_[IPIP|SIT] have been replaced

Nikolay Aleksandrov (1):
      vrf: fix bug_on triggered by rx when destroying a vrf

Roopa Prabhu (1):
      mpls: fix uninitialized in_label var warning in mpls_getroute

Sowmini Varadhan (2):
      rds: tcp: use sock_create_lite() to create the accept socket
      net/sock: add WARN_ON(parent->sk) in sock_graft()

Srinivas Dasari (4):
      cfg80211: Check if PMKID attribute is of expected size
      cfg80211: Check if NAN service ID is of expected size
      cfg80211: Define nla_policy for NL80211_ATTR_LOCAL_MESH_POWER_MODE
      cfg80211: Validate frequencies nested in NL80211_ATTR_SCAN_FREQUENCIES

WANG Cong (1):
      bonding: avoid NETDEV_CHANGEMTU event when unregistering slave

Wu Fengguang (1):
      tcp: md5: tcp_md5_do_lookup_exact() can be static

Yunsheng Lin (2):
      net: hns: Fix a wrong op phy C45 code
      net: hns: Fix a skb used after free bug

Zheng Li (1):
      sctp: set the value of flowi6_oif to sk_bound_dev_if to make sctp_v6_get_dst to find the correct route entry.

vishnuvardhan (1):
      net: macb: Adding Support for Jumbo Frames up to 10240 Bytes in SAMA5D3

 Documentation/networking/segmentation-offloads.txt      |  2 +-
 MAINTAINERS                                             |  2 --
 drivers/net/arcnet/com20020-pci.c                       |  6 ++++--
 drivers/net/bonding/bond_main.c                         | 15 +++++++++------
 drivers/net/ethernet/cadence/macb_main.c                |  3 ++-
 drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c |  2 +-
 drivers/net/ethernet/cavium/liquidio/cn66xx_device.c    |  2 +-
 drivers/net/ethernet/hisilicon/hns/hns_enet.c           | 22 ++++++++++------------
 drivers/net/ethernet/hisilicon/hns/hns_enet.h           |  6 +++---
 drivers/net/ethernet/hisilicon/hns_mdio.c               |  2 +-
 drivers/net/ethernet/mediatek/mtk_eth_soc.c             |  5 -----
 drivers/net/ethernet/netronome/nfp/flower/main.c        |  1 +
 drivers/net/virtio_net.c                                |  1 +
 drivers/net/vrf.c                                       | 11 ++++++-----
 drivers/ptp/ptp_dte.c                                   |  2 +-
 include/linux/netdevice.h                               |  1 +
 include/net/ip6_route.h                                 |  8 ++++++++
 include/net/sock.h                                      |  1 +
 net/bridge/netfilter/ebt_nflog.c                        |  1 +
 net/core/dev.c                                          |  3 ++-
 net/ipv4/tcp_ipv4.c                                     |  6 +++---
 net/ipv6/ip6_fib.c                                      |  5 +----
 net/ipv6/route.c                                        |  8 +-------
 net/mpls/af_mpls.c                                      | 12 ++++++++----
 net/netfilter/nf_conntrack_proto_dccp.c                 |  7 +++++++
 net/netfilter/nf_conntrack_proto_sctp.c                 |  7 +++++++
 net/rds/tcp_listen.c                                    |  2 +-
 net/sctp/ipv6.c                                         |  2 ++
 net/tls/tls_main.c                                      |  2 +-
 net/wireless/nl80211.c                                  | 10 +++++++---
 30 files changed, 92 insertions(+), 65 deletions(-)
