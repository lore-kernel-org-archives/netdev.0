From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/5] Netfilter/IPVS fixes for net
Date: Mon, 24 Jun 2013 17:15:44 +0200
Message-ID: <1372086950-4042-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51469 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750964Ab3FXPQC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jun 2013 11:16:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains five fixes for Netfilter/IPVS, they are:

* A skb leak fix in fragmentation handling in case that helpers are in place,
  it occurs since the IPV6 NAT infrastructure, from Phil Oester.

* Fix SCTP port mangling in ICMP packets for IPVS, from Julian Anastasov.

* Fix event delivery in ctnetlink regarding the new connlabel infrastructure,
  from Florian Westphal.

* Fix mangling in the SIP NAT helper, from Balazs Peter Odor.

* Fix crash in ipt_ULOG introduced while adding netnamespace support,
  from Gao Feng.

I'll take care of passing several of these patches to -stable once they hit
Linus' tree.

You can pull these changes from:

git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

Thanks!

----------------------------------------------------------------

The following changes since commit b396966c4688522863572927cb30aa874b3ec504:

  netfilter: xt_TCPMSS: Fix missing fragmentation handling (2013-06-12 11:06:19 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to c8fc51cfa758be945c6113a4b446e0159070f768:

  netfilter: ipt_ULOG: fix incorrect setting of ulog timer (2013-06-24 17:10:44 +0200)

----------------------------------------------------------------
Balazs Peter Odor (1):
      netfilter: nf_nat_sip: fix mangling

Florian Westphal (1):
      netfilter: ctnetlink: send event when conntrack label was modified

Gao feng (1):
      netfilter: ipt_ULOG: fix incorrect setting of ulog timer

Julian Anastasov (1):
      ipvs: SCTP ports should be writable in ICMP packets

Phil Oester (1):
      netfilter: nf_conntrack_ipv6: Plug sk_buff leak in fragment handling

 net/ipv4/netfilter/ipt_ULOG.c                  |   12 ++++++++----
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |    2 +-
 net/netfilter/ipvs/ip_vs_core.c                |    3 ++-
 net/netfilter/nf_conntrack_labels.c            |    2 +-
 net/netfilter/nf_conntrack_netlink.c           |    1 +
 net/netfilter/nf_nat_sip.c                     |    3 ++-
 6 files changed, 15 insertions(+), 8 deletions(-)
