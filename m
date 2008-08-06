From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 4/4] forcedeth: add tx pause limit
Date: Wed, 06 Aug 2008 12:16:11 -0400
Message-ID: <4899CE4B.1000606@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040001050900060000050101"
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:12177 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757108AbYHFT1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 15:27:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040001050900060000050101
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch adds support for limiting the number of tx pause frames to a 
default of 8. Previously, hardware would send out continuous stream of 
pause frames.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------040001050900060000050101
Content-Type: text/plain;
 name="patch-forcedeth-txpauselimit"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-txpauselimit"

--- old/drivers/net/forcedeth.c	2008-08-06 12:03:13.000000000 -0400
+++ new/drivers/net/forcedeth.c	2008-08-06 12:05:05.000000000 -0400
@@ -249,6 +249,8 @@
 #define NVREG_TX_PAUSEFRAME_ENABLE_V1	0x01800010
 #define NVREG_TX_PAUSEFRAME_ENABLE_V2	0x056003f0
 #define NVREG_TX_PAUSEFRAME_ENABLE_V3	0x09f00880
+	NvRegTxPauseFrameLimit = 0x174,
+#define NVREG_TX_PAUSEFRAMELIMIT_ENABLE	0x00010000
 	NvRegMIIStatus = 0x180,
 #define NVREG_MIISTAT_ERROR		0x0001
 #define NVREG_MIISTAT_LINKCHANGE	0x0008
@@ -3076,8 +3078,11 @@
 			u32 pause_enable = NVREG_TX_PAUSEFRAME_ENABLE_V1;
 			if (np->driver_data & DEV_HAS_PAUSEFRAME_TX_V2)
 				pause_enable = NVREG_TX_PAUSEFRAME_ENABLE_V2;
-			if (np->driver_data & DEV_HAS_PAUSEFRAME_TX_V3)
+			if (np->driver_data & DEV_HAS_PAUSEFRAME_TX_V3) {
 				pause_enable = NVREG_TX_PAUSEFRAME_ENABLE_V3;
+				/* limit the number of tx pause frames to a default of 8 */
+				writel(readl(base + NvRegTxPauseFrameLimit)|NVREG_TX_PAUSEFRAMELIMIT_ENABLE, base + NvRegTxPauseFrameLimit);
+			}
 			writel(pause_enable,  base + NvRegTxPauseFrame);
 			writel(regmisc|NVREG_MISC1_PAUSE_TX, base + NvRegMisc1);
 			np->pause_flags |= NV_PAUSEFRAME_TX_ENABLE;

--------------040001050900060000050101--
