From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/4] Netfilter fixes for net
Date: Mon, 11 Aug 2014 19:06:15 +0200
Message-ID: <1407776779-9113-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains fixes for your net tree, they are:

1) Unitialize the set element key and data from the commit path,
   otherwise this leaks chain refcount if the transaction is aborted,
   reported by Thomas Graf.

2) Fix crash when updating chains without no counters in nf_tables,
   this slipped through in the new transaction infrastructure, reported
   by Matteo Croce.

3) Replace all mutex_lock_interruptible() by mutex_lock() in the Netfilter
   tree, suggested by Patrick McHardy. This implicitly fixes the problem
   that Eric Dumazet reported in: http://patchwork.ozlabs.org/patch/373076/

4) Fix error return code in nf_tables when deleting set element in
   nf_tables if the transaction cannot be allocated, from Julia Lawall.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit 33caee39925b887a99a2400dc5c980097c3573f9:

  Merge branch 'akpm' (patchbomb from Andrew Morton) (2014-08-06 21:14:42 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to 609ccf087747de48ef52160f93e0df864c532a61:

  netfilter: nf_tables: fix error return code (2014-08-08 16:47:29 +0200)

----------------------------------------------------------------
Julia Lawall (1):
      netfilter: nf_tables: fix error return code

Pablo Neira Ayuso (3):
      netfilter: nf_tables: uninitialize element key/data from the commit path
      netfilter: nf_tables: don't update chain with unset counters
      netfilter: don't use mutex_lock_interruptible()

 net/bridge/netfilter/ebtables.c |   10 ++-------
 net/netfilter/core.c            |   11 ++-------
 net/netfilter/ipvs/ip_vs_ctl.c  |   19 ++++------------
 net/netfilter/nf_sockopt.c      |    8 ++-----
 net/netfilter/nf_tables_api.c   |   30 ++++++++++++++-----------
 net/netfilter/x_tables.c        |   47 ++++++++++-----------------------------
 6 files changed, 39 insertions(+), 86 deletions(-)
