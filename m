From: Tomas Winkler <tomas.winkler@intel.com>
Subject: [net-next-2.6] net/bridge: fix trivial sparse errors
Date: Mon,  3 Jan 2011 23:08:58 +0200
Message-ID: <1294088938-6219-1-git-send-email-tomas.winkler@intel.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Tomas Winkler <tomas.winkler@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:38096 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750927Ab1ACVJ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jan 2011 16:09:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/bridge//br_stp_if.c:148:66: warning: conversion of
net/bridge//br_stp_if.c:148:66:     int to
net/bridge//br_stp_if.c:148:66:     int enum umh_wait

net/bridge//netfilter/ebtables.c:1150:30: warning: Using plain integer as NULL pointer

Signed-off-by: Tomas Winkler <tomas.winkler@intel.com>
---
 net/bridge/br_stp_if.c          |    2 +-
 net/bridge/netfilter/ebtables.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
index 1d88269..79372d4 100644
--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -145,7 +145,7 @@ static void br_stp_stop(struct net_bridge *br)
 	char *envp[] = { NULL };
 
 	if (br->stp_enabled == BR_USER_STP) {
-		r = call_usermodehelper(BR_STP_PROG, argv, envp, 1);
+		r = call_usermodehelper(BR_STP_PROG, argv, envp, UMH_WAIT_PROC);
 		br_info(br, "userspace STP stopped, return code %d\n", r);
 
 		/* To start timers on any ports left in blocking */
diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index cbc9f39..16df053 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -1147,7 +1147,7 @@ ebt_register_table(struct net *net, const struct ebt_table *input_table)
 	void *p;
 
 	if (input_table == NULL || (repl = input_table->table) == NULL ||
-	    repl->entries == 0 || repl->entries_size == 0 ||
+	    repl->entries == NULL || repl->entries_size == 0 ||
 	    repl->counters != NULL || input_table->private != NULL) {
 		BUGPRINT("Bad table data for ebt_register_table!!!\n");
 		return ERR_PTR(-EINVAL);
-- 
1.7.3.4

---------------------------------------------------------------------
Intel Israel (74) Limited

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.

