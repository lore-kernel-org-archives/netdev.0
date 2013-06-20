From: nikolay@redhat.com
Subject: [PATCH] bonding: fix slave speed reporting in bond_miimon_commit
Date: Thu, 20 Jun 2013 14:34:13 +0200
Message-ID: <1371731653-13568-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, fubar@us.ibm.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42311 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752189Ab3FTMhF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jun 2013 08:37:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>

When we have BOND_LINK_UP the speed is reported unconditionally with %u
format although it can be SPEED_UNKNOWN (-1). After this patch it returns
0 in that case in an attempt to keep the existing scripts happy.
One line is intenionally left 81 chars because it gets ugly if broken.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
If the scripts are not a concern I can re-post with a string "unknown".

 drivers/net/bonding/bond_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 02d9ae7..f975696 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2413,7 +2413,8 @@ static void bond_miimon_commit(struct bonding *bond)
 
 			pr_info("%s: link status definitely up for interface %s, %u Mbps %s duplex.\n",
 				bond->dev->name, slave->dev->name,
-				slave->speed, slave->duplex ? "full" : "half");
+				slave->speed == SPEED_UNKNOWN ? 0 : slave->speed,
+				slave->duplex ? "full" : "half");
 
 			/* notify ad that the link status has changed */
 			if (bond->params.mode == BOND_MODE_8023AD)
-- 
1.8.1.4
