From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/6] Netfilter/IPVS fixes for net
Date: Tue,  1 Oct 2013 11:08:25 +0200
Message-ID: <1380618511-6109-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57957 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751174Ab3JAJJh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Oct 2013 05:09:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains Netfilter/IPVS fixes for your net
tree, they are:

* Fix BUG_ON splat due to malformed TCP packets seen by synproxy, from
  Patrick McHardy.

* Fix possible weight overflow in lblc and lblcr schedulers due to
  32-bits arithmetics, from Simon Kirby.

* Fix possible memory access race in the lblc and lblcr schedulers,
  introduced when it was converted to use RCU, two patches from
  Julian Anastasov.

* Fix hard dependency on CPU 0 when reading per-cpu stats in the
  rate estimator, from Julian Anastasov.

* Fix race that may lead to object use after release, when invoking
  ipvsadm -C && ipvsadm -R, introduced when adding RCU, from Julian
  Anastasov.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

Thanks!

----------------------------------------------------------------

The following changes since commit 61c5923a2f2d8ab98a1e3c76f17e0f4a871ec75b:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf (2013-09-17 20:22:53 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to f4a87e7bd2eaef26a3ca25437ce8b807de2966ad:

  netfilter: synproxy: fix BUG_ON triggered by corrupt TCP packets (2013-09-30 12:44:38 +0200)

----------------------------------------------------------------
Julian Anastasov (4):
      ipvs: make the service replacement more robust
      ipvs: do not use dest after ip_vs_dest_put in LBLC
      ipvs: do not use dest after ip_vs_dest_put in LBLCR
      ipvs: stats should not depend on CPU 0

Patrick McHardy (1):
      netfilter: synproxy: fix BUG_ON triggered by corrupt TCP packets

Simon Kirby (1):
      ipvs: fix overflow on dest weight multiply

 include/net/ip_vs.h                           |    9 +--
 include/net/netfilter/nf_conntrack_synproxy.h |    2 +-
 net/ipv4/netfilter/ipt_SYNPROXY.c             |   10 ++-
 net/ipv6/netfilter/ip6t_SYNPROXY.c            |   10 ++-
 net/netfilter/ipvs/ip_vs_core.c               |   12 +++-
 net/netfilter/ipvs/ip_vs_ctl.c                |   86 ++++++++++---------------
 net/netfilter/ipvs/ip_vs_est.c                |    4 +-
 net/netfilter/ipvs/ip_vs_lblc.c               |   72 ++++++++++-----------
 net/netfilter/ipvs/ip_vs_lblcr.c              |   62 ++++++++----------
 net/netfilter/ipvs/ip_vs_nq.c                 |    8 +--
 net/netfilter/ipvs/ip_vs_sed.c                |    8 +--
 net/netfilter/ipvs/ip_vs_wlc.c                |    6 +-
 net/netfilter/nf_synproxy_core.c              |   12 ++--
 13 files changed, 143 insertions(+), 158 deletions(-)
