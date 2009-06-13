From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 00/07: netfilter update
Date: Sat, 13 Jun 2009 15:09:34 +0200 (MEST)
Message-ID: <20090613130934.2112.65299.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37044 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753702AbZFMNJf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jun 2009 09:09:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

following is a final netfilter update for 2.6.31, containing:

- a fix for a warning when reading one of the the nf_log files

- a patch to use the new mod_timer_pending() function in conntrack
  to avoid taking the global conntrack lock for timer updates

- a set of patches from Pablo to make conntrack event notifications
  runtime selectable and optionally reliable. This works by making
  sure at least the final destroy event is successfully transmitted,
  otherwise the event is re-broadcast until a configurable timeout
  is reached.

- a patch from Joe Perches to convert a bunch of printks without a
  log level to pr_err()


Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git master

Thanks!


 include/linux/list_nulls.h                  |   18 +++
 include/net/netfilter/nf_conntrack.h        |    2 +
 include/net/netfilter/nf_conntrack_ecache.h |  175 ++++++++++++++---------
 include/net/netfilter/nf_conntrack_extend.h |    2 +
 include/net/netfilter/nf_conntrack_helper.h |    2 +
 include/net/netns/conntrack.h               |    7 +-
 net/netfilter/nf_conntrack_core.c           |  132 ++++++++++++-----
 net/netfilter/nf_conntrack_ecache.c         |  209 ++++++++++++++++++---------
 net/netfilter/nf_conntrack_helper.c         |   14 ++
 net/netfilter/nf_conntrack_netlink.c        |   68 +++++----
 net/netfilter/nf_log.c                      |    6 +-
 net/netfilter/x_tables.c                    |   16 +-
 12 files changed, 431 insertions(+), 220 deletions(-)

Joe Perches (1):
      x_tables: Convert printk to pr_err

Pablo Neira Ayuso (4):
      netfilter: conntrack: move event caching to conntrack extension infrastructure
      netfilter: conntrack: move helper destruction to nf_ct_helper_destroy()
      list_nulls: add hlist_nulls_add_head and hlist_nulls_del
      netfilter: conntrack: optional reliable conntrack event delivery

Patrick McHardy (2):
      netfilter: nf_log: fix sleeping function called from invalid context
      netfilter: nf_conntrack: use mod_timer_pending() for conntrack refresh
