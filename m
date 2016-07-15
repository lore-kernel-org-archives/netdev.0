From: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
Subject: [PATCH 2/4 v4] Marvell phy: add field to get errors from fiber link.
Date: Fri, 15 Jul 2016 12:12:06 +0200
Message-ID: <7caea37c-993c-f406-e95a-f37b8ffe8949@nexvision.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 17.mo3.mail-out.ovh.net ([87.98.178.58]:42594 "EHLO
	17.mo3.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932570AbcGOKMI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 06:12:08 -0400
Received: from player734.ha.ovh.net (b7.ovh.net [213.186.33.57])
	by mo3.mail-out.ovh.net (Postfix) with ESMTP id 55F031030683
	for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 12:12:06 +0200 (CEST)
Received: from [192.168.1.29] (LFbn-1-1866-70.w90-73.abo.wanadoo.fr [90.73.165.70])
	(Authenticated sender: charles-antoine.couret@nexvision.fr)
	by player734.ha.ovh.net (Postfix) with ESMTPSA id 46A7C280076
	for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 12:12:06 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 6244e234cced4b3e5ee1f0ab735c4bd52b7ed0a4 Mon Sep 17 00:00:00 2001
From: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
Date: Fri, 15 Jul 2016 11:56:12 +0200
Subject: [PATCH 2/4] Marvell phy: add field to get errors from fiber link.

Phy not concerned by fiber link don't display that.

Signed-off-by: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
---
 drivers/net/phy/marvell.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 97b9148..13a93d8 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -165,8 +165,9 @@ struct marvell_hw_stat {
 };
 
 static struct marvell_hw_stat marvell_hw_stats[] = {
-	{ "phy_receive_errors", 0, 21, 16},
+	{ "phy_receive_errors_copper", 0, 21, 16},
 	{ "phy_idle_errors", 0, 10, 8 },
+	{ "phy_receive_errors_fiber", 1, 21, 16},
 };
 
 struct marvell_priv {
@@ -1237,7 +1238,10 @@ static int m88e1318_set_wol(struct phy_device *phydev, struct ethtool_wolinfo *w
 
 static int marvell_get_sset_count(struct phy_device *phydev)
 {
-	return ARRAY_SIZE(marvell_hw_stats);
+	if (phydev->supported & SUPPORTED_FIBRE)
+		return ARRAY_SIZE(marvell_hw_stats);
+	else
+		return ARRAY_SIZE(marvell_hw_stats) - NB_FIBER_STATS;
 }
 
 static void marvell_get_strings(struct phy_device *phydev, u8 *data)
-- 
2.7.4
