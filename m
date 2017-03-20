From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/22] Netfilter/IPVS updates for net-next
Date: Mon, 20 Mar 2017 11:08:28 +0100
Message-ID: <1490004530-9128-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51700 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753977AbdCTKJ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Mar 2017 06:09:28 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id B2674523DF
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:08:59 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 9F027DA86D
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:08:59 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 27846DA807
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:08:57 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains Netfilter/IPVS updates for your
net-next tree. A couple of new features for nf_tables, and unsorted
cleanups and incremental updates for the Netfilter tree. More
specifically, they are:

1) Allow to check for TCP option presence via nft_exthdr, patch
   from Phil Sutter.

2) Add symmetric hash support to nft_hash, from Laura Garcia Liebana.

3) Use pr_cont() in ebt_log, from Joe Perches.

4) Remove some dead code in arp_tables reported via static analysis
   tool, from Colin Ian King.

5) Consolidate nf_tables expression validation, from Liping Zhang.

6) Consolidate set lookup via nft_set_lookup().

7) Remove unnecessary rcu read lock side in bridge netfilter, from
   Florian Westphal.

8) Remove unused variable in nf_reject_ipv4, from Tahee Yoo.

9) Pass nft_ctx struct to object initialization indirections, from
   Florian Westphal.

10) Add code to integrate conntrack helper into nf_tables, also from
    Florian.

11) Allow to check if interface index or name exists via
    NFTA_FIB_F_PRESENT, from Phil Sutter.

12) Simplify resolve_normal_ct(), from Florian.

13) Use per-limit spinlock in nft_limit and xt_limit, from Liping Zhang.

14) Use rwlock in nft_set_rbtree set, also from Liping Zhang.

15) One patch to remove a useless printk at netns init path in ipvs,
    and several patches to document IPVS knobs.

16) Use refcount_t for reference counter in the Netfilter/IPVS code,
    from Elena Reshetova.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit 8d70eeb84ab277377c017af6a21d0a337025dede:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2017-03-04 17:31:39 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git HEAD

for you to fetch changes up to 4485a841be171dbd8d3f0701b00f59d389e94ce6:

  netfilter: fix the warning on unused refcount variable (2017-03-20 10:49:12 +0100)

----------------------------------------------------------------
Colin Ian King (1):
      netfilter: arp_tables: remove redundant check on ret being non-zero

Cong Wang (1):
      ipvs: remove an annoying printk in netns init

Florian Westphal (4):
      netfilter: bridge: remove unneeded rcu_read_lock
      netfilter: provide nft_ctx in object init function
      netfilter: nft_ct: add helper set support
      netfilter: nf_conntrack: reduce resolve_normal_ct args

Hangbin Liu (4):
      ipvs: fix sync_threshold description and add sync_refresh_period, sync_retries
      ipvs: Document sysctl sync_qlen_max and sync_sock_size
      ipvs: Document sysctl sync_ports
      ipvs: Document sysctl pmtu_disc

Joe Perches (1):
      netfilter: Use pr_cont where appropriate

Laura Garcia Liebana (2):
      netfilter: nft_hash: rename nft_hash to nft_jhash
      netfilter: nft_hash: support of symmetric hash

Liping Zhang (3):
      netfilter: nf_tables: validate the expr explicitly after init successfully
      netfilter: limit: use per-rule spinlock to improve the scalability
      netfilter: nft_set_rbtree: use per-set rwlock to improve the scalability

Pablo Neira Ayuso (1):
      netfilter: nf_tables: add nft_set_lookup()

Phil Sutter (2):
      netfilter: nft_exthdr: Allow checking TCP option presence, too
      netfilter: nft_fib: Support existence check

Reshetova, Elena (2):
      netfilter: refcounter conversions
      netfilter: fix the warning on unused refcount variable

