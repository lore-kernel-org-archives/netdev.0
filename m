From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/3] net: phy: Add phy_ignore_ta_mask to account for broken turn-around
Date: Tue, 12 May 2015 10:33:24 -0700
Message-ID: <1431452006-3219-2-git-send-email-f.fainelli@gmail.com>
References: <1431442563-10218-1-git-send-email-bert@biot.com>
 <1431452006-3219-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, jogo@openwrt.org, bert@biot.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:32811 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933250AbbELRdu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 13:33:50 -0400
Received: by pacwv17 with SMTP id wv17so20331569pac.0
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 10:33:49 -0700 (PDT)
In-Reply-To: <1431452006-3219-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some PHY devices/switches will not release the turn-around line as they
should do at the end of a MDIO transaction. To help with such
situations, allow MDIO bus drivers to be made aware of such
restrictions.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/linux/phy.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/linux/phy.h b/include/linux/phy.h
index 685809835b5c..701c7a3946e0 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -181,6 +181,9 @@ struct mii_bus {
 	/* PHY addresses to be ignored when probing */
 	u32 phy_mask;
 
+	/* PHY addresses to ignore the TA/read failure */
+	u32 phy_ignore_ta_mask;
+
 	/*
 	 * Pointer to an array of interrupts, each PHY's
 	 * interrupt at the index matching its address
-- 
2.1.0
