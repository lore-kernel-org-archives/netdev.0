From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH] genetlink: Optimize genl_register_family()
Date: Thu, 15 Oct 2009 11:24:53 +0530
Message-ID: <20091015055453.30128.12160.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp09.au.ibm.com ([202.81.31.142]:42311 "EHLO
	e23smtp09.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753261AbZJOFzr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 01:55:47 -0400
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp09.au.ibm.com (8.14.3/8.13.1) with ESMTP id n9FGgiFD007117
	for <netdev@vger.kernel.org>; Fri, 16 Oct 2009 03:42:44 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9F5qOA81699946
	for <netdev@vger.kernel.org>; Thu, 15 Oct 2009 16:52:24 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n9F5svpi030673
	for <netdev@vger.kernel.org>; Thu, 15 Oct 2009 16:54:58 +1100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

genl_register_family() doesn't need to call genl_family_find_byid
when GENL_ID_GENERATE is passed during register.

Patch on net-next-2.6, compile and reboot testing only.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
diff -ruNp org/net/netlink/genetlink.c new/net/netlink/genetlink.c
--- org/net/netlink/genetlink.c	2009-10-06 08:34:10.000000000 +0530
+++ new/net/netlink/genetlink.c	2009-10-12 13:57:38.000000000 +0530
@@ -374,11 +374,6 @@ int genl_register_family(struct genl_fam
 		goto errout_locked;
 	}
 
-	if (genl_family_find_byid(family->id)) {
-		err = -EEXIST;
-		goto errout_locked;
-	}
-
 	if (family->id == GENL_ID_GENERATE) {
 		u16 newid = genl_generate_id();
 
@@ -388,6 +383,9 @@ int genl_register_family(struct genl_fam
 		}
 
 		family->id = newid;
+	} else if (genl_family_find_byid(family->id)) {
+		err = -EEXIST;
+		goto errout_locked;
 	}
 
 	if (family->maxattr) {
