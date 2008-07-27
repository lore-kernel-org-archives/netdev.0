From: Bryan Wu <cooloney@kernel.org>
Subject: [PATCH 3/3] Blackfin EMAC Driver: Functional power management support
Date: Sun, 27 Jul 2008 22:45:05 +0800
Message-ID: <1217169905-7055-4-git-send-email-cooloney@kernel.org>
References: <1217169905-7055-1-git-send-email-cooloney@kernel.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Michael Hennerich <michael.hennerich@analog.com>,
	Bryan Wu <cooloney@kernel.org>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from po-out-1718.google.com ([72.14.252.157]:28450 "EHLO
	po-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757611AbYG0Opc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jul 2008 10:45:32 -0400
Received: by po-out-1718.google.com with SMTP id c31so8301862poi.1
        for <netdev@vger.kernel.org>; Sun, 27 Jul 2008 07:45:32 -0700 (PDT)
In-Reply-To: <1217169905-7055-1-git-send-email-cooloney@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Hennerich <michael.hennerich@analog.com>

Reprogram MAC address after resume from Suspend Mem
(Blackfin Hibernate looses all CORE and SYSTEM register content)

Signed-off-by: Michael Hennerich <michael.hennerich@analog.com>
Signed-off-by: Bryan Wu <cooloney@kernel.org>
---
 drivers/net/bfin_mac.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 57ebe6d..69a6b9d 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -972,6 +972,7 @@ static int bfin_mac_open(struct net_device *dev)
 	phy_start(lp->phydev);
 	phy_write(lp->phydev, MII_BMCR, BMCR_RESET);
 	setup_system_regs(dev);
+	setup_mac_addr(dev->dev_addr);
 	bfin_mac_disable();
 	bfin_mac_enable();
 	pr_debug("hardware init finished\n");
-- 
1.5.6

