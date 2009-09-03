From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] sky2: only enable Vaux if capable of wakeup
Date: Thu, 3 Sep 2009 09:16:25 -0700
Message-ID: <20090903091625.2e6aff91@nehalam>
References: <4A9928C9.7000907@ring3k.org>
	<200908311158.57972.rene.mayrhofer@gibraltar.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mike McCormack <mikem@ring3k.org>, netdev@vger.kernel.org,
	Richard Leitner <leitner@esys.at>
To: Rene Mayrhofer <rene.mayrhofer@gibraltar.at>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:34410 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755817AbZICQRE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 12:17:04 -0400
In-Reply-To: <200908311158.57972.rene.mayrhofer@gibraltar.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While perusing vendor driver, I saw that it did not enable the Vaux
power unless device was able to wake from lan for D3cold.
This might help for Rene's power issue.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sky2.c	2009-09-03 09:01:24.668473584 -0700
+++ b/drivers/net/sky2.c	2009-09-03 09:10:18.949088574 -0700
@@ -272,8 +272,9 @@ static void sky2_power_aux(struct sky2_h
 			    Y2_CLK_GAT_LNK1_DIS | Y2_PCI_CLK_LNK2_DIS |
 			    Y2_COR_CLK_LNK2_DIS | Y2_CLK_GAT_LNK2_DIS);
 
-	/* switch power to VAUX */
-	if (sky2_read32(hw, B0_CTST) & Y2_VAUX_AVAIL)
+	/* switch power to VAUX if supported and PME from D3cold */
+	if ( (sky2_read32(hw, B0_CTST) & Y2_VAUX_AVAIL) &&
+	     pci_pme_capable(hw->pdev, PCI_D3cold))
 		sky2_write8(hw, B0_POWER_CTRL,
 			    (PC_VAUX_ENA | PC_VCC_ENA |
 			     PC_VAUX_ON | PC_VCC_OFF));
