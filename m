From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/3] Netfilter fixes for net
Date: Tue, 15 Apr 2014 00:43:32 +0200
Message-ID: <1397515415-5477-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains three Netfilter fixes for your net tree,
they are:

* Fix missing generation sequence initialization which results in a splat
  if lockdep is enabled, it was introduced in the recent works to improve
  nf_conntrack scalability, from Andrey Vagin.

* Don't flush the GRE keymap list in nf_conntrack when the pptp helper is
  disabled otherwise this crashes due to a double release, from Andrey
  Vagin.

* Fix nf_tables cmp fast in big endian, from Patrick McHardy.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit 6859e7df6d9045a461412777e63bd8cef12f9705:

  netdev: remove potentially harmful checks (2014-04-07 15:52:07 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to b855d416dc17061ebb271ea7ef1201d100531770:

  netfilter: nf_tables: fix nft_cmp_fast failure on big endian for size < 4 (2014-04-14 10:38:02 +0200)

----------------------------------------------------------------
Andrey Vagin (2):
      netfilter: nf_conntrack: flush net_gre->keymap_list only from gre helper
      netfilter: nf_conntrack: initialize net.ct.generation

Patrick McHardy (1):
      netfilter: nf_tables: fix nft_cmp_fast failure on big endian for size < 4

 include/linux/netfilter/nf_conntrack_proto_gre.h |    1 -
 include/net/netfilter/nf_tables_core.h           |   10 ++++++++++
 net/netfilter/nf_conntrack_core.c                |    1 +
 net/netfilter/nf_conntrack_pptp.c                |   20 +-------------------
 net/netfilter/nf_conntrack_proto_gre.c           |    3 +--
 net/netfilter/nf_tables_core.c                   |    3 +--
 net/netfilter/nft_cmp.c                          |    2 +-
 7 files changed, 15 insertions(+), 25 deletions(-)
