From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/4] Netfilter/nf_tables fixes
Date: Tue, 15 Jul 2014 16:05:18 +0200
Message-ID: <1405433122-7440-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains nf_tables fixes, they are:

1) Fix wrong transaction handling when the table flags are not
   modified.

2) Fix missing rcu read_lock section in the netlink dump path, which
   is not protected by the nfnl_lock.

3) Set NLM_F_DUMP_INTR in the netlink dump path to indicate
   interferences with updates.

4) Fix 64 bits chain counters when they are retrieved from a 32 bits
   arch, from Eric Dumazet.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit e940f5d6ba6a01f8dbb870854d5205d322452730:

  ipv6: Fix MLD Query message check (2014-06-27 00:21:50 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to ce355e209feb030945dae4c358c02f29a84f3f8b:

  netfilter: nf_tables: 64bit stats need some extra synchronization (2014-07-14 12:00:17 +0200)

----------------------------------------------------------------
Eric Dumazet (1):
      netfilter: nf_tables: 64bit stats need some extra synchronization

Pablo Neira Ayuso (3):
      netfilter: nf_tables: skip transaction if no update flags in tables
      netfilter: nf_tables: safe RCU iteration on list when dumping
      netfilter: nf_tables: set NLM_F_DUMP_INTR if netlink dumping is stale

 include/net/netfilter/nf_tables.h |    6 +-
 include/net/netns/nftables.h      |    2 +-
 net/netfilter/nf_tables_api.c     |  140 +++++++++++++++++++++++--------------
 net/netfilter/nf_tables_core.c    |   10 +--
 4 files changed, 100 insertions(+), 58 deletions(-)
