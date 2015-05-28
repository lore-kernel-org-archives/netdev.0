From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/4] Netfilter updates for net-next
Date: Fri, 29 May 2015 01:44:51 +0200
Message-ID: <1432856695-23831-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40644 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932403AbbE1Xj7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 19:39:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains Netfilter updates for net-next, they are:

1) default CONFIG_NETFILTER_INGRESS to y for easier compile-testing of all
   options.

2) Allow to bind a table to net_device. This introduces the internal
   NFT_AF_NEEDS_DEV flag to perform a mandatory check for this binding.
   This is required by the next patch.

3) Add the 'netdev' table family, this new table allows you to create ingress
   filter basechains. This provides access to the existing nf_tables features
   from ingress.

4) Kill unused argument from compat_find_calc_{match,target} in ip_tables
   and ip6_tables, from Florian Westphal.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit 76d7c457659dfc05d5a23cd0b21fea333d1788cd:

  Merge branch 'icmp_frag' (2015-05-19 00:15:50 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

for you to fetch changes up to ed6c4136f1571bd6ab362afc3410905a8a69ca42:

  netfilter: nf_tables: add netdev table to filter from ingress (2015-05-26 18:41:23 +0200)

----------------------------------------------------------------
Florian Westphal (1):
      netfilter: remove unused comefrom hookmask argument

Pablo Neira Ayuso (3):
      netfilter: default CONFIG_NETFILTER_INGRESS to y
      netfilter: nf_tables: allow to bind table to net_device
      netfilter: nf_tables: add netdev table to filter from ingress

 include/net/netfilter/nf_tables.h        |    8 ++
 include/net/netns/nftables.h             |    1 +
 include/uapi/linux/netfilter/nf_tables.h |    2 +
 net/ipv4/netfilter/ip_tables.c           |    4 +-
 net/ipv6/netfilter/ip6_tables.c          |    4 +-
 net/netfilter/Kconfig                    |    6 +
 net/netfilter/Makefile                   |    1 +
 net/netfilter/nf_tables_api.c            |   46 +++++++-
 net/netfilter/nf_tables_netdev.c         |  183 ++++++++++++++++++++++++++++++
 9 files changed, 244 insertions(+), 11 deletions(-)
 create mode 100644 net/netfilter/nf_tables_netdev.c
