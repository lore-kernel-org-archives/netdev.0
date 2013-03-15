From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH] bridge: Add support for setting BR_ROOT_BLOCK flag.
Date: Fri, 15 Mar 2013 12:39:12 -0400
Message-ID: <1363365552-27451-1-git-send-email-vyasevic@redhat.com>
Cc: shemminger@vyatta.com, Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17977 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752232Ab3COQjQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Mar 2013 12:39:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Most of the support was already there.  The only thing that was missing
was the call to set the flag.  Add this call.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_netlink.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 1382842..84c3b7d 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -327,6 +327,7 @@ static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
 	br_set_port_flag(p, tb, IFLA_BRPORT_MODE, BR_HAIRPIN_MODE);
 	br_set_port_flag(p, tb, IFLA_BRPORT_GUARD, BR_BPDU_GUARD);
 	br_set_port_flag(p, tb, IFLA_BRPORT_FAST_LEAVE, BR_MULTICAST_FAST_LEAVE);
+	br_set_port_flag(p, tb, IFLA_BRPORT_PROTECT, BR_ROOT_BLOCK);
 
 	if (tb[IFLA_BRPORT_COST]) {
 		err = br_stp_set_path_cost(p, nla_get_u32(tb[IFLA_BRPORT_COST]));
-- 
1.7.7.6
