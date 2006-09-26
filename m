From: James Morris <jmorris@namei.org>
Subject: [Patch] Possible dereference in net/core/rtnetlink.c (fwd)
Date: Tue, 26 Sep 2006 15:34:07 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0609261534030.3929@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.sea5.speakeasy.net ([69.17.117.6]:468 "EHLO
	mail4.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932488AbWIZTeL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Sep 2006 15:34:11 -0400
Received: from megaweapon.nightmoose.net (HELO d.namei) ([66.92.66.197])
          (envelope-sender <jmorris@namei.org>)
          by mail4.sea5.speakeasy.net (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <netdev@vger.kernel.org>; 26 Sep 2006 19:34:10 -0000
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

---------- Forwarded message ----------
Date: Tue, 26 Sep 2006 12:50:51 +0200
From: Eric Sesterhenn <snakebyte@gmx.de>
To: linux-kernel@vger.kernel.org
Cc: kuznet@ms2.inr.ac.ru
Subject: [Patch] Possible dereference in net/core/rtnetlink.c

hi,

another possible dereference spotted by coverity (#cid 1390).
if the nlmsg_parse() call fails, we goto errout, where we call
dev_put(), with dev still initialized to NULL.

Signed-off-by: Eric Sesterhenn <snakebyte@gmx.de>

--- linux-2.6.18-git5/net/core/rtnetlink.c.orig	2006-09-26 12:48:03.000000000 +0200
+++ linux-2.6.18-git5/net/core/rtnetlink.c	2006-09-26 12:48:28.000000000 +0200
@@ -562,7 +562,7 @@ static int rtnl_getlink(struct sk_buff *
 
 	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy);
 	if (err < 0)
-		goto errout;
+		return err;
 
 	ifm = nlmsg_data(nlh);
 	if (ifm->ifi_index >= 0) {


-
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/
