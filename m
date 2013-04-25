From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/10] netfilter fixes for net-next
Date: Thu, 25 Apr 2013 02:22:11 +0200
Message-ID: <1366849341-10466-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41101 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758615Ab3DYAWa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Apr 2013 20:22:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains fixes for recently applied
Netfilter/IPVS updates to the net-next tree, most relevantly
they are:

* Fix sparse warnings introduced in the RCU conversion, from
  Julian Anastasov.

* Fix wrong endianness in the size field of IPVS sync messages,
  from Simon Horman.

* Fix missing if checking in nf_xfrm_me_harder, from Dan Carpenter.

* Fix off by one access in the IPVS SCTP tracking code, again from
  Dan Carpenter.

The following changes since commit 3e3251b3f289528732edab386ddf73ac428359b7:

  net: sctp: minor: remove dead code from sctp_packet (2013-04-22 16:25:21 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

for you to fetch changes up to e7e6f6300faaafe05380ca5455b99c2a8f1f51a0:

  netfilter: nf_nat: missing condition in nf_xfrm_me_harder() (2013-04-25 01:58:16 +0200)

----------------------------------------------------------------
Dan Carpenter (2):
      ipvs: off by one in set_sctp_state()
      netfilter: nf_nat: missing condition in nf_xfrm_me_harder()

Julian Anastasov (5):
      ipvs: properly dereference dest_dst in ip_vs_forget_dev
      ipvs: fix sparse warnings for ip_vs_conn listing
      ipvs: fix the remaining sparse warnings in ip_vs_ctl.c
      ipvs: fix sparse warnings in lblc and lblcr
      ipvs: fix sparse warnings for some parameters

Simon Horman (3):
      ipvs: Avoid shadowing net variable in ip_vs_leave()
      ipvs: Use min3() in ip_vs_dbg_callid()
      ipvs: Use network byte order for sync message size

 include/net/ip_vs.h                   |    8 ++---
 include/uapi/linux/ip_vs.h            |    4 +--
 net/netfilter/ipvs/ip_vs_conn.c       |   14 ++++-----
 net/netfilter/ipvs/ip_vs_core.c       |    7 +++--
 net/netfilter/ipvs/ip_vs_ctl.c        |   55 ++++++++++++++++++++-------------
 net/netfilter/ipvs/ip_vs_lblc.c       |    2 +-
 net/netfilter/ipvs/ip_vs_lblcr.c      |    2 +-
 net/netfilter/ipvs/ip_vs_pe_sip.c     |    3 +-
 net/netfilter/ipvs/ip_vs_proto_sctp.c |    2 +-
 net/netfilter/ipvs/ip_vs_sync.c       |   21 +++++--------
 net/netfilter/nf_nat_core.c           |    1 +
 11 files changed, 64 insertions(+), 55 deletions(-)
