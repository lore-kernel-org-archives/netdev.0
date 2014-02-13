From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH iproute2 v2] iplink_bond: fix parameter value matching
Date: Thu, 13 Feb 2014 17:31:59 +0100 (CET)
Message-ID: <20140213163159.7F73CE668E@unicorn.suse.cz>
References: <52F448AF.3060604@huawei.com>
Cc: netdev@vger.kernel.org, Ding Tianhong <dingtianhong@huawei.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:40980 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751676AbaBMQcA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Feb 2014 11:32:00 -0500
In-Reply-To: <52F448AF.3060604@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lookup function get_index() compares argument with table entries
only up to the length of the table entry so that if an entry
with lower index is a substring of a later one, earlier entry is
used even if the argument is equal to the other. For example,

  ip link set bond0 type bond xmit_hash_policy layer2+3

sets xmit_hash_policy to 0 (layer2) as this is found before
"layer2+3" can be checked.

Use strcmp() to compare whole strings instead.

v2: look for an exact match only

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 ip/iplink_bond.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/iplink_bond.c b/ip/iplink_bond.c
index f22151e..7a950df 100644
--- a/ip/iplink_bond.c
+++ b/ip/iplink_bond.c
@@ -106,7 +106,7 @@ static int get_index(const char **tbl, char *name)
 				return i;
 
 	for (i = 0; tbl[i]; i++)
-		if (strncmp(tbl[i], name, strlen(tbl[i])) == 0)
+		if (strcmp(tbl[i], name) == 0)
 			return i;
 
 	return -1;
-- 
1.8.1.4
