From: Pau Koning <paukoning@gmail.com>
Subject: [PATCH] batman-adv: Fix NULL pointer dereference in DAT hash collision avoidance
Date: Tue, 12 Feb 2013 11:18:45 +0100
Message-ID: <1360664325-7323-1-git-send-email-paukoning@gmail.com>
Cc: netdev@vger.kernel.org, Pau Koning <paukoning@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f175.google.com ([209.85.215.175]:48487 "EHLO
	mail-ea0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758144Ab3BLKS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 05:18:58 -0500
Received: by mail-ea0-f175.google.com with SMTP id d1so75837eab.34
        for <netdev@vger.kernel.org>; Tue, 12 Feb 2013 02:18:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An entry in DAT with the hashed position of 0 can cause a NULL pointer
dereference when the first entry is checked by batadv_choose_next_candidate.
This first candidate automatically has the max value of 0 and the max_orig_node
of NULL. Not checking max_orig_node for NULL in batadv_is_orig_node_eligible
will lead to a NULL pointer dereference when checking for the lowest address.

This problem was added in 785ea1144182c341b8b85b0f8180291839d176a8
("batman-adv: Distributed ARP Table - create DHT helper functions").

Signed-off-by: Pau Koning <paukoning@gmail.com>
---
 net/batman-adv/distributed-arp-table.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index 0e05ad4..d54188a 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -439,7 +439,7 @@ static bool batadv_is_orig_node_eligible(struct batadv_dat_candidate *res,
 	/* this is an hash collision with the temporary selected node. Choose
 	 * the one with the lowest address
 	 */
-	if ((tmp_max == max) &&
+	if ((tmp_max == max) && max_orig_node &&
 	    (batadv_compare_eth(candidate->orig, max_orig_node->orig) > 0))
 		goto out;
 
-- 
1.7.10.4
