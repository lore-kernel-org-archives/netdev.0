From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/2] skge: default WOL should be magic only (rev2)
Date: Tue, 8 May 2007 13:36:20 -0700
Message-ID: <20070508133620.0a7c6d12@localhost>
References: <20070507110036.050e7b5b@freekitty>
 <4640055A.5000502@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:38667 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966608AbXEHUhe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 16:37:34 -0400
In-Reply-To: <4640055A.5000502@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

By default, the skge driver now enables wake on magic and wake on PHY.
This is a bad default (bug), wake on PHY means machine will never shutdown 
if connected to a switch.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>a

---
 drivers/net/skge.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

--- sky2-2.6.21.orig/drivers/net/skge.c	2007-05-08 10:06:39.000000000 -0700
+++ sky2-2.6.21/drivers/net/skge.c	2007-05-08 10:21:51.000000000 -0700
@@ -3594,7 +3594,9 @@ static struct net_device *skge_devinit(s
 	skge->duplex = -1;
 	skge->speed = -1;
 	skge->advertising = skge_supported_modes(hw);
-	skge->wol = pci_wake_enabled(hw->pdev) ? wol_supported(hw) : 0;
+
+	if (pci_wake_enabled(hw->pdev))
+		skge->wol = wol_supported(hw) & WAKE_MAGIC;
 
 	hw->dev[port] = dev;
 
