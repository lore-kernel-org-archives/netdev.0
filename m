From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 1/2] bonding: remove dead code
Date: Tue, 4 Mar 2014 16:34:25 -0800
Message-ID: <20140304163425.44995c59@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:51231 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932108AbaCEAgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 19:36:53 -0500
Received: by mail-pd0-f175.google.com with SMTP id x10so282137pdj.34
        for <netdev@vger.kernel.org>; Tue, 04 Mar 2014 16:36:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These functions are defined but no longer used.
Compile tested only.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/drivers/net/bonding/bond_main.c	2014-03-03 10:37:53.188148575 -0800
+++ b/drivers/net/bonding/bond_main.c	2014-03-04 16:01:15.715286487 -0800
@@ -3931,52 +3931,6 @@ static void bond_uninit(struct net_devic
 
 /*------------------------- Module initialization ---------------------------*/
 
-int bond_parm_tbl_lookup(int mode, const struct bond_parm_tbl *tbl)
-{
-	int i;
-
-	for (i = 0; tbl[i].modename; i++)
-		if (mode == tbl[i].mode)
-			return tbl[i].mode;
-
-	return -1;
-}
-
-static int bond_parm_tbl_lookup_name(const char *modename,
-				     const struct bond_parm_tbl *tbl)
-{
-	int i;
-
-	for (i = 0; tbl[i].modename; i++)
-		if (strcmp(modename, tbl[i].modename) == 0)
-			return tbl[i].mode;
-
-	return -1;
-}
-
-/*
- * Convert string input module parms.  Accept either the
- * number of the mode or its string name.  A bit complicated because
- * some mode names are substrings of other names, and calls from sysfs
- * may have whitespace in the name (trailing newlines, for example).
- */
-int bond_parse_parm(const char *buf, const struct bond_parm_tbl *tbl)
-{
-	int modeint;
-	char *p, modestr[BOND_MAX_MODENAME_LEN + 1];
-
-	for (p = (char *)buf; *p; p++)
-		if (!(isdigit(*p) || isspace(*p)))
-			break;
-
-	if (*p && sscanf(buf, "%20s", modestr) != 0)
-		return bond_parm_tbl_lookup_name(modestr, tbl);
-	else if (sscanf(buf, "%d", &modeint) != 0)
-		return bond_parm_tbl_lookup(modeint, tbl);
-
-	return -1;
-}
-
 static int bond_check_params(struct bond_params *params)
 {
 	int arp_validate_value, fail_over_mac_value, primary_reselect_value, i;
--- a/drivers/net/bonding/bonding.h	2014-03-03 10:37:53.188148575 -0800
+++ b/drivers/net/bonding/bonding.h	2014-03-04 16:01:09.003415653 -0800
@@ -458,8 +458,6 @@ void bond_sysfs_slave_del(struct slave *
 int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev);
 int bond_release(struct net_device *bond_dev, struct net_device *slave_dev);
 int bond_xmit_hash(struct bonding *bond, struct sk_buff *skb, int count);
-int bond_parse_parm(const char *mode_arg, const struct bond_parm_tbl *tbl);
-int bond_parm_tbl_lookup(int mode, const struct bond_parm_tbl *tbl);
 void bond_select_active_slave(struct bonding *bond);
 void bond_change_active_slave(struct bonding *bond, struct slave *new_active);
 void bond_create_debugfs(void);
