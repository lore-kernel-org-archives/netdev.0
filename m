From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 17/26] atl1: update phy config function
Date: Mon, 31 Dec 2007 20:22:44 -0600
Message-ID: <1199154173-4058-18-git-send-email-jacliburn@bellsouth.net>
References: <1199154173-4058-1-git-send-email-jacliburn@bellsouth.net>
Cc: Jay Cliburn <jacliburn@bellsouth.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost02.isp.att.net ([204.127.217.102]:63805 "EHLO
	fmailhost02.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752181AbYAAC2N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 21:28:13 -0500
In-Reply-To: <1199154173-4058-1-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update atl1_phy_config() to conform with current vendor driver version
1.2.40.2.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/atlx/atl1.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index abed547..6432956 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -2344,11 +2344,11 @@ static void atl1_phy_config(unsigned long data)
 	unsigned long flags;
 
 	spin_lock_irqsave(&adapter->lock, flags);
-	adapter->phy_timer_pending = false;
 	atl1_write_phy_reg(hw, MII_ADVERTISE, hw->mii_autoneg_adv_reg);
 	atl1_write_phy_reg(hw, MII_ATLX_CR, hw->mii_1000t_ctrl_reg);
 	atl1_write_phy_reg(hw, MII_BMCR, MII_CR_RESET | MII_CR_AUTO_NEG_EN);
 	spin_unlock_irqrestore(&adapter->lock, flags);
+	clear_bit(0, &adapter->cfg_phy);
 }
 
 int atl1_reset(struct atl1_adapter *adapter)
-- 
1.5.3.3

