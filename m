From: holger@eitzenberger.org
Subject: [patch 6/7] bonding: make tbl argument to bond_parse_parm() const
Date: Tue, 09 Dec 2008 21:07:56 +0100
Message-ID: <20081209201451.115627905@eitzenberger.org>
References: <20081209200750.490739902@eitzenberger.org>
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:61689 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754651AbYLIUT7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 15:19:59 -0500
Content-Disposition: inline; filename=bonding-make-arg-const.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bond_parse_parm() parses a parameter table for a particular value and
is therefore not modifying the table at all.  Therefore make the 2nd
argument const, thus allowing to make the tables const later.

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Index: bonding-2.6-out/drivers/net/bonding/bond_main.c
===================================================================
--- bonding-2.6-out.orig/drivers/net/bonding/bond_main.c	2008-12-08 22:52:57.000000000 +0100
+++ bonding-2.6-out/drivers/net/bonding/bond_main.c	2008-12-08 22:53:12.000000000 +0100
@@ -4723,7 +4723,7 @@
  * some mode names are substrings of other names, and calls from sysfs
  * may have whitespace in the name (trailing newlines, for example).
  */
-int bond_parse_parm(const char *buf, struct bond_parm_tbl *tbl)
+int bond_parse_parm(const char *buf, const struct bond_parm_tbl *tbl)
 {
 	int mode = -1, i, rv;
 	char *p, modestr[BOND_MAX_MODENAME_LEN + 1] = { 0, };
Index: bonding-2.6-out/drivers/net/bonding/bonding.h
===================================================================
--- bonding-2.6-out.orig/drivers/net/bonding/bonding.h	2008-12-08 22:52:57.000000000 +0100
+++ bonding-2.6-out/drivers/net/bonding/bonding.h	2008-12-08 22:53:12.000000000 +0100
@@ -337,7 +337,7 @@
 void bond_loadbalance_arp_mon(struct work_struct *);
 void bond_activebackup_arp_mon(struct work_struct *);
 void bond_set_mode_ops(struct bonding *bond, int mode);
-int bond_parse_parm(const char *mode_arg, struct bond_parm_tbl *tbl);
+int bond_parse_parm(const char *mode_arg, const struct bond_parm_tbl *tbl);
 void bond_select_active_slave(struct bonding *bond);
 void bond_change_active_slave(struct bonding *bond, struct slave *new_active);
 void bond_register_arp(struct bonding *);

-- 
