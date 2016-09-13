From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/4] Netfilter fixes for net
Date: Tue, 13 Sep 2016 11:05:13 +0200
Message-ID: <1473757517-3764-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains Netfilter fixes for your net tree,
they are:

1) Endianess fix for the new nf_tables netlink trace infrastructure,
   NFTA_TRACE_POLICY endianess was not correct, patch from Liping Zhang.

2) Fix broken re-route after userspace queueing in nf_tables route
   chain. This patch is large but it is simple since it is just getting
   this code in sync with iptable_mangle. Also from Liping.

3) NAT mangling via ctnetlink lies to userspace when nf_nat_setup_info()
   fails to setup the NAT conntrack extension. This problem has been
   there since the beginning, but it can now show up after rhashtable
   conversion.

4) Fix possible NULL pointer dereference due to failures in allocating
   the synproxy and seqadj conntrack extensions, from Gao feng.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit 6e1ce3c3451291142a57c4f3f6f999a29fb5b3bc:

  af_unix: split 'u->readlock' into two: 'iolock' and 'bindlock' (2016-09-04 13:29:29 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git HEAD

for you to fetch changes up to 4440a2ab3b9f40dddbe006331ef0659c76859296:

  netfilter: synproxy: Check oom when adding synproxy and seqadj ct extensions (2016-09-13 10:50:56 +0200)

----------------------------------------------------------------
Gao Feng (1):
      netfilter: synproxy: Check oom when adding synproxy and seqadj ct extensions

Liping Zhang (2):
      netfilter: nf_tables_trace: fix endiness when dump chain policy
      netfilter: nft_chain_route: re-route before skb is queued to userspace

Pablo Neira Ayuso (1):
      netfilter: nf_nat: handle NF_DROP from nfnetlink_parse_nat_setup()

 include/net/netfilter/nf_conntrack_synproxy.h | 14 ++++++++++++++
 net/ipv4/netfilter/nft_chain_route_ipv4.c     | 11 +++++++----
 net/ipv6/netfilter/nft_chain_route_ipv6.c     | 10 +++++++---
 net/netfilter/nf_conntrack_core.c             |  6 +++---
 net/netfilter/nf_nat_core.c                   |  5 +++--
 net/netfilter/nf_tables_trace.c               |  2 +-
 6 files changed, 35 insertions(+), 13 deletions(-)
