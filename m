From: holger@eitzenberger.org
Subject: [patch 2/7] bonding: use table for mode names
Date: Tue, 09 Dec 2008 21:07:52 +0100
Message-ID: <20081209201446.222212807@eitzenberger.org>
References: <20081209200750.490739902@eitzenberger.org>
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.188]:61039 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754154AbYLIUOu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 15:14:50 -0500
Content-Disposition: inline; filename=bonding-use-table-for-3ad-mode-names.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use a small array in bond_mode_name() for the names, thus saving some
space:

before

    text     data      bss      dec    hex filename
   57736     9372      344    67452  1077c drivers/net/bonding/bonding.ko

after
    text     data      bss      dec    hex filename
   57441     9372      344    67157  10655 drivers/net/bonding/bonding.ko

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Index: bonding-2.6/drivers/net/bonding/bond_main.c
===================================================================
--- bonding-2.6.orig/drivers/net/bonding/bond_main.c	2008-12-08 20:55:52.000000000 +0100
+++ bonding-2.6/drivers/net/bonding/bond_main.c	2008-12-08 22:16:02.000000000 +0100
@@ -219,24 +219,20 @@
 
 static const char *bond_mode_name(int mode)
 {
-	switch (mode) {
-	case BOND_MODE_ROUNDROBIN :
-		return "load balancing (round-robin)";
-	case BOND_MODE_ACTIVEBACKUP :
-		return "fault-tolerance (active-backup)";
-	case BOND_MODE_XOR :
-		return "load balancing (xor)";
-	case BOND_MODE_BROADCAST :
-		return "fault-tolerance (broadcast)";
-	case BOND_MODE_8023AD:
-		return "IEEE 802.3ad Dynamic link aggregation";
-	case BOND_MODE_TLB:
-		return "transmit load balancing";
-	case BOND_MODE_ALB:
-		return "adaptive load balancing";
-	default:
+	static const char *names[] = {
+		[BOND_MODE_ROUNDROBIN] = "load balancing (round-robin)",
+		[BOND_MODE_ACTIVEBACKUP] = "fault-tolerance (active-backup)",
+		[BOND_MODE_XOR] = "load balancing (xor)",
+		[BOND_MODE_BROADCAST] = "fault-tolerance (broadcast)",
+		[BOND_MODE_8023AD]= "IEEE 802.3ad Dynamic link aggregation",
+		[BOND_MODE_TLB] = "transmit load balancing",
+		[BOND_MODE_ALB] = "adaptive load balancing",
+	};
+
+	if (mode < 0 || mode > BOND_MODE_ALB)
 		return "unknown";
-	}
+
+	return names[mode];
 }
 
 /*---------------------------------- VLAN -----------------------------------*/

-- 
