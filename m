From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next v2] IPVS fixes for v3.10
Date: Tue, 23 Apr 2013 12:03:51 +0900
Message-ID: <1366686240-23493-1-git-send-email-horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Simon Horman <horms@verge.net.au>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:47326 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754128Ab3DWDEG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 23:04:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pablo,

this is a revision of a previous pull request.
The previous pull request contained one fix-all patch.
As per your request it has been split into a number of separate patches.
This request also includes several new patches that fix
yet more problems flagged by static analysis.

Separately, I have also posted the following SCTP patch
"[PATCH] sctp: Correct type and usage of sctp_end_cksum()"

With this series and the above patch applied I
believe that IPVS is now sparse-clean.

Much thanks to Julian Anastasov for his patience, and
Dan Carpenter and Hans Schillstrom for their help.

The following changes since commit 3e3251b3f289528732edab386ddf73ac428359b7:

  net: sctp: minor: remove dead code from sctp_packet (2013-04-22 16:25:21 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs3-for-v3.10

for you to fetch changes up to 38561437d056b11f679f9735d68ad597ba67dc84:

  ipvs: Use network byte order for sync message size (2013-04-23 11:43:06 +0900)

----------------------------------------------------------------
IPVS fixes for v3.10

This series fixes a number of problems which were flagged by
static analysis.

The first two patches in the series resolve problems that
have been introduced since v3.9.

* ipvs: fix sparse warnings for ip_vs_conn listing
* ipvs: properly dereference dest_dst in ip_vs_forget_dev

The remaining patches resolve problems that have been around for longer.

It is not obvious to me that any of the problems resolved by
these patches manifest as bugs.

----------------------------------------------------------------
Dan Carpenter (1):
      ipvs: off by one in set_sctp_state()

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

 include/net/ip_vs.h                   |  8 ++---
 include/uapi/linux/ip_vs.h            |  4 +--
 net/netfilter/ipvs/ip_vs_conn.c       | 14 ++++-----
 net/netfilter/ipvs/ip_vs_core.c       |  7 +++--
 net/netfilter/ipvs/ip_vs_ctl.c        | 55 ++++++++++++++++++++++-------------
 net/netfilter/ipvs/ip_vs_lblc.c       |  2 +-
 net/netfilter/ipvs/ip_vs_lblcr.c      |  2 +-
 net/netfilter/ipvs/ip_vs_pe_sip.c     |  3 +-
 net/netfilter/ipvs/ip_vs_proto_sctp.c |  2 +-
 net/netfilter/ipvs/ip_vs_sync.c       | 21 +++++--------
 10 files changed, 63 insertions(+), 55 deletions(-)
