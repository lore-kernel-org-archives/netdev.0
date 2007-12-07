From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 2/8] bonding: Return nothing for not applicable values
Date: Thu,  6 Dec 2007 23:40:29 -0800
Message-ID: <11970132372293-git-send-email-fubar@us.ibm.com>
References: <11970132353950-git-send-email-fubar@us.ibm.com>
 <11970132363756-git-send-email-fubar@us.ibm.com>
Cc: jgarzik@pobox.com, Wagner Ferenc <wferi@niif.hu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:43251 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751827AbXLGHkt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 02:40:49 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lB77ecTA000865
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2007 02:40:38 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lB77ecLu117288
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2007 00:40:38 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lB77ebmA018016
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2007 00:40:37 -0700
In-Reply-To: <11970132363756-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wagner Ferenc <wferi@niif.hu>

From: Wagner Ferenc <wferi@niif.hu>

The previous code returned '\n' (that is, a single empty line)
from most files, with one exception (xmit_hash_policy), where
it returned 'NA\n'.  This patch consolidates each file to return
nothing at all if not applicable, not even a '\n'.

I find this behaviour more usual, more useful, more efficient
and shorter to code from both sides.

Signed-off-by: Ferenc Wagner <wferi@niif.hu>
Acked-by: Jay Vosburgh <fubar@us.ibm.com>
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
1.5.3.4.206.g58ba4-dirty

