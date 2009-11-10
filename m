From: Patrick McHardy <kaber@trash.net>
Subject: netfilter -stable 00/02: netfilter -stable fixes
Date: Tue, 10 Nov 2009 11:40:18 +0100 (MET)
Message-ID: <20091110104014.8250.89589.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net
To: stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63907 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751690AbZKJKkN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 05:40:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following two patches fix two bug in netfilter:

- a bug in TCP conntrack sequence tracking when used with NAT helpers that
  enlarge packets

- a regression in the xt_connlimit match introduced in 2.6.29, causing
  false negatives

Please apply, thanks.


 include/net/netfilter/nf_conntrack.h   |    8 +--
 include/net/netfilter/nf_nat_helper.h  |    4 ++
 net/ipv4/netfilter/nf_nat_core.c       |    3 +
 net/ipv4/netfilter/nf_nat_helper.c     |   34 +++++++++++-----
 net/netfilter/nf_conntrack_core.c      |    8 ++++
 net/netfilter/nf_conntrack_proto_tcp.c |   64 +++++++++++++-------------------
 net/netfilter/xt_connlimit.c           |   10 ++---
 7 files changed, 71 insertions(+), 60 deletions(-)

Jan Engelhardt (1):
      netfilter: xt_connlimit: fix regression caused by zero family value

Jozsef Kadlecsik (1):
      netfilter: nf_nat: fix NAT issue in 2.6.30.4+
