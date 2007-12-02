From: Wagner Ferenc <wferi@niif.hu>
Subject: [PATCH 2/5] net/bonding: Return nothing for not applicable values
Date: Sun, 02 Dec 2007 14:09:19 +0100
Message-ID: <87ve7hz1j4.fsf_-_@szonett.ki.iif.hu>
References: <87wss3jin5.fsf@szonett.ki.iif.hu>
	<871wabkxcd.fsf@szonett.ki.iif.hu>
	<20071127194929.757e4ebe.randy.dunlap@oracle.com>
	<87bq9ekb8m.fsf@szonett.ki.iif.hu> <474D8B83.9050609@oracle.com>
	<87wss1c3d8.fsf_-_@szonett.ki.iif.hu> <26966.1196298795@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tac.ki.iif.hu ([193.6.222.43]:34890 "EHLO tac.ki.iif.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752264AbXLBNJe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Dec 2007 08:09:34 -0500
In-Reply-To: <26966.1196298795@death> (Jay Vosburgh's message of "Wed, 28 Nov
	2007 17:13:15 -0800, Wed, 28 Nov 2007 17:01:23 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The previous code returned '\n' (that is, a single empty line)
from most files, with one exception (xmit_hash_policy), where
it returned 'NA\n'.  This patch consolidates each file to return
nothing at all if not applicable, not even a '\n'.

I find this behaviour more usual, more useful, more efficient
and shorter to code from both sides.

Signed-off-by: Ferenc Wagner <wferi@niif.hu>
---
 drivers/net/bonding/bond_sysfs.c |   25 ++++---------------------
 1 files changed, 4 insertions(+), 21 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index a3f1b4a..6bb91e2 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -455,14 +455,11 @@ static ssize_t bonding_show_xmit_hash(struct device *d,
 				      struct device_attribute *attr,
 				      char *buf)
 {
-	int count;
+	int count = 0;
 	struct bonding *bond = to_bond(d);
 
-	if ((bond->params.mode != BOND_MODE_XOR) &&
-	    (bond->params.mode != BOND_MODE_8023AD)) {
-		// Not Applicable
-		count = sprintf(buf, "NA\n");
-	} else {
+	if ((bond->params.mode == BOND_MODE_XOR) ||
+	    (bond->params.mode == BOND_MODE_8023AD)) {
 		count = sprintf(buf, "%s %d\n",
 			xmit_hashtype_tbl[bond->params.xmit_policy].modename,
 			bond->params.xmit_policy);
@@ -1079,8 +1076,6 @@ static ssize_t bonding_show_primary(struct device *d,
 
 	if (bond->primary_slave)
 		count = sprintf(buf, "%s\n", bond->primary_slave->dev->name);
-	else
-		count = sprintf(buf, "\n");
 
 	return count;
 }
@@ -1186,7 +1181,7 @@ static ssize_t bonding_show_active_slave(struct device *d,
 {
 	struct slave *curr;
 	struct bonding *bond = to_bond(d);
-	int count;
+	int count = 0;
 
 	read_lock(&bond->curr_slave_lock);
 	curr = bond->curr_active_slave;
@@ -1194,8 +1189,6 @@ static ssize_t bonding_show_active_slave(struct device *d,
 
 	if (USES_PRIMARY(bond->params.mode) && curr)
 		count = sprintf(buf, "%s\n", curr->dev->name);
-	else
-		count = sprintf(buf, "\n");
 	return count;
 }
 
@@ -1309,8 +1302,6 @@ static ssize_t bonding_show_ad_aggregator(struct device *d,
 		struct ad_info ad_info;
 		count = sprintf(buf, "%d\n", (bond_3ad_get_active_agg_info(bond, &ad_info)) ?  0 : ad_info.aggregator_id);
 	}
-	else
-		count = sprintf(buf, "\n");
 
 	return count;
 }
@@ -1331,8 +1322,6 @@ static ssize_t bonding_show_ad_num_ports(struct device *d,
 		struct ad_info ad_info;
 		count = sprintf(buf, "%d\n", (bond_3ad_get_active_agg_info(bond, &ad_info)) ?  0: ad_info.ports);
 	}
-	else
-		count = sprintf(buf, "\n");
 
 	return count;
 }
@@ -1353,8 +1342,6 @@ static ssize_t bonding_show_ad_actor_key(struct device *d,
 		struct ad_info ad_info;
 		count = sprintf(buf, "%d\n", (bond_3ad_get_active_agg_info(bond, &ad_info)) ?  0 : ad_info.actor_key);
 	}
-	else
-		count = sprintf(buf, "\n");
 
 	return count;
 }
@@ -1375,8 +1362,6 @@ static ssize_t bonding_show_ad_partner_key(struct device *d,
 		struct ad_info ad_info;
 		count = sprintf(buf, "%d\n", (bond_3ad_get_active_agg_info(bond, &ad_info)) ?  0 : ad_info.partner_key);
 	}
-	else
-		count = sprintf(buf, "\n");
 
 	return count;
 }
@@ -1401,8 +1386,6 @@ static ssize_t bonding_show_ad_partner_mac(struct device *d,
 					print_mac(mac, ad_info.partner_system));
 		}
 	}
-	else
-		count = sprintf(buf, "\n");
 
 	return count;
 }
-- 
1.4.4.4

