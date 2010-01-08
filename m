From: Samir Bellabes <sam@synack.fr>
Subject: [PATCH] genetlink: optimize ctrl_dumpfamily()
Date: Fri, 08 Jan 2010 09:10:56 +0100
Message-ID: <m2bph5kodr.fsf@ssh.synack.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>,
	Johannes Berg <johannes@sipsolutions.net>,
	jamal <hadi@cyberus.ca>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bob75-7-88-160-5-175.fbx.proxad.net ([88.160.5.175]:45716 "EHLO
	cerbere.dyndns.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753302Ab0AHIK5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 03:10:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit f3257ff67aac80d423227eae89281e506fed8cd6
Author: Samir Bellabes <sam@synack.fr>
Date:   Fri Jan 8 08:44:41 2010 +0100

    genetlink: optimize ctrl_dumpfamily()
    
    there is a unnecessary test which can be replaced by a good initialization in
    the 'for' statement
    
    Noticed by Serge E. Hallyn <serue@us.ibm.com>
    
    Signed-off-by: Samir Bellabes <sam@synack.fr>

diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index d07ecda..a4b6e14 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -681,9 +681,7 @@ static int ctrl_dumpfamily(struct sk_buff *skb, struct netlink_callback *cb)
 	int chains_to_skip = cb->args[0];
 	int fams_to_skip = cb->args[1];
 
-	for (i = 0; i < GENL_FAM_TAB_SIZE; i++) {
-		if (i < chains_to_skip)
-			continue;
+	for (i = chains_to_skip; i < GENL_FAM_TAB_SIZE; i++) {
 		n = 0;
 		list_for_each_entry(rt, genl_family_chain(i), family_list) {
 			if (!rt->netnsok && !net_eq(net, &init_net))
