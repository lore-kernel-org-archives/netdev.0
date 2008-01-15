From: Makito SHIOKAWA <mshiokawa@miraclelinux.com>
Subject: [PATCH 3/4] bonding: Fix work rearming
Date: Tue, 15 Jan 2008 15:36:07 +0900
Message-ID: <20080115063650.149555000@miraclelinux.com>
References: <20080115063604.577118000@miraclelinux.com>
Cc: Makito SHIOKAWA <mshiokawa@miraclelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.miraclelinux.com ([219.118.163.66]:9818 "EHLO
	dhcp-0021.miraclelinux.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751470AbYAOGeY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 01:34:24 -0500
Content-Disposition: inline; filename=bonding-fix-monitor-rearming.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change code not to rearm bond_mii_monitor() when value 0 is set for miimon.

Signed-off-by: Makito SHIOKAWA <mshiokawa@miraclelinux.com>
---
 drivers/net/bonding/bond_main.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2388,7 +2388,8 @@ void bond_mii_monitor(struct work_struct
 
 	delay = ((bond->params.miimon * HZ) / 1000) ? : 1;
 	read_unlock(&bond->lock);
-	queue_delayed_work(bond->wq, &bond->mii_work, delay);
+	if (bond->params.miimon)
+		queue_delayed_work(bond->wq, &bond->mii_work, delay);
 }
 
 static __be32 bond_glean_dev_ip(struct net_device *dev)

-- 
Makito SHIOKAWA
MIRACLE LINUX CORPORATION 
