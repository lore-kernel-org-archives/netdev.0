From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v2 0/8] IPv6 MLD updates
Date: Wed,  4 Sep 2013 00:19:36 +0200
Message-ID: <1378246784-21067-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55565 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761056Ab3ICWTs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Sep 2013 18:19:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set contains the non-RFC version of the previous submission entitled
"[RFC PATCH net-next 0/7] IPv6 MLD updates". Most importantly it contains
a fix for MLDv1/v2 switchback timeout where hosts currently are switching
back from v1 compat mode to normal v2 too early (i.e. switchback time was
<= 30secs instead of >= 260secs on default), and the set also contains a
patch that allows for v2-only mode as per RFC recommendation. The rest is
related to cleanups that make the code more readable resp. maintainable.

Changes from RFC to non-RFC:

We ignore v2 messages now when in v1 compat mode, otherwise report timers
are reset and triggered, also stop current v2 report timer in case it is
currently running and we received a v1 query; use WARN_ON instead of BUG_ON
for RV of 0 (patch1).

Two more patches have been added that makes to code more readable, that is
"net: ipv6: mld: refactor query processing into v1/v2 functions" and
"net: ipv6: mld: introduce mld_{gq,ifc,dad}_stop_timer functions", the
sysctl patch "net: ipv6: mld: restrict min/max of sysctl force_mld_version"
has been dropped as extra1 and extra2 vars are overwritten with idev and net
anyway when addrconf sysctl is registered, hence dropped for now. The rest is
unchanged, only adapted to take changes into account.

Changes from v1 to v2:

Minor update in "net: ipv6: mld: implement RFC3810 MLDv2 mode only" in MLD
version selection. Rest stays the same, added Acked-bys from Hannes in
unchanged patches.

Thanks!

Daniel Borkmann (8):
  net: ipv6: mld: fix v1/v2 switchback timeout to rfc3810, 9.12.
  net: ipv6: mld: clean up MLD_V1_SEEN macro
  net: ipv6: mld: get rid of MLDV2_MRC and simplify calculation
  net: ipv6: mld: implement RFC3810 MLDv2 mode only
  net: ipv6: mld: similarly to MLDv2 have min max_delay of 1
  net: ipv6: mld: refactor query processing into v1/v2 functions
  net: ipv6: mld: introduce mld_{gq,ifc,dad}_stop_timer functions
  net: ipv6: mld: document force_mld_version in ip-sysctl.txt

 Documentation/networking/ip-sysctl.txt |   5 +
 include/net/if_inet6.h                 |   9 +-
 include/net/mld.h                      |  51 +++++--
 net/bridge/br_multicast.c              |   3 +-
 net/ipv6/mcast.c                       | 248 +++++++++++++++++++++++++++------
 5 files changed, 259 insertions(+), 57 deletions(-)

-- 
1.7.11.7
