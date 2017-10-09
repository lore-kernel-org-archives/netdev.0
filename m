From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 09 Oct 2017 16:10:36 -0700 (PDT)
Message-ID: <20171009.161036.1990581350034973996.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58938 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754604AbdJIXKh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 19:10:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Fix object leak on IPSEC offload failure, from Steffen Klassert.

2) Fix range checks in ipset address range addition operations,
   from Jozsef Kadlecsik.

3) Fix pernet ops unregistration order in ipset, from Florian
   Westphal.

4) Add missing netlink attribute policy for nl80211 packet pattern
   attrs, from Peng Xu.

5) Fix PPP device destruction race, from Guillaume Nault.

6) Write marks get lost when BPF verifier processes R1=R2 register
   assignments, causing incorrect liveness information and less
   state pruning.  Fix from Alexei Starovoitov.

7) Fix blockhole routes so that they are marked dead and therefore
   not cached in sockets, otherwise IPSEC stops working.  From
   Steffen Klassert.

8) Fix broadcast handling of UDP socket early demux, from Paolo
   Abeni.

Please pull, thanks a lot!

The following changes since commit 7a92616c0bac849e790283723b36c399668a1d9f:

  Merge tag 'pm-4.14-rc4' of git://git.kernel.org/pub/scm/linux/kernel/git/rafael/linux-pm (2017-10-05 15:51:37 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to fdfbad3256918fc5736d68384331d2dbf45ccbd6:

  cdc_ether: flag the u-blox TOBY-L2 and SARA-U2 as wwan (2017-10-09 16:03:32 -0700)

----------------------------------------------------------------
Aleksander Morgado (1):
      cdc_ether: flag the u-blox TOBY-L2 and SARA-U2 as wwan

Alexei Starovoitov (1):
      bpf: fix liveness marking

Alexey Kodanev (2):
      vti: fix NULL dereference in xfrm_input()
      gso: fix payload length when gso_size is zero

Artem Savkov (2):
      xfrm: don't call xfrm_policy_cache_flush under xfrm_state_lock
      netfilter: ebtables: fix race condition in frame_filter_net_init()

Arvind Yadav (1):
      netfilter: nf_tables: Release memory obtained by kasprintf

Axel Beckert (1):
      doc: Fix typo "8023.ad" in bonding documentation

Dan Carpenter (1):
      selftests/net: rxtimestamp: Fix an off by one

David S. Miller (4):
      Merge branch 'master' of git://git.kernel.org/.../klassert/ipsec
      Merge tag 'mac80211-for-davem-2017-10-09' of git://git.kernel.org/.../jberg/mac80211
      Merge branch '10GbE' of git://git.kernel.org/.../jkirsher/net-queue
      Merge git://git.kernel.org/.../pablo/nf

Ding Tianhong (2):
      Revert commit 1a8b6d76dc5b ("net:add one common config...")
      net: ixgbe: Use new PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag

Eric Dumazet (1):
      netfilter: x_tables: avoid stack-out-of-bounds read in xt_copy_counters_from_user

Florian Westphal (1):
      netfilter: ipset: pernet ops must be unregistered last

Guillaume Nault (1):
      ppp: fix race in ppp device destruction

Gustavo A. R. Silva (1):
      net: thunderx: mark expected switch fall-throughs in nicvf_main()

Ido Schimmel (1):
      mlxsw: spectrum_router: Avoid expensive lookup during route removal

Jason A. Donenfeld (1):
      netlink: do not set cb_running if dump's start() errs

JingPiao Chen (1):
      netfilter: nf_tables: fix update chain error

John Fastabend (1):
      ixgbe: incorrect XDP ring accounting in ethtool tx_frame param

Jon Maloy (2):
      tipc: correct initialization of skb list
      tipc: Unclone message at secondary destination lookup

Jozsef Kadlecsik (1):
      netfilter: ipset: Fix adding an IPv4 range containing more than 2^31 addresses

Lin Zhang (1):
      netfilter: SYNPROXY: skip non-tcp packet in {ipv4, ipv6}_synproxy_hook

Mark D Rustad (1):
      ixgbe: Return error when getting PHY address if PHY access is not supported

Matteo Croce (1):
      ipv6: fix net.ipv6.conf.all.accept_dad behaviour for real

Pablo Neira Ayuso (1):
      netfilter: nf_tables: do not dump chain counters if not enabled

Paolo Abeni (1):
      udp: fix bcast packet reception

Peng Xu (1):
      nl80211: Define policy for packet pattern attributes

Ross Lagerwall (1):
      netfilter: ipset: Fix race between dump and swap

