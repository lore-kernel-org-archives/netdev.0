From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] sky2: don't clear phy power bits
Date: Tue, 21 Aug 2007 11:11:56 -0700
Message-ID: <20070821111156.590afb5d@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:47211 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755651AbXHUSNG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2007 14:13:06 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are special PHY settings available on Yukon EC-U chip that
should not get cleared. The reset bits are in the least significant
bits, so that is all that needs to be set.

This should solve mysterious errors on some motherboards (like Gigabyte DS-3).

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/drivers/net/sky2.c	2007-08-21 10:17:54.000000000 -0700
+++ b/drivers/net/sky2.c	2007-08-21 10:17:59.000000000 -0700
@@ -696,8 +696,8 @@ static void sky2_mac_init(struct sky2_hw
 	int i;
 	const u8 *addr = hw->dev[port]->dev_addr;
 
-	sky2_write32(hw, SK_REG(port, GPHY_CTRL), GPC_RST_SET);
-	sky2_write32(hw, SK_REG(port, GPHY_CTRL), GPC_RST_CLR);
+	sky2_write8(hw, SK_REG(port, GPHY_CTRL), GPC_RST_SET);
+	sky2_write8(hw, SK_REG(port, GPHY_CTRL), GPC_RST_CLR);
 
 	sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_RST_CLR);
 
