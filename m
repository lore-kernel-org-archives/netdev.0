From: Simon Horman <horms@verge.net.au>
Subject: [rfc] IPVS: Remove conditionally include sysctl code
Date: Fri,  4 Feb 2011 18:46:08 +0900
Message-ID: <1296812782-14953-1-git-send-email-horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>,
	Hans Schillstrom <hans@schillstrom.com>
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, lvs-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:34736 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754139Ab1BDJqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Feb 2011 04:46:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the case where CONFIG_SYSCTL is undefined related
control code in IPVS is unnecessary. This patch series
attempts to make the inclusion of all such code
conditional on CONFIG_SYSCTL.

The changes are available in the git repository at:
git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-test-2.6.git config-sysctl

I consider these changes as an RFC at this stage and would
appreciate review or other feedback.

If this series is successful I will examine what if any similar
changes are appropriate for the case where CONFIG_PROC_FS is undefined.

Simon Horman (14):
      IPVS: Add ip_vs_route_me_harder()
      IPVS: Add sysctl_snat_reroute()
      IPVS: Add sysctl_nat_icmp_send()
      IPVS: Add {sysctl_sync_threshold,period}()
      IPVS: Add sysctl_sync_ver()
      IPVS: Add sysctl_expire_nodest_conn()
      IPVS: Add expire_quiescent_template()
      IPVS: Conditinally use sysctl_lblc{r}_expiration
      IPVS: ip_vs_todrop() becomes a noop when CONFIG_SYSCTL is undefined
      IPVS: Conditional ip_vs_conntrack_enabled()
      IPVS: Minimise ip_vs_leave when CONFIG_SYSCTL is undefined
      IPVS: Conditionally define and use ip_vs_lblc{r}_table
      IPVS: Add __ip_vs_control_{init,cleanup}_sysctl()
      IPVS: Conditionally include sysctl members of struct netns_ipvs

 include/net/ip_vs.h              |    8 +++
 include/net/netns/ip_vs.h        |   61 ++++++++++++++++++---
 net/netfilter/ipvs/ip_vs_conn.c  |   13 ++++-
 net/netfilter/ipvs/ip_vs_core.c  |   98 ++++++++++++++++++++------------
 net/netfilter/ipvs/ip_vs_ctl.c   |  114 +++++++++++++++++++++++--------------
 net/netfilter/ipvs/ip_vs_lblc.c  |   31 ++++++++---
 net/netfilter/ipvs/ip_vs_lblcr.c |   35 ++++++++---
 net/netfilter/ipvs/ip_vs_sync.c  |    8 +-
 8 files changed, 256 insertions(+), 112 deletions(-)

