From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/6] skge: FIFO Ram calculation error
Date: Mon, 26 Nov 2007 11:54:48 -0800
Message-ID: <20071126195557.525592634@linux-foundation.org>
References: <20071126195447.846382144@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:52192 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754544AbXKZT7J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 14:59:09 -0500
Content-Disposition: inline; filename=skge-ram-offset.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The calculation of usable FIFO RAM is wrong in the skge driver.
First, is doesn't take into account the reserved area on the original
SysKonnect Genesis boards. Second it has an off-by-one error because
hw->ports is either 1 or 2.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/skge.c	2007-11-21 09:50:08.000000000 -0800
+++ b/drivers/net/skge.c	2007-11-21 12:18:59.000000000 -0800
@@ -2619,8 +2619,8 @@ static int skge_up(struct net_device *de
 		yukon_mac_init(hw, port);
 	spin_unlock_bh(&hw->phy_lock);
 
-	/* Configure RAMbuffers */
-	chunk = hw->ram_size / ((hw->ports + 1)*2);
+	/* Configure RAMbuffers - equally between ports and tx/rx */
+	chunk = (hw->ram_size  - hw->ram_offset) / (hw->ports * 2);
 	ram_addr = hw->ram_offset + 2 * chunk * port;
 
 	skge_ramset(hw, rxqaddr[port], ram_addr, chunk);

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

