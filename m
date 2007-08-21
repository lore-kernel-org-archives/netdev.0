From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFT] sky2: yukon-ec-u phy power problems
Date: Tue, 21 Aug 2007 10:07:13 -0700
Message-ID: <20070821100713.2867dce3@freepuppy.rosehill.hemminger.net>
References: <20070819093221.4d3291e9@freepuppy.rosehill.hemminger.net>
	<623107.14278.qm@web38905.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <w@1wt.eu>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Kevin E <kevin360@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:35484 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757666AbXHURHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2007 13:07:23 -0400
In-Reply-To: <623107.14278.qm@web38905.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The sky2 driver clears some bits in the PHY control register, that cause
the PHY interface to get changed.  Some of these deal with voltage and power
savings as well. This may explain some of the failures on Gigabyte DS-3 motherboard.

The clue to possible problem was looking at why loading/unloading sky2 would
break vendor sk98lin driver (ie what registers changed).


--- a/drivers/net/sky2.c	2007-08-21 09:53:41.000000000 -0700
+++ b/drivers/net/sky2.c	2007-08-21 09:53:43.000000000 -0700
@@ -696,8 +696,8 @@ static void sky2_mac_init(struct sky2_hw
 	int i;
 	const u8 *addr = hw->dev[port]->dev_addr;
 
-	sky2_write32(hw, SK_REG(port, GPHY_CTRL), GPC_RST_SET);
-	sky2_write32(hw, SK_REG(port, GPHY_CTRL), GPC_RST_CLR);
+	sky2_write8(hw, SK_REG(port, GPHY_CTRL), GPC_RST_SET);
+	sky2_write8(hw, SK_REG(port, GPHY_CTRL), GPC_RST_CLR);
 
 	sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_RST_CLR);
 
