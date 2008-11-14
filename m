From: Giulio Benetti <giulio.benetti@micronovasrl.com>
Subject: macb phy address bug?
Date: Fri, 14 Nov 2008 08:53:13 +0100
Message-ID: <200811140853.13729.giulio.benetti@micronovasrl.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_p5SHJOX6dmTexmV"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.etics.it ([212.103.198.88]:4371 "EHLO etics.it"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751009AbYKNH66 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Nov 2008 02:58:58 -0500
Received: from pc001.dominio.micronovasrl.com by etics.it (MDaemon PRO v10.0.1 trial)
	with ESMTP id md50000057661.msg
	for <netdev@vger.kernel.org>; Fri, 14 Nov 2008 08:53:13 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_p5SHJOX6dmTexmV
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

PHYID returns 0xffff and not 0xffffffff when not found and in some 
case(at91sam9263) 0x0. Maybe this patch could be useful.



Signed-off-by: Giulio Benetti <giulio.benetti@micronovasrl.com>

--Boundary-00=_p5SHJOX6dmTexmV
Content-Type: text/x-diff;
  charset="iso 8859-15";
  name="macb.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="macb.patch"

diff -urN -X exclude linux.orig/drivers/net/phy/phy_device.c linux/drivers/net/phy/phy_device.c
--- linux.orig/drivers/net/phy/phy_device.c	2008-11-11 17:52:13.000000000 +0100
+++ linux/drivers/net/phy/phy_device.c	2008-11-12 19:20:47.000000000 +0100
@@ -227,8 +227,8 @@
 	if (r)
 		return ERR_PTR(r);
 
-	/* If the phy_id is all Fs, there is no device there */
-	if (0xffffffff == phy_id)
+	/* If the phy_id is all Fs or all 0s, there is no device there */
+	if ((0xffff == phy_id) || (0x00 == phy_id))
 		return NULL;
 
 	dev = phy_device_create(bus, addr, phy_id);

--Boundary-00=_p5SHJOX6dmTexmV--

