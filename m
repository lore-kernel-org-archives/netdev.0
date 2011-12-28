From: pablo@netfilter.org
Subject: [PATCH 0/5] netfilter updates for net-next (2nd round)
Date: Wed, 28 Dec 2011 14:39:28 +0100
Message-ID: <1325079573-6120-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, jengelh@medozas.de,
	kaber@trash.net
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59542 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753879Ab1L1Njz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Dec 2011 08:39:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi Dave,

These are a couple of late updates from Jan Engelhardt, who has been
kind enough to recover the unmerged ECN support for IPv6. The IPv6
ECN support is original work from Patrick McHardy.

This includes one patch to obsolete the /proc/net/[nf|ip]_conntrack
outputs in favour of conntrack(8). Basically, it adds some compilation
time option to disable it. Later on, we can schedule it for removal.

You can pull this changes from:

git://1984.lsi.us.es/net-next nf-next

Let us know if it's too late for this merge window.
Thanks again!

Jan Engelhardt (4):
  netfilter: xtables: move ipt_ecn to xt_ecn
  netfilter: xtables: give xt_ecn its own name
  netfilter: xtables: collapse conditions in xt_ecn
  netfilter: provide config option to disable ancient procfs parts

Patrick McHardy (1):
  netfilter: xtables: add an IPv6 capable version of the ECN match

 include/linux/netfilter/Kbuild          |    1 +
 include/linux/netfilter/xt_ecn.h        |   35 ++++++
 include/linux/netfilter_ipv4/ipt_ecn.h  |   38 ++-----
 net/ipv4/netfilter/Kconfig              |   12 +-
 net/ipv4/netfilter/Makefile             |    1 -
 net/ipv4/netfilter/ipt_ecn.c            |  127 ----------------------
 net/netfilter/Kconfig                   |   19 ++++
 net/netfilter/Makefile                  |    1 +
 net/netfilter/nf_conntrack_expect.c     |   12 +-
 net/netfilter/nf_conntrack_standalone.c |    4 +-
 net/netfilter/xt_ecn.c                  |  179 +++++++++++++++++++++++++++++++
 11 files changed, 258 insertions(+), 171 deletions(-)
 create mode 100644 include/linux/netfilter/xt_ecn.h
 delete mode 100644 net/ipv4/netfilter/ipt_ecn.c
 create mode 100644 net/netfilter/xt_ecn.c

-- 
1.7.7.3
