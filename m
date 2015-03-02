From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/5] Netfilter updates for net-next
Date: Mon,  2 Mar 2015 12:43:42 +0100
Message-ID: <1425296627-16391-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55930 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751097AbbCBLkZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2015 06:40:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

A small batch with accumulated updates in nf-next, mostly IPVS updates,
they are:

1) Add 64-bits stats counters to IPVS, from Julian Anastasov.

2) Move NETFILTER_XT_MATCH_ADDRTYPE out of NETFILTER_ADVANCED as docker
seem to require this, from Anton Blanchard.

3) Use boolean instead of numeric value in set_match_v*(), from
coccinelle via Fengguang Wu.

4) Allows rescheduling of new connections in IPVS when port reuse is
detected, from Marcelo Ricardo Leitner.

5) Add missing bits to support arptables extensions from nft_compat,
from Arturo Borrero.

Patrick is preparing a large batch to enhance the set infrastructure,
named expressions among other things, that should follow up soon after
this batch.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit 4c1017aa80c95a74703139bb95c4ce0d130efe4d:

  netfilter: nft_lookup: add missing attribute validation for NFTA_LOOKUP_SET_ID (2015-01-30 19:08:20 +0100)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

for you to fetch changes up to 5f15893943bfdc804e8703c5aa2c8dd8bf7ddf3f:

  netfilter: nft_compat: add support for arptables extensions (2015-03-02 12:28:13 +0100)

----------------------------------------------------------------
Anton Blanchard (1):
      netfilter: Don't hide NETFILTER_XT_MATCH_ADDRTYPE behind NETFILTER_ADVANCED

Arturo Borrero (1):
      netfilter: nft_compat: add support for arptables extensions

Julian Anastasov (1):
      ipvs: use 64-bit rates in stats

Marcelo Ricardo Leitner (1):
      ipvs: allow rescheduling of new connections when port reuse is detected

Wu Fengguang (1):
      netfilter: ipset: fix boolreturn.cocci warnings

 Documentation/networking/ipvs-sysctl.txt |   21 ++++
 include/net/ip_vs.h                      |   61 +++++++---
 include/uapi/linux/ip_vs.h               |    7 +-
 net/netfilter/Kconfig                    |    2 +-
 net/netfilter/ipvs/ip_vs_core.c          |   69 +++++++----
 net/netfilter/ipvs/ip_vs_ctl.c           |  182 ++++++++++++++++++++----------
 net/netfilter/ipvs/ip_vs_est.c           |  102 ++++++++---------
 net/netfilter/ipvs/ip_vs_sync.c          |   21 +++-
 net/netfilter/nft_compat.c               |    9 ++
 net/netfilter/xt_set.c                   |    4 +-
 10 files changed, 326 insertions(+), 152 deletions(-)
