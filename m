From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: [PATCH] net: Do not wrap sysctl igmp_max_memberships in IP_MULTICAST
Date: Tue, 12 Apr 2011 11:49:34 +0200
Message-ID: <1302601774-24289-1-git-send-email-Joakim.Tjernlund@transmode.se>
Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:35316 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753523Ab1DLJth (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Apr 2011 05:49:37 -0400
Received: from sesr04.transmode.se (sesr04.transmode.se [192.168.201.15])
	by gw1.transmode.se (Postfix) with ESMTP id 3A757258003
	for <netdev@vger.kernel.org>; Tue, 12 Apr 2011 11:49:36 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

controlling igmp_max_membership is useful even when IP_MULTICAST
is off.
Quagga(an OSPF deamon) uses multicast addresses for all interfaces
using a single socket and hits igmp_max_membership limit when
there are 20 interfaces or more.
Always export sysctl igmp_max_memberships in proc, just like
igmp_max_msf

Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
---
 net/ipv4/sysctl_net_ipv4.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index d96c1da..9cc2824 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -306,7 +306,6 @@ static struct ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_do_large_bitmap,
 	},
-#ifdef CONFIG_IP_MULTICAST
 	{
 		.procname	= "igmp_max_memberships",
 		.data		= &sysctl_igmp_max_memberships,
@@ -314,8 +313,6 @@ static struct ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
-
-#endif
 	{
 		.procname	= "igmp_max_msf",
 		.data		= &sysctl_igmp_max_msf,
-- 
1.7.3.4

