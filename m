From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/6] skge: default WOL should be magic only
Date: Tue, 15 May 2007 15:08:23 -0700
Message-ID: <20070515220903.522640228@linux-foundation.org>
References: <20070515220821.676720721@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:54941 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756626AbXEOWT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2007 18:19:29 -0400
Content-Disposition: inline; filename=skge-wol-magic
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

By default, the skge driver now enables wake on magic and wake on PHY.
This is a bad default (bug), wake on PHY means machine will never shutdown 
if connected to a switch.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>a

---
 drivers/net/skge.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

--- linux-2.6.21.y.orig/drivers/net/skge.c	2007-05-10 13:26:26.000000000 -0700
+++ linux-2.6.21.y/drivers/net/skge.c	2007-05-10 13:26:31.000000000 -0700
@@ -3586,7 +3586,9 @@ static struct net_device *skge_devinit(s
 	skge->duplex = -1;
 	skge->speed = -1;
 	skge->advertising = skge_supported_modes(hw);
-	skge->wol = pci_wake_enabled(hw->pdev) ? wol_supported(hw) : 0;
+
+	if (pci_wake_enabled(hw->pdev))
+		skge->wol = wol_supported(hw) & WAKE_MAGIC;
 
 	hw->dev[port] = dev;
 

--
Stephen Hemminger <shemminger@linux-foundation.org>

