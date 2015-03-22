From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/6] Netfilter fixes for net
Date: Sun, 22 Mar 2015 19:46:32 +0100
Message-ID: <1427049998-5665-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:33383 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751840AbbCVSmr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Mar 2015 14:42:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains Netfilter fixes for your net tree,
they are:

1) Fix missing initialization of tuple structure in nfnetlink_cthelper
   to avoid mismatches when looking up to attach userspace helpers to
   flows, from Ian Wilson.

2) Fix potential crash in nft_hash when we hit -EAGAIN in
   nft_hash_walk(), from Herbert Xu.

3) We don't need to indicate the hook information to update the
   basechain default policy in nf_tables.

4) Restore tracing over nfnetlink_log due to recent rework to
   accomodate logging infrastructure into nf_tables.

5) Fix wrong IP6T_INV_PROTO check in xt_TPROXY.

6) Set IP6T_F_PROTO flag in nft_compat so we can use SYNPROXY6 and
   REJECT6 from xt over nftables.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit 4363890079674db7b00cf1bb0e6fa430e846e86b:

  net: Handle unregister properly when netdev namespace change fails. (2015-03-10 21:59:46 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to 749177ccc74f9c6d0f51bd78a15c652a2134aa11:

  netfilter: nft_compat: set IP6T_F_PROTO flag if protocol is set (2015-03-22 19:32:05 +0100)

----------------------------------------------------------------
Herbert Xu (1):
      netfilter: Fix potential crash in nft_hash walker

Ian Wilson (1):
      netfilter: Zero the tuple in nfnl_cthelper_parse_tuple()

Pablo Neira Ayuso (4):
      netfilter: nf_tables: allow to change chain policy without hook if it exists
      netfilter: restore rule tracing via nfnetlink_log
      netfilter: xt_TPROXY: fix invflags check in tproxy_tg6_check()
      netfilter: nft_compat: set IP6T_F_PROTO flag if protocol is set

 include/net/netfilter/nf_log.h     |   10 ++++++++++
 net/ipv4/netfilter/ip_tables.c     |    6 +++---
 net/ipv6/netfilter/ip6_tables.c    |    6 +++---
 net/netfilter/nf_log.c             |   24 ++++++++++++++++++++++++
 net/netfilter/nf_tables_api.c      |    5 ++++-
 net/netfilter/nf_tables_core.c     |    8 ++++----
 net/netfilter/nfnetlink_cthelper.c |    3 +++
 net/netfilter/nft_compat.c         |    6 ++++++
 net/netfilter/nft_hash.c           |    2 ++
 net/netfilter/xt_TPROXY.c          |    4 ++--
 10 files changed, 61 insertions(+), 13 deletions(-)
