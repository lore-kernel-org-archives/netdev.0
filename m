From: pablo@netfilter.org
Subject: [PATCH 0/4] netfilter updates for net-next (batch 3)
Date: Tue, 19 Jun 2012 05:16:25 +0200
Message-ID: <1340075789-6196-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

The following patchset provides fixes for issues that were recently introduced
by my new cthelper infrastructure. They have been spotted by Randy Dunlap,
Andrew Morton and Dan Carpenter.

The patches provide:

* compilation fixes if CONFIG_NF_CONNTRACK is disabled: I moved all the
  conntrack code from nfnetlink_queue.c to nfnetlink_queue_ct.c to avoid
  peppering the entire code with lots of ifdefs. I needed to rename
  nfnetlink_queue.c to nfnetlink_queue_core.c to get it working with the
  Makefile tweaks I've added.

* fix NULL pointer dereference via ctnetlink while trying to change the helper
  for an existing conntrack entry. I don't find any reasonable use case for
  changing the helper from one to another in run-time. Thus, now ctnetlink
  returns -EOPNOTSUPP for this operation.

* fix possible out-of-bound zeroing of the conntrack extension area due to
  the helper automatic assignation routine.

You can pull these changes from:

git://1984.lsi.us.es/nf-next master

Thanks!

Pablo Neira Ayuso (4):
  netfilter: ctnetlink: fix NULL dereference while trying to change helper
  netfilter: nf_ct_helper: disable automatic helper re-assignment of different type
  netfilter: fix compilation of the nfnl_cthelper if NF_CONNTRACK is unset
  netfilter: nfnetlink_queue: fix compilation with NF_CONNTRACK disabled

 include/net/netfilter/nfnetlink_queue.h            |   43 +++++++++
 net/netfilter/Kconfig                              |   29 ++++--
 net/netfilter/Makefile                             |    4 +-
 net/netfilter/nf_conntrack_helper.c                |    8 +-
 net/netfilter/nf_conntrack_netlink.c               |   24 ++---
 .../{nfnetlink_queue.c => nfnetlink_queue_core.c}  |   49 ++--------
 net/netfilter/nfnetlink_queue_ct.c                 |   97 ++++++++++++++++++++
 7 files changed, 187 insertions(+), 67 deletions(-)
 create mode 100644 include/net/netfilter/nfnetlink_queue.h
 rename net/netfilter/{nfnetlink_queue.c => nfnetlink_queue_core.c} (95%)
 create mode 100644 net/netfilter/nfnetlink_queue_ct.c

-- 
1.7.10

