From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH] forcedeth fix: take phy out of reset during power up
Date: Mon, 22 Sep 2008 09:55:35 -0400
Message-ID: <48D7A3D7.2010602@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040201010907040207010402"
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:16076 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751011AbYIVRLc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 13:11:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040201010907040207010402
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch will add the phy reset bit into the power up mask which is 
used during power up. Certain BIOSes will place the phy in reset and 
therefore the driver must take the phy out of reset when it loads.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------040201010907040207010402
Content-Type: text/plain;
 name="patch-forcedeth-phyreset-powerup"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-phyreset-powerup"

--- old/drivers/net/forcedeth.c	2008-09-22 09:46:17.000000000 -0400
+++ new/drivers/net/forcedeth.c	2008-09-22 09:46:20.000000000 -0400
@@ -337,7 +337,7 @@
 	NvRegMSIXIrqStatus = 0x3f0,
 
 	NvRegPowerState2 = 0x600,
-#define NVREG_POWERSTATE2_POWERUP_MASK		0x0F11
+#define NVREG_POWERSTATE2_POWERUP_MASK		0x0F15
 #define NVREG_POWERSTATE2_POWERUP_REV_A3	0x0001
 #define NVREG_POWERSTATE2_PHY_RESET		0x0004
 };

--------------040201010907040207010402--
