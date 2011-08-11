From: Julia Lawall <julia@diku.dk>
Subject: [PATCH] net/bridge/netfilter/ebtables.c: use available error handling code
Date: Thu, 11 Aug 2011 13:59:38 +0200
Message-ID: <1313063978-29400-1-git-send-email-julia@diku.dk>
Cc: kernel-janitors@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	davem@davemloft.net, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, coreteam@netfilter.org,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Bart De Schuymer <bart.de.schuymer@pandora.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:40090 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751864Ab1HKL7p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Aug 2011 07:59:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

Free the locally allocated table and newinfo as done in adjacent error
handling code.

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 net/bridge/netfilter/ebtables.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 2b5ca1a..5864cc4 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -1198,7 +1198,8 @@ ebt_register_table(struct net *net, const struct ebt_table *input_table)
 
 	if (table->check && table->check(newinfo, table->valid_hooks)) {
 		BUGPRINT("The table doesn't like its own initial data, lol\n");
-		return ERR_PTR(-EINVAL);
+		ret = -EINVAL;
+		goto free_chainstack;
 	}
 
 	table->private = newinfo;