Sabrina Dubroca (1):
      ixgbe: fix masking of bits read from IXGBE_VXLANCTRL register

Shmulik Ladkani (1):
      netfilter: xt_bpf: Fix XT_BPF_MODE_FD_PINNED mode of 'xt_bpf_info_v1'

Steffen Klassert (4):
      xfrm: Fix deletion of offloaded SAs on failure.
      xfrm: Fix negative device refcount on offload failure.
      ipv6: Fix traffic triggered IPsec connections.
      ipv4: Fix traffic triggered IPsec connections.

Subash Abhinov Kasiviswanathan (1):
      netfilter: xt_socket: Restore mark from full sockets only

Vadim Fedorenko (1):
      netfilter: ipvs: full-functionality option for ECN encapsulation in tunnel

 Documentation/networking/bonding.txt                          |  2 +-
 arch/Kconfig                                                  |  3 ---
 arch/sparc/Kconfig                                            |  1 -
 drivers/net/ethernet/cavium/thunder/nicvf_main.c              |  2 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c                | 22 ----------------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c               | 19 -------------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c              | 16 ++++++++--------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c                 |  6 +++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c         | 14 --------------
 drivers/net/ppp/ppp_generic.c                                 | 20 ++++++++++++++++++++
 drivers/net/usb/cdc_ether.c                                   | 13 +++++++++++++
 include/linux/bpf.h                                           |  5 +++++
 include/linux/netfilter_bridge/ebtables.h                     |  7 ++++---
 include/uapi/linux/netfilter/xt_bpf.h                         |  1 +
 kernel/bpf/inode.c                                            |  1 +
 kernel/bpf/verifier.c                                         |  5 +++++
 net/bridge/netfilter/ebtable_broute.c                         |  4 ++--
 net/bridge/netfilter/ebtable_filter.c                         |  4 ++--
 net/bridge/netfilter/ebtable_nat.c                            |  4 ++--
 net/bridge/netfilter/ebtables.c                               | 17 +++++++++--------
 net/ipv4/gre_offload.c                                        |  2 +-
 net/ipv4/netfilter/ipt_SYNPROXY.c                             |  3 ++-
 net/ipv4/route.c                                              |  2 +-
 net/ipv4/udp.c                                                | 14 +++++---------
 net/ipv4/udp_offload.c                                        |  2 +-
 net/ipv6/addrconf.c                                           |  4 ++--
 net/ipv6/ip6_offload.c                                        |  2 +-
 net/ipv6/netfilter/ip6t_SYNPROXY.c                            |  2 +-
 net/ipv6/route.c                                              |  2 +-
 net/netfilter/ipset/ip_set_core.c                             | 29 ++++++++++++++++++-----------
 net/netfilter/ipset/ip_set_hash_ip.c                          | 22 ++++++++++++----------
 net/netfilter/ipset/ip_set_hash_ipmark.c                      |  2 +-
 net/netfilter/ipset/ip_set_hash_ipport.c                      |  2 +-
 net/netfilter/ipset/ip_set_hash_ipportip.c                    |  2 +-
 net/netfilter/ipset/ip_set_hash_ipportnet.c                   |  4 ++--
 net/netfilter/ipset/ip_set_hash_net.c                         |  2 +-
 net/netfilter/ipset/ip_set_hash_netiface.c                    |  2 +-
 net/netfilter/ipset/ip_set_hash_netnet.c                      |  4 ++--
 net/netfilter/ipset/ip_set_hash_netport.c                     |  2 +-
 net/netfilter/ipset/ip_set_hash_netportnet.c                  |  4 ++--
 net/netfilter/ipvs/ip_vs_xmit.c                               |  8 ++++++--
 net/netfilter/nf_tables_api.c                                 | 10 ++++++----
 net/netfilter/x_tables.c                                      |  4 ++--
 net/netfilter/xt_bpf.c                                        | 22 ++++++++++++++++++++--
 net/netfilter/xt_socket.c                                     |  4 ++--
 net/netlink/af_netlink.c                                      | 13 +++++++------
 net/tipc/bcast.c                                              |  4 ++--
 net/tipc/msg.c                                                |  8 ++++++++
 net/wireless/nl80211.c                                        | 14 ++++++++++++--
 net/xfrm/xfrm_device.c                                        |  1 +
 net/xfrm/xfrm_input.c                                         |  6 ++++--
 net/xfrm/xfrm_state.c                                         |  4 ++--
 net/xfrm/xfrm_user.c                                          |  1 +
 tools/testing/selftests/networking/timestamping/rxtimestamp.c |  2 +-
 54 files changed, 211 insertions(+), 164 deletions(-)
