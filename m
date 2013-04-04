From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/5] netfilter updates for net
Date: Thu,  4 Apr 2013 14:56:04 +0200
Message-ID: <1365080169-6880-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40139 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760835Ab3DDM4i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Apr 2013 08:56:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains netfilter updates for your net tree,
they are:

* Fix missing the skb->trace reset in nf_reset, noticed by Gao Feng
  while using the TRACE target with several net namespaces.

* Fix prefix translation in IPv6 NPT if non-multiple of 32 prefixes
  are used, from Matthias Schiffer.

* Fix invalid nfacct objects with empty name, they are now rejected
  with -EINVAL, spotted by Michael Zintakis, patch from myself.

* A couple of fixes for wrong return values in the error path of
  nfnetlink_queue and nf_conntrack, from Wei Yongjun.

You can pull these changes from:

git://1984.lsi.us.es/nf master

Thanks!

P.S: Next pull request for fixes will be done from my new trees at
git.kernel.org. I still have to make a pull request for nf-next from 1984
anytime soon though. After that, I'll close the trees in that machine.

Gao feng (1):
  netfilter: reset nf_trace in nf_reset

Matthias Schiffer (1):
  netfilter: ip6t_NPT: Fix translation for non-multiple of 32 prefix lengths

Pablo Neira Ayuso (1):
  netfilter: nfnetlink_acct: return -EINVAL if object name is empty

Wei Yongjun (2):
  netfilter: nfnetlink_queue: fix error return code in nfnetlink_queue_init()
  netfilter: nf_conntrack: fix error return code

 include/linux/skbuff.h                  |    3 +++
 net/ipv6/netfilter/ip6t_NPT.c           |    2 +-
 net/netfilter/nf_conntrack_standalone.c |    1 +
 net/netfilter/nfnetlink_acct.c          |    2 ++
 net/netfilter/nfnetlink_queue_core.c    |    4 +++-
 5 files changed, 10 insertions(+), 2 deletions(-)

-- 
1.7.10.4
