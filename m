From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 26 Nov 2014 16:48:45 -0500 (EST)
Message-ID: <20141126.164845.1084296709868117001.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Several small fixes here:

1) Don't crash in tg3 driver when the number of tx queues has
   been configured to be different from the number of rx queues.
   From Thadeu Lima de Souza Cascardo.

2) VLAN filter not disabled properly in promisc mode in ixgbe
   driver, from Vlad Yasevich.

3) Fix OOPS on dellink op in VTI tunnel driver, from Xin Long.

4) IPV6 GRE driver WCCP code checks skb->protocol for ETH_P_IP
   instead of ETH_P_IPV6, whoops.  From Yuri Chislov.

5) Socket matching in ping driver is buggy when packet AF does
   not match socket's AF.  Fix from Jane Zhou.

6) Fix checksum calculation errors in VXLAN due to where
   the udp_tunnel6_xmit_skb() helper gets it's saddr/daddr from.
   From Alexander Duyck.

7) Fix 5G detection problem in rtlwifi driver, from Larry Finger.

8) Fix NULL deref in tcp_v{4,6}_send_reset, from Eric Dumazet.

9) Various missing netlink attribute verifications in bridging
   code, from Thomas Graf.

10) tcp_recvmsg() unconditionally calls ipv4 ip_recv_error
    even for ipv6 sockets, whoops.  Fix from Willem de Bruijn.

Please pull, thanks a lot!

The following changes since commit 8a84e01e147f44111988f9d8ccd2eaa30215a0f2:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2014-11-21 17:20:36 -0800)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to d1c637c51d87e021c12ed66baddf6cfbd11a3e2b:

  Merge tag 'master-2014-11-25' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless (2014-11-26 16:38:35 -0500)

----------------------------------------------------------------

Alexander Duyck (3):
      ipv6: Do not treat a GSO_TCPV4 request from UDP tunnel over IPv6 as invalid
      ip6_udp_tunnel: Fix checksum calculation
      vxlan: Fix boolean flip in VXLAN_F_UDP_ZERO_CSUM6_[TX|RX]

Alexey Khoroshilov (1):
      xen-netback: do not report success if backend_create_xenvif() fails

Andrew Lutomirski (1):
      net-timestamp: Fix a documentation typo

Carolyn Wyborny (1):
      igb: Fixes needed for surprise removal support

Daniel Borkmann (1):
      ixgbe: fix use after free adapter->state test in ixgbe_remove/ixgbe_probe

David S. Miller (4):
      Merge branch 'ipv6_vxlan_outer_udp_csum'
      Merge branch 'bcm_sf2'
      Merge branch 'bridge_nl_validation'
      Merge tag 'master-2014-11-25' of git://git.kernel.org/.../linville/wireless

Eric Dumazet (1):
      tcp: fix possible NULL dereference in tcp_vX_send_reset()

Florian Fainelli (2):
      net: dsa: bcm_sf2: fix unmapping registers in case of errors
      net: dsa: bcm_sf2: reset switch prior to initialization

Huacai Chen (1):
      stmmac: platform: fix default values of the filter bins setting

Jack Morgenstein (1):
      net/mlx4_core: Limit count field to 24 bits in qp_alloc_res

Jane Zhou (1):
      net/ping: handle protocol mismatching scenario

John W. Linville (1):
      Merge tag 'iwlwifi-for-john-2014-11-23' of git://git.kernel.org/.../iwlwifi/iwlwifi-fixes

Julia Lawall (1):
      solos-pci: fix error return code

Larry Finger (2):
      rtlwifi: rtl8821ae: Fix 5G detection problem
      rtlwifi: Change order in device startup

Luciano Coelho (1):
      iwlwifi: mvm: check TLV flag before trying to use hotspot firmware commands

Michael S. Tsirkin (1):
      af_packet: fix sparse warning

Pablo Neira (1):
      Revert "netfilter: conntrack: fix race in __nf_conntrack_confirm against get_next_corpse"

Thadeu Lima de Souza Cascardo (1):
      tg3: fix ring init when there are more TX than RX channels

Thomas Graf (5):
      bridge: Validate IFLA_BRIDGE_FLAGS attribute length
      net: Validate IFLA_BRIDGE_MODE attribute length
      net: Check for presence of IFLA_AF_SPEC
      bridge: Add missing policy entry for IFLA_BRPORT_FAST_LEAVE
      bridge: Sanitize IFLA_EXT_MASK for AF_BRIDGE:RTM_GETLINK

Vlad Yasevich (1):
      ixgbe: Correctly disable VLAN filter in promiscuous mode

Willem de Bruijn (1):
      net-timestamp: make tcp_recvmsg call ipv6_recv_error for AF_INET6 socks

Yuri Chislov (1):
      ipv6: gre: fix wrong skb->protocol in WCCP

lucien (1):
      ip_tunnel: the lack of vti_link_ops' dellink() cause kernel panic

 Documentation/networking/timestamping.txt             |  2 +-
 drivers/atm/solos-pci.c                               |  2 ++
 drivers/net/dsa/bcm_sf2.c                             | 58 +++++++++++++++++++++++++++++----------------------
 drivers/net/ethernet/broadcom/tg3.c                   |  3 ++-
 drivers/net/ethernet/emulex/benet/be_main.c           |  5 +++++
 drivers/net/ethernet/intel/igb/igb_main.c             | 23 +++++++++++++-------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c         | 17 +++++++++++----
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c |  2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 13 ++++++------
 drivers/net/vxlan.c                                   |  4 ++--
 drivers/net/wireless/iwlwifi/iwl-fw.h                 |  2 ++
 drivers/net/wireless/iwlwifi/mvm/mac80211.c           | 12 ++++++++---
 drivers/net/wireless/rtlwifi/pci.c                    | 20 +++++++++---------
 drivers/net/wireless/rtlwifi/rtl8821ae/hw.c           |  5 +++--
 drivers/net/xen-netback/xenbus.c                      | 15 +++++++------
 include/net/inet_common.h                             |  2 ++
 net/bridge/br_netlink.c                               |  1 +
 net/core/rtnetlink.c                                  | 23 +++++++++++++++-----
 net/ipv4/af_inet.c                                    | 11 ++++++++++
 net/ipv4/ip_vti.c                                     |  1 +
 net/ipv4/ping.c                                       | 14 ++++---------
 net/ipv4/tcp.c                                        |  2 +-
 net/ipv4/tcp_ipv4.c                                   |  5 ++++-
 net/ipv6/ip6_gre.c                                    |  4 ++--
 net/ipv6/ip6_offload.c                                |  3 ++-
 net/ipv6/ip6_udp_tunnel.c                             |  4 +---
 net/ipv6/ip6_vti.c                                    | 11 ++++++++++
 net/ipv6/tcp_ipv6.c                                   |  5 ++++-
 net/netfilter/nf_conntrack_core.c                     | 14 ++++++-------
 net/packet/af_packet.c                                |  2 +-
 30 files changed, 184 insertions(+), 101 deletions(-)
