From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/18] netfilter updates for net-next (try 2)
Date: Mon, 29 Apr 2013 20:22:06 +0200
Message-ID: <1367259744-8922-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

This is a second pull request resolving the compilation issue in
net/sched/em_ipset.

The following patchset contains relevant updates for the Netfilter
tree, they are:

* Enhancements for ipset: Add the counter extension for sets, this
  information can be used from the iptables set match, to change
  the matching behaviour. Jozsef required to add the extension
  infrastructure and moved the existing timeout support upon it.
  This also includes a change in net/sched/em_ipset to adapt it to
  the new extension structure.

* Enhancements for performance boosting in nfnetlink_queue: Add new
  configuration flags that allows user-space to receive big packets (GRO)
  and to disable checksumming calculation. This were proposed by Eric
  Dumazet during the Netfilter Workshop 2013 in Copenhagen. Florian
  Westphal was kind enough to find the time to materialize the proposal.

* A sparse fix from Simon, he noticed it in the SCTP NAT helper, the fix
  required a change in the interface of sctp_end_cksum.

The following changes since commit 37fe0660981d7a1577409226f77554c2c5123e27:

  net: fix address check in rtnl_fdb_del (2013-04-25 04:14:08 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

for you to fetch changes up to eee1d5a14780b9391ec51f3feaf4cffb521ddbb1:

  sctp: Correct type and usage of sctp_end_cksum() (2013-04-29 20:09:08 +0200)

----------------------------------------------------------------
Florian Westphal (4):
      netfilter: nf_queue: move device refcount bump to extra function
      netfilter: move skb_gso_segment into nfnetlink_queue module
      netfilter: nfnetlink_queue: add skb info attribute
      netfilter: nfnetlink_queue: avoid expensive gso segmentation and checksum fixup

Jozsef Kadlecsik (13):
      netfilter: ipset: Make possible to test elements marked with nomatch
      netfilter: ipset: Move often used IPv6 address masking function to header file
      netfilter: ipset: Introduce extensions to elements in the core
      netfilter: ipset: Unified bitmap type generation
      netfilter: ipset: Bitmap types using the unified code base
      netfilter: ipset: Unified hash type generation
      netfilter: ipset: Hash types using the unified code base
      netfilter: ipset: list:set type using the extension interface
      netfilter: ipset: Introduce the counter extension in the core
      netfilter: ipset: The bitmap types with counter support
      netfilter: ipset: The hash types with counter support
      netfilter: ipset: The list:set type with counter support
      netfilter: ipset: set match: add support to match the counters

Simon Horman (1):
      sctp: Correct type and usage of sctp_end_cksum()

 include/linux/netfilter/ipset/ip_set.h         |  126 ++-
 include/linux/netfilter/ipset/ip_set_ahash.h   | 1241 ------------------------
 include/linux/netfilter/ipset/ip_set_bitmap.h  |    6 +
 include/linux/netfilter/ipset/ip_set_timeout.h |  102 +-
 include/linux/netfilter/ipset/pfxlen.h         |    9 +
 include/net/netfilter/nf_queue.h               |    6 +
 include/net/sctp/checksum.h                    |    2 +-
 include/uapi/linux/netfilter/ipset/ip_set.h    |   36 +-
 include/uapi/linux/netfilter/nfnetlink_queue.h |   10 +-
 include/uapi/linux/netfilter/xt_set.h          |    9 +
 net/netfilter/ipset/ip_set_bitmap_gen.h        |  277 ++++++
 net/netfilter/ipset/ip_set_bitmap_ip.c         |  411 +++-----
 net/netfilter/ipset/ip_set_bitmap_ipmac.c      |  624 +++++-------
 net/netfilter/ipset/ip_set_bitmap_port.c       |  414 +++-----
 net/netfilter/ipset/ip_set_core.c              |   36 +-
 net/netfilter/ipset/ip_set_hash_gen.h          | 1100 +++++++++++++++++++++
 net/netfilter/ipset/ip_set_hash_ip.c           |  344 ++-----
 net/netfilter/ipset/ip_set_hash_ipport.c       |  362 +++----
 net/netfilter/ipset/ip_set_hash_ipportip.c     |  368 +++----
 net/netfilter/ipset/ip_set_hash_ipportnet.c    |  469 ++++-----
 net/netfilter/ipset/ip_set_hash_net.c          |  402 +++-----
 net/netfilter/ipset/ip_set_hash_netiface.c     |  478 ++++-----
 net/netfilter/ipset/ip_set_hash_netport.c      |  456 +++------
 net/netfilter/ipset/ip_set_list_set.c          |  622 +++++++-----
 net/netfilter/nf_nat_proto_sctp.c              |    5 +-
 net/netfilter/nf_queue.c                       |  143 +--
 net/netfilter/nfnetlink_queue_core.c           |  173 +++-
 net/netfilter/xt_set.c                         |   94 +-
 net/sched/em_ipset.c                           |    2 +-
 29 files changed, 3688 insertions(+), 4639 deletions(-)
 delete mode 100644 include/linux/netfilter/ipset/ip_set_ahash.h
 create mode 100644 net/netfilter/ipset/ip_set_bitmap_gen.h
 create mode 100644 net/netfilter/ipset/ip_set_hash_gen.h
