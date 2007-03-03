From: Florian Fainelli <florian.fainelli@int-evry.fr>
Subject: [PATCH] Au1000 link beat detection
Date: Sat, 3 Mar 2007 16:53:11 +0100
Message-ID: <200703031653.11697.florian.fainelli@int-evry.fr>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_nnZ6FHRQrGggw8u"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-ext.int-evry.fr ([157.159.11.17]:46649 "EHLO
	smtp-ext.int-evry.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030666AbXCCP60 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Mar 2007 10:58:26 -0500
Received: from mini.int.alphacore.net (florian.maisel.int-evry.fr [157.159.41.36])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp-ext.int-evry.fr (Postfix) with ESMTP id C40288D1690
	for <netdev@vger.kernel.org>; Sat,  3 Mar 2007 16:58:07 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_nnZ6FHRQrGggw8u
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi all

This patch fixes the link beat detection when the cable is not plugged at 
startup with au1000_eth driver.

Signed-off-by: Florian Fainelli <florian.fainelli@int-evry.fr>
-- 

--Boundary-00=_nnZ6FHRQrGggw8u
Content-Type: text/plain;
  charset="utf-8";
  name="005-au1000_eth_link_beat.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="005-au1000_eth_link_beat.patch"

diff -urN linux-2.6.16.7/drivers/net/au1000_eth.c linux-2.6.16.7.new/drivers/net/au1000_eth.c
--- linux-2.6.16.7/drivers/net/au1000_eth.c	2006-04-17 23:53:25.000000000 +0200
+++ linux-2.6.16.7.new/drivers/net/au1000_eth.c	2006-04-23 01:42:48.000000000 +0200
@@ -12,6 +12,9 @@
  * Author: MontaVista Software, Inc.
  *         	ppopov@mvista.com or source@mvista.com
  *
+ *         Bjoern Riemer 2004
+ *           riemer@fokus.fraunhofer.de or riemer@riemer-nt.de
+ *             // fixed the link beat detection with ioctls (SIOCGMIIPHY)
  * ########################################################################
  *
  *  This program is free software; you can distribute it and/or modify it
@@ -1672,6 +1675,10 @@
 	aup->phy_ops->phy_status(dev, aup->phy_addr, &link, &speed);
 	control = MAC_DISABLE_RX_OWN | MAC_RX_ENABLE | MAC_TX_ENABLE;
 #ifndef CONFIG_CPU_LITTLE_ENDIAN
+	/*riemer: fix for startup without cable */
+	if (!link)
+		dev->flags &= ~IFF_RUNNING;
+
 	control |= MAC_BIG_ENDIAN;
 #endif
 	if (link && (dev->if_port == IF_PORT_100BASEFX)) {

--Boundary-00=_nnZ6FHRQrGggw8u--