Taehee Yoo (1):
      netfilter: nf_reject: remove unused variable

 Documentation/networking/ipvs-sysctl.txt     |  68 +++++++++--
 include/net/ip_vs.h                          |  16 +--
 include/net/netfilter/nf_conntrack_expect.h  |   4 +-
 include/net/netfilter/nf_conntrack_timeout.h |   3 +-
 include/net/netfilter/nf_tables.h            |  12 +-
 include/net/netfilter/nft_fib.h              |   2 +-
 include/uapi/linux/netfilter/nf_tables.h     |  26 +++-
 net/bridge/br_netfilter_hooks.c              |   3 -
 net/bridge/netfilter/ebt_log.c               |  34 +++---
 net/bridge/netfilter/nft_reject_bridge.c     |   6 +-
 net/ipv4/netfilter/arp_tables.c              |   2 -
 net/ipv4/netfilter/ipt_CLUSTERIP.c           |  19 +--
 net/ipv4/netfilter/nf_nat_snmp_basic.c       |  15 +--
 net/ipv4/netfilter/nf_reject_ipv4.c          |   3 -
 net/ipv4/netfilter/nft_fib_ipv4.c            |   4 +-
 net/ipv6/netfilter/nft_fib_ipv6.c            |   2 +-
 net/netfilter/ipvs/ip_vs_conn.c              |  24 ++--
 net/netfilter/ipvs/ip_vs_core.c              |   6 +-
 net/netfilter/ipvs/ip_vs_ctl.c               |  12 +-
 net/netfilter/ipvs/ip_vs_lblc.c              |   2 +-
 net/netfilter/ipvs/ip_vs_lblcr.c             |   6 +-
 net/netfilter/ipvs/ip_vs_nq.c                |   2 +-
 net/netfilter/ipvs/ip_vs_proto_sctp.c        |   2 +-
 net/netfilter/ipvs/ip_vs_proto_tcp.c         |   2 +-
 net/netfilter/ipvs/ip_vs_rr.c                |   2 +-
 net/netfilter/ipvs/ip_vs_sed.c               |   2 +-
 net/netfilter/ipvs/ip_vs_wlc.c               |   2 +-
 net/netfilter/ipvs/ip_vs_wrr.c               |   2 +-
 net/netfilter/nf_conntrack_core.c            |  57 ++++-----
 net/netfilter/nf_conntrack_expect.c          |  10 +-
 net/netfilter/nf_conntrack_netlink.c         |   4 +-
 net/netfilter/nf_tables_api.c                |  49 ++++++--
 net/netfilter/nfnetlink_acct.c               |  15 +--
 net/netfilter/nfnetlink_cttimeout.c          |  12 +-
 net/netfilter/nfnetlink_log.c                |  14 ++-
 net/netfilter/nft_compat.c                   |   8 --
 net/netfilter/nft_counter.c                  |   3 +-
 net/netfilter/nft_ct.c                       | 171 +++++++++++++++++++++++++++
 net/netfilter/nft_dynset.c                   |  14 +--
 net/netfilter/nft_exthdr.c                   |  13 +-
 net/netfilter/nft_fib.c                      |  16 ++-
 net/netfilter/nft_hash.c                     | 133 ++++++++++++++++++---
 net/netfilter/nft_limit.c                    |  10 +-
 net/netfilter/nft_lookup.c                   |  14 +--
 net/netfilter/nft_masq.c                     |   4 -
 net/netfilter/nft_meta.c                     |   4 -
 net/netfilter/nft_nat.c                      |   4 -
 net/netfilter/nft_objref.c                   |  14 +--
 net/netfilter/nft_quota.c                    |   3 +-
 net/netfilter/nft_redir.c                    |   4 -
 net/netfilter/nft_reject.c                   |   5 -
 net/netfilter/nft_reject_inet.c              |   6 +-
 net/netfilter/nft_set_rbtree.c               |  31 ++---
 net/netfilter/xt_limit.c                     |  11 +-
 54 files changed, 615 insertions(+), 297 deletions(-)
