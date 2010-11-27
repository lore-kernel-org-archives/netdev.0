From: Szymon Janc <szymon@janc.net.pl>
Subject: [PATCH 6/6] forcedeth: use usleep_range not msleep for small sleeps
Date: Sat, 27 Nov 2010 19:39:48 +0100
Message-ID: <1290883188-2078-7-git-send-email-szymon@janc.net.pl>
References: <1290883188-2078-1-git-send-email-szymon@janc.net.pl>
Cc: Szymon Janc <szymon@janc.net.pl>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cox.rootnode.net ([89.248.165.14]:56870 "EHLO cox.rootnode.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753330Ab0K0SvD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Nov 2010 13:51:03 -0500
Received: from DSPAM-Daemon (localhost [127.0.0.1])
	by cox.rootnode.net (Postfix) with SMTP id AFF988041CA0
	for <netdev@vger.kernel.org>; Sat, 27 Nov 2010 19:41:52 +0100 (CET)
In-Reply-To: <1290883188-2078-1-git-send-email-szymon@janc.net.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Szymon Janc <szymon@janc.net.pl>
---
 drivers/net/forcedeth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index a2b6681..538bd9b 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -1178,7 +1178,7 @@ static int phy_reset(struct net_device *dev, u32 bmcr_setup)
 
 	/* must wait till reset is deasserted */
 	while (miicontrol & BMCR_RESET) {
-		msleep(10);
+		usleep_range(10000, 20000);
 		miicontrol = mii_rw(dev, np->phyaddr, MII_BMCR, MII_READ);
 		/* FIXME: 100 tries seem excessive */
 		if (tries++ > 100)
-- 
1.7.2.3


