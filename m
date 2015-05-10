From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/2 net-next] critical ingress path performance improvements
Date: Sun, 10 May 2015 18:59:28 +0200
Message-ID: <1431277170-4618-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, ast@plumgrid.com, jhs@mojatatu.com,
	daniel@iogearbox.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40243 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751679AbbEJQyu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 May 2015 12:54:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch improves performance of the super-critical ingress path by moving
the qdisc ingress code to sch_ingress, where this really belongs.

This patchset also removes the Qdisc->enqueue() indirection since this does not
enqueue anything.

This is roughly 92199pps, ~0.42% more performance on my old box.

As it's been stated before, most users don't need this:

24824a09 ("net: dynamic ingress_queue allocation")

So getting the code inlined into the core introduces a penalty to everyone in
this world.

Please apply, thanks!

Pablo Neira Ayuso (2):
  net: kill useless net_*_ingress_queue() definitions when NET_CLS_ACT is unset
  net: move qdisc ingress filtering code where it belongs

 include/linux/netdevice.h |    3 +++
 include/linux/rtnetlink.h |    9 +--------
 net/core/dev.c            |   45 ++++++++++++---------------------------------
 net/sched/sch_ingress.c   |   43 +++++++++++++++++++++++++++++++++++++++----
 4 files changed, 55 insertions(+), 45 deletions(-)

-- 
1.7.10.4
