From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: [PATCH] phy_device: Interrupt number 0 is valid
Date: Wed, 08 Oct 2008 15:16:32 +0300
Message-ID: <48ECA4A0.7080508@teltonika.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 81-7-68-229.static.zebra.lt ([81.7.68.229]:47072 "EHLO
	teltonika.lt" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752448AbYJHMQh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 08:16:37 -0400
Received: from 82-135-208-232.static.zebra.lt (HELO Programuotojas.82-135-208-232.ip.zebra.lt) (paulius.zaleckas@[82.135.208.232])
          (envelope-sender <paulius.zaleckas@teltonika.lt>)
          by teltonika.lt (qmail-ldap-1.03) with SMTP
          for <netdev@vger.kernel.org>; 8 Oct 2008 12:16:29 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If interrupt number 0(valid interrupt number) will be passed as
phy interrupt it should be used. In current situation even phy
polling will not work since PHY_POLL = -1

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>

Index: linux-2.6/drivers/net/phy/phy_device.c
===================================================================
--- linux-2.6.orig/drivers/net/phy/phy_device.c
+++ linux-2.6/drivers/net/phy/phy_device.c
@@ -285,7 +285,7 @@ struct phy_device * phy_connect(struct n
 
 	phy_start_machine(phydev, NULL);
 
-	if (phydev->irq > 0)
+	if (phydev->irq >= 0)
 		phy_start_interrupts(phydev);
 
 	return phydev;
@@ -298,7 +298,7 @@ EXPORT_SYMBOL(phy_connect);
  */
 void phy_disconnect(struct phy_device *phydev)
 {
-	if (phydev->irq > 0)
+	if (phydev->irq >= 0)
 		phy_stop_interrupts(phydev);
 
 	phy_stop_machine(phydev);

