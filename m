From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/3] netfilter fixes for net
Date: Wed, 23 Oct 2013 11:15:21 +0200
Message-ID: <1382519724-3953-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains three netfilter fixes for your net
tree, they are:

* A couple of fixes to resolve info leak to userspace due to uninitialized
  memory area in ulogd, from Mathias Krause.

* Fix instruction ordering issues that may lead to the access of
  uninitialized data in x_tables. The problem involves the table update
 (producer) and the main packet matching (consumer) routines. Detected in
  SMP ARMv7, from Will Deacon.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

Thanks!

----------------------------------------------------------------

The following changes since commit c31eeaced22ce8bd61268a3c595d542bb38c0a4f:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2013-10-01 12:58:48 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to b416c144f46af1a30ddfa4e4319a8f077381ad63:

  netfilter: x_tables: fix ordering of jumpstack allocation and table update (2013-10-22 10:11:29 +0200)

----------------------------------------------------------------
Mathias Krause (2):
      netfilter: ebt_ulog: fix info leaks
      netfilter: ipt_ULOG: fix info leaks

Will Deacon (1):
      netfilter: x_tables: fix ordering of jumpstack allocation and table update

 net/bridge/netfilter/ebt_ulog.c |    9 +++------
 net/ipv4/netfilter/arp_tables.c |    5 +++++
 net/ipv4/netfilter/ip_tables.c  |    5 +++++
 net/ipv4/netfilter/ipt_ULOG.c   |    7 +------
 net/ipv6/netfilter/ip6_tables.c |    5 +++++
 net/netfilter/x_tables.c        |    7 ++++++-
 6 files changed, 25 insertions(+), 13 deletions(-)
