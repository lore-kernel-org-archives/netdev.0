From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH] genetlink: export genl_unregister_mc_group()
Date: Thu, 17 Apr 2008 12:54:01 -0700
Message-ID: <200804171254.01950.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:21357 "EHLO
	azsmga101.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753905AbYDQT6G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2008 15:58:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add an EXPORT_SYMBOL() to genl_unregister_mc_group(), to allow
unregistering groups on the run. 

Cleanup is currently done when unregistering a family, but there is
no way to unregister a single multicast group due to that function not
being exported. Seems to be a mistake as it is documented as for
external consumption.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>

---
diff -r ec7efeb20531 net/netlink/genetlink.c
--- a/net/netlink/genetlink.c	Tue Feb 12 09:49:05 2008 -0800
+++ b/net/netlink/genetlink.c	Thu Apr 17 12:50:29 2008 -0700
@@ -225,6 +225,7 @@ void genl_unregister_mc_group(struct gen
 	__genl_unregister_mc_group(family, grp);
 	genl_unlock();
 }
+EXPORT_SYMBOL(genl_unregister_mc_group);
 
 static void genl_unregister_mc_groups(struct genl_family *family)
 {
