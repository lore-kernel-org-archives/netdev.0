From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/2] skge: default WOL should be magic only
Date: Mon, 7 May 2007 11:00:36 -0700
Message-ID: <20070507110036.050e7b5b@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:51066 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754728AbXEGSB5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2007 14:01:57 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

By default, the skge driver now enables wake on magic and wake on PHY.
This is a bad default (bug), wake on PHY means machine will never shutdown 
if connected to a switch.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>a

---
 drivers/net/skge.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- sky2-2.6.21.orig/drivers/net/skge.c	2007-05-07 10:01:47.000000000 -0700
+++ sky2-2.6.21/drivers/net/skge.c	2007-05-07 10:03:29.000000000 -0700
@@ -3591,7 +3591,7 @@ static struct net_device *skge_devinit(s
 	skge->duplex = -1;
 	skge->speed = -1;
 	skge->advertising = skge_supported_modes(hw);
-	skge->wol = pci_wake_enabled(hw->pdev) ? wol_supported(hw) : 0;
+	skge->wol = pci_wake_enabled(hw->pdev) ? WAKE_MAGIC : 0;
 
 	hw->dev[port] = dev;
 
