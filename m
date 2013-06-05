From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/12] Netfilter/IPVS updates for net-next
Date: Wed,  5 Jun 2013 22:40:21 +0200
Message-ID: <1370464832-4216-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57424 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757250Ab3FEUkr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jun 2013 16:40:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@soleta.eu>

Hi David,

The following patchset contains the first batch of
Netfilter/IPVS updates for your net-next tree, they are:

* Three patches with improvements and code refactorization
  for nfnetlink_queue, from Florian Westphal.

* FTP helper now parses replies without brackets, as RFC1123
  recommends, from Jeff Mahoney.

* Rise a warning to tell everyone about ULOG deprecation,
  NFLOG has been already in the kernel tree for long time
  and supersedes the old logging over netlink stub, from
  myself.

* Don't panic if we fail to load netfilter core framework,
  just bail out instead, from myself.

* Add cond_resched_rcu, used by IPVS to allow rescheduling
  while walking over big hashtables, from Simon Horman.

* Change type of IPVS sysctl_sync_qlen_max sysctl to avoid
  possible overflow, from Zhang Yanfei.

* Use strlcpy instead of strncpy to skip zeroing of already
  initialized area to write the extension names in ebtables,
  from Chen Gang.

* Use already existing per-cpu notrack object from xt_CT,
  from Eric Dumazet.

* Save explicit socket lookup in xt_socket now that we have
  early demux, also from Eric Dumazet.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

Thanks!

----------------------------------------------------------------

The following changes since commit 8892475386e819aa50856947948c546ccc964d96:

  ipv6: use ipv6_addr_scope() helper (2013-05-23 01:17:47 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

for you to fetch changes up to 7f87712c0152511a1842698ad8dca425fee2dc4f:

  netfilter: nfnetlink_queue: only add CAP_LEN attr when needed (2013-06-05 12:40:54 +0200)

----------------------------------------------------------------
Chen Gang (1):
      bridge: netfilter: using strlcpy() instead of strncpy()

Eric Dumazet (2):
      netfilter: xt_CT: optimize XT_CT_NOTRACK
      netfilter: xt_socket: use IP early demux

Florian Westphal (3):
      netfilter: nfnetlink_queue: avoid peer_portid test
      netfilter: nfnetlink_queue: cleanup copy_range usage
      netfilter: nfnetlink_queue: only add CAP_LEN attr when needed

Jeff Mahoney (1):
      netfilter: Implement RFC 1123 for FTP conntrack

Pablo Neira Ayuso (2):
      netfilter: don't panic on error while walking through the init path
      netfilter: {ipt,ebt}_ULOG: rise warning on deprecation

Simon Horman (2):
      sched: add cond_resched_rcu() helper
      ipvs: use cond_resched_rcu() helper when walking connections

Zhang Yanfei (1):
      ipvs: change type of netns_ipvs->sysctl_sync_qlen_max

 include/linux/netfilter.h            |    2 +-
 include/linux/sched.h                |    9 +++++
 include/net/ip_vs.h                  |    8 ++--
 include/net/netns/x_tables.h         |    6 +++
 net/bridge/netfilter/ebt_ulog.c      |    6 +++
 net/bridge/netfilter/ebtables.c      |    6 +--
 net/ipv4/netfilter/Kconfig           |    2 +-
 net/ipv4/netfilter/ipt_ULOG.c        |    6 +++
 net/netfilter/core.c                 |   21 +++++++---
 net/netfilter/ipvs/ip_vs_conn.c      |   23 ++++-------
 net/netfilter/ipvs/ip_vs_ctl.c       |    4 +-
 net/netfilter/nf_conntrack_ftp.c     |   73 +++++++++++++++++++++++++---------
 net/netfilter/nf_log.c               |    5 +--
 net/netfilter/nfnetlink_queue_core.c |   29 +++++++-------
 net/netfilter/xt_CT.c                |   10 +++--
 net/netfilter/xt_socket.c            |   26 +++++++-----
 net/socket.c                         |    4 +-
 17 files changed, 155 insertions(+), 85 deletions(-)
