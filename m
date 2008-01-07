From: Krzysztof Helt <krzysztof.h1@wp.pl>
Subject: 3c509: PnP resource management fix
Date: Mon, 7 Jan 2008 22:44:06 +0100
Message-ID: <20080107224406.b7e56ade.krzysztof.h1@wp.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.wp.pl ([212.77.101.5]:45551 "EHLO mx1.wp.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750871AbYAGVkr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jan 2008 16:40:47 -0500
Received: from host-87-99-61-239.lanet.net.pl (HELO krzysio.net) (krzysztof.h1@[87.99.61.239])
          (envelope-sender <krzysztof.h1@wp.pl>)
          by smtp.wp.pl (WP-SMTPD) with SMTP
          for <netdev@vger.kernel.org>; 7 Jan 2008 22:40:46 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krzysztof Helt <krzysztof.h1@wp.pl>

In order to release PnP resources a card type must be set to EL3_PNP.
Previously, it was never set hence the PnP resources were not
released and device was left in incorrect state.

Signed-off-by: Krzysztof Helt <krzysztof.h1@wp.pl>

---

The type value is set only if the card is enabled as PnP device.

--- linux-2.6.24/drivers/net/3c509.c	2007-12-25 23:20:20.000000000 +0100
+++ linux-new/drivers/net/3c509.c	2007-12-26 12:18:08.000000000 +0100
@@ -385,6 +385,7 @@ static int __init el3_probe(int card_idx
 #if defined(__ISAPNP__)
 	static int pnp_cards;
 	struct pnp_dev *idev = NULL;
+	int pnp_found = 0;
 
 	if (nopnp == 1)
 		goto no_pnp;
@@ -430,6 +431,7 @@ __again:
 			pnp_cards++;
 
 			netdev_boot_setup_check(dev);
+			pnp_found = 1;
 			goto found;
 		}
 	}
@@ -560,6 +562,8 @@ no_pnp:
 	lp = netdev_priv(dev);
 #if defined(__ISAPNP__)
 	lp->dev = &idev->dev;
+	if (pnp_found)
+		lp->type = EL3_PNP;
 #endif
 	err = el3_common_init(dev);
 
