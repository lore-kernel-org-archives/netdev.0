From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 5/8] bonding: Allow setting and querying xmit policy regardless of mode
Date: Thu,  6 Dec 2007 23:40:32 -0800
Message-ID: <11970132381345-git-send-email-fubar@us.ibm.com>
References: <11970132353950-git-send-email-fubar@us.ibm.com>
 <11970132363756-git-send-email-fubar@us.ibm.com>
 <11970132372293-git-send-email-fubar@us.ibm.com>
 <1197013237259-git-send-email-fubar@us.ibm.com>
 <11970132382296-git-send-email-fubar@us.ibm.com>
Cc: jgarzik@pobox.com, Wagner Ferenc <wferi@niif.hu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:50966 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751947AbXLGHkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 02:40:51 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lB77edeC009089
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2007 02:40:39 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lB77edsa124416
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2007 00:40:39 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lB77edhB018111
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2007 00:40:39 -0700
In-Reply-To: <11970132382296-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wagner Ferenc <wferi@niif.hu>

From: Wagner Ferenc <wferi@niif.hu>

For consistency with the behaviour of the arp_ip_target option,
let /sys/class/net/bond0/bonding/xmit_hash_policy accept and report
current policy even if the bonding mode in effect does not use it.

Signed-off-by: Ferenc Wagner <wferi@niif.hu>
Acked-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_sysfs.c |   21 +++------------------
 1 files changed, 3 insertions(+), 18 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 9de2c52..11b76b3 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -456,17 +456,11 @@ static ssize_t bonding_show_xmit_hash(struct device *d,
 				      struct device_attribute *attr,
 				      char *buf)
 {
-	int count = 0;
 	struct bonding *bond = to_bond(d);
 
-	if ((bond->params.mode == BOND_MODE_XOR) ||
-	    (bond->params.mode == BOND_MODE_8023AD)) {
-		count = sprintf(buf, "%s %d\n",
-			xmit_hashtype_tbl[bond->params.xmit_policy].modename,
-			bond->params.xmit_policy);
-	}
-
-	return count;
+	return sprintf(buf, "%s %d\n",
+		       xmit_hashtype_tbl[bond->params.xmit_policy].modename,
+		       bond->params.xmit_policy);
 }
 
 static ssize_t bonding_store_xmit_hash(struct device *d,
@@ -484,15 +478,6 @@ static ssize_t bonding_store_xmit_hash(struct device *d,
 		goto out;
 	}
 
-	if ((bond->params.mode != BOND_MODE_XOR) &&
-	    (bond->params.mode != BOND_MODE_8023AD)) {
-		printk(KERN_ERR DRV_NAME
-		       "%s: Transmit hash policy is irrelevant in this mode.\n",
-		       bond->dev->name);
-		ret = -EPERM;
-		goto out;
-	}
-
 	new_value = bond_parse_parm((char *)buf, xmit_hashtype_tbl);
 	if (new_value < 0)  {
 		printk(KERN_ERR DRV_NAME
-- 
1.5.3.4.206.g58ba4-dirty

