From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/8] Netfilter updates for net-next
Date: Wed, 13 Apr 2016 01:02:38 +0200
Message-ID: <1460502166-20340-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains the first batch of Netfilter updates for
your net-next tree.

1) Define pr_fmt() in nf_conntrack, from Weongyo Jeong.

2) Define and register netfilter's afinfo for the bridge family,
   this comes in preparation for native nfqueue's bridge for nft,
   from Stephane Bryant.

3) Add new attributes to store layer 2 and VLAN headers to nfqueue,
   also from Stephane Bryant.

4) Parse new NFQA_VLAN and NFQA_L2HDR nfqueue netlink attributes
   coming from userspace, from Stephane Bryant.

5) Use net->ipv6.devconf_all->hop_limit instead of hardcoded hop_limit
   in IPv6 SYNPROXY, from Liping Zhang.

6) Remove unnecessary check for dst == NULL in nf_reject_ipv6,
   from Haishuang Yan.

7) Deinline ctnetlink event report functions, from Florian Westphal.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit e46b4e2b46e173889b19999b8bd033d5e8b3acf0:

  Merge tag 'trace-v4.6' of git://git.kernel.org/pub/scm/linux/kernel/git/rostedt/linux-trace (2016-03-24 10:52:25 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git HEAD

for you to fetch changes up to ecdfb48cddfd1096343148113d5b1bd789033aa8:

  netfilter: conntrack: move expectation event helper to ecache.c (2016-04-12 23:01:57 +0200)

----------------------------------------------------------------
Florian Westphal (2):
      netfilter: conntrack: de-inline nf_conntrack_eventmask_report
      netfilter: conntrack: move expectation event helper to ecache.c

Haishuang Yan (1):
      netfilter: ipv6: unnecessary to check whether ip6_route_output() returns NULL

Liping Zhang (1):
      netfilter: ip6t_SYNPROXY: remove magic number for hop_limit

Stephane Bryant (3):
      netfilter: bridge: add nf_afinfo to enable queuing to userspace
      netfilter: bridge: pass L2 header and VLAN as netlink attributes in queues to userspace
      netfilter: bridge: nf queue verdict to use NFQA_VLAN and NFQA_L2HDR

Weongyo Jeong (1):
      netfilter: nf_conntrack: Uses pr_fmt() for logging.

 include/net/netfilter/nf_conntrack_ecache.h    | 108 ++++---------------------
 include/uapi/linux/netfilter/nfnetlink_queue.h |  10 +++
 net/bridge/netfilter/nf_tables_bridge.c        |  47 ++++++++++-
 net/ipv6/netfilter/ip6t_SYNPROXY.c             |  56 +++++++------
 net/ipv6/netfilter/nf_reject_ipv6.c            |   2 +-
 net/netfilter/nf_conntrack_core.c              |  15 ++--
 net/netfilter/nf_conntrack_ecache.c            |  84 +++++++++++++++++++
 net/netfilter/nfnetlink_queue.c                | 105 ++++++++++++++++++++++++
 8 files changed, 298 insertions(+), 129 deletions(-)
