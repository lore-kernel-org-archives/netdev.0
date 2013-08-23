From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH RFC 0/6] SYNPROXY target v2
Date: Fri, 23 Aug 2013 09:52:03 +0200
Message-ID: <1377244329-20146-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	mph@one.com, jesper.brouer@gmail.com, as@one.com
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following patches contain the current version of the SYNPROXY target.
Changes this the last posting are:

- use sysctl_ip_default_ttl instead of hardcoding 64

- use MAX_TCP_HEADER instead of LL_MAX_HEADER

- add some comments requested by Jesper regarding ack_seq initialization
  in the server's SYN packet

- use consume_skb() instead of kfree_skb() in the synproxy hook

- remove a fixme and add explicit check for "-p tcp" in the SYNPROXY rule
  in the IPv6 version

- some whitespace fixes

- a larger number of fixes for properly handling retransmissions and
  out of order packets, please see the changelog included in patch 6/6
  for details.
  
  I've kept those in a seperate patch for now to ease review, we'll do
  some more extensive testing on monday and I'll fold the changes in
  their respective patches before the final submission.

Comments welcome.


Patrick McHardy (6):
      netfilter: nf_conntrack: make sequence number adjustments usuable without NAT
      net: syncookies: export cookie_v4_init_sequence/cookie_v4_check
      netfilter: add SYNPROXY core/target
      net: syncookies: export cookie_v6_init_sequence/cookie_v6_check
      netfilter: add IPv6 SYNPROXY target
      netfilter: synproxy: fix handling of retransmissions before established state

 include/linux/netfilter.h                          |   9 +-
 include/net/netfilter/nf_conntrack_extend.h        |   6 +
 include/net/netfilter/nf_conntrack_seqadj.h        |  51 +++
 include/net/netfilter/nf_conntrack_synproxy.h      |  76 ++++
 include/net/netfilter/nf_nat.h                     |  10 -
 include/net/netfilter/nf_nat_helper.h              |  19 -
 include/net/tcp.h                                  |   8 +
 include/uapi/linux/netfilter/nf_conntrack_common.h |   3 +-
 include/uapi/linux/netfilter/nfnetlink_conntrack.h |  15 +-
 include/uapi/linux/netfilter/xt_SYNPROXY.h         |  16 +
 net/ipv4/netfilter/Kconfig                         |  13 +
 net/ipv4/netfilter/Makefile                        |   1 +
 net/ipv4/netfilter/ipt_SYNPROXY.c                  | 457 ++++++++++++++++++++
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c     |   7 +-
 net/ipv4/syncookies.c                              |  29 +-
 net/ipv6/netfilter/Kconfig                         |  13 +
 net/ipv6/netfilter/Makefile                        |   1 +
 net/ipv6/netfilter/ip6t_SYNPROXY.c                 | 480 +++++++++++++++++++++
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c     |   7 +-
 net/ipv6/syncookies.c                              |  25 +-
 net/netfilter/Kconfig                              |   3 +
 net/netfilter/Makefile                             |   5 +-
 net/netfilter/nf_conntrack_core.c                  |  22 +-
 net/netfilter/nf_conntrack_netlink.c               | 115 +++--
 net/netfilter/nf_conntrack_proto_tcp.c             |  34 +-
 net/netfilter/nf_conntrack_seqadj.c                | 238 ++++++++++
 net/netfilter/nf_nat_core.c                        |  16 +-
 net/netfilter/nf_nat_helper.c                      | 228 +---------
 net/netfilter/nf_nat_sip.c                         |   3 +-
 net/netfilter/nf_synproxy_core.c                   | 431 ++++++++++++++++++
 net/netfilter/nfnetlink_queue_ct.c                 |   8 +-
 31 files changed, 1953 insertions(+), 396 deletions(-)
