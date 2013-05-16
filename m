From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/4] Netfilter fixes for net (3.10-rc1)
Date: Thu, 16 May 2013 17:55:17 +0200
Message-ID: <1368719721-7470-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51402 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752673Ab3EPPza (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 May 2013 11:55:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains three Netfilter fixes and update
for the MAINTAINER file for your net tree, they are:

* Fix crash if nf_log_packet is called from conntrack, in that case
  both interfaces are NULL, from Hans Schillstrom. This bug introduced
  with the logging netns support in the previous merge window.

* Fix compilation of nf_log and nf_queue without CONFIG_PROC_FS,
  from myself. This bug was introduced in the previous merge window
  with the new netns support for the netfilter logging infrastructure.

* Fix possible crash in xt_TCPOPTSTRIP due to missing sanity
  checkings to validate that the TCP header is well-formed, from
  myself. I can find this bug in 2.6.25, probably it's been there
  since the beginning. I'll pass this to -stable.

* Update MAINTAINER file to point to new nf trees at git.kernel.org,
  remove Harald and use M: instead of P: (now obsolete tag) to
  keep Jozsef in the list of people.

Please, consider pulling this. Thanks!

----------------------------------------------------------------

The following changes since commit efeaa5550e4bfd335396415958fe3615530e5d5c:

  tcp: do not expire TCP fastopen cookies (2013-05-05 16:58:02 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to bc6bcb59dd7c184d229f9e86d08aa56059938a4c:

  netfilter: xt_TCPOPTSTRIP: fix possible mangling beyond packet boundary (2013-05-16 17:35:53 +0200)

----------------------------------------------------------------
Hans Schillstrom (1):
      netfilter: log: netns NULL ptr bug when calling from conntrack

Pablo Neira Ayuso (3):
      netfilter: nf_{log,queue}: fix compilation without CONFIG_PROC_FS
      netfilter: update MAINTAINERS file
      netfilter: xt_TCPOPTSTRIP: fix possible mangling beyond packet boundary

 MAINTAINERS                           |   10 +++++-----
 include/net/netfilter/nf_log.h        |    3 ++-
 include/net/netfilter/nfnetlink_log.h |    3 ++-
 net/bridge/netfilter/ebt_log.c        |   11 +++++------
 net/bridge/netfilter/ebt_ulog.c       |   18 +++++++++++-------
 net/ipv4/netfilter/ipt_ULOG.c         |   13 ++++++++-----
 net/netfilter/nf_log.c                |    7 +++++--
 net/netfilter/nfnetlink_log.c         |    6 ++++--
 net/netfilter/nfnetlink_queue_core.c  |    2 ++
 net/netfilter/xt_LOG.c                |   13 +++++++------
 net/netfilter/xt_NFLOG.c              |    3 ++-
 net/netfilter/xt_TCPOPTSTRIP.c        |   17 ++++++++++++++---
 12 files changed, 67 insertions(+), 39 deletions(-)
