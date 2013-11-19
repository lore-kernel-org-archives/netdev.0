From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 4/9] hsr: don't call genl_unregister_mc_group()
Date: Tue, 19 Nov 2013 15:19:34 +0100
Message-ID: <1384870779-17571-5-git-send-email-johannes@sipsolutions.net>
References: <1384870779-17571-1-git-send-email-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:41405 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752987Ab3KSOTt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Nov 2013 09:19:49 -0500
In-Reply-To: <1384870779-17571-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

There's no need to unregister the multicast group if the
generic netlink family is registered immediately after.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 net/hsr/hsr_netlink.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/hsr/hsr_netlink.c b/net/hsr/hsr_netlink.c
index f182260..908e335 100644
--- a/net/hsr/hsr_netlink.c
+++ b/net/hsr/hsr_netlink.c
@@ -435,9 +435,7 @@ fail_rtnl_link_register:
 
 void __exit hsr_netlink_exit(void)
 {
-	genl_unregister_mc_group(&hsr_genl_family, &hsr_network_genl_mcgrp);
 	genl_unregister_family(&hsr_genl_family);
-
 	rtnl_link_unregister(&hsr_link_ops);
 }
 
-- 
1.8.4.rc3
