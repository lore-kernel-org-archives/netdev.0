From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 00/04: netfilter fixes
Date: Mon, 16 Mar 2009 17:08:42 +0100 (MET)
Message-ID: <20090316160841.3567.94089.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

the following patches for 2.6.29 fix a few netfilter bugs:

- avoid event delivery for conntracks dropped because of clashes (from Pablo)

- fix for a ctnetlink crash during expectation creation caused by a missing
  initialization. Also from Pablo.

- a fix for correctly handling NF_DROP return values from the conntrack
  ->packet() callbacks. From Christoph Pasch.

- reordering of the header checks in IPv6 conntrack reassembly to avoid an
  incorrect log message with NEXTHDR_NONE. Also from Christoph.

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git

Thanks!


 include/net/netfilter/nf_conntrack_core.h |    3 ++-
 net/ipv6/netfilter/nf_conntrack_reasm.c   |    8 ++++----
 net/netfilter/nf_conntrack_core.c         |    2 +-
 net/netfilter/nf_conntrack_netlink.c      |    1 +
 net/netfilter/nf_conntrack_proto_tcp.c    |    4 ++--
 5 files changed, 10 insertions(+), 8 deletions(-)

Christoph Paasch (2):
      netfilter: conntrack: fix dropping packet after l4proto->packet()
      netfilter: conntrack: check for NEXTHDR_NONE before header sanity checking

Pablo Neira Ayuso (2):
      netfilter: conntrack: don't deliver events for racy packets
      netfilter: ctnetlink: fix crash during expectation creation
