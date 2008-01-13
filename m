From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 5/5] forcedeth: multicast fix
Date: Sun, 13 Jan 2008 16:03:04 -0500
Message-ID: <478A7C88.6050908@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020509090300000602050908"
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate02.nvidia.com ([216.228.112.143]:9365 "EHLO
	HQEMGATE02.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753584AbYANWtD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 17:49:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020509090300000602050908
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch fixes the case where no multicast addresses are requested to 
be added to the multicast filter. The multicast mask must be set to all 
1's instead of all 0's.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------020509090300000602050908
Content-Type: text/plain;
 name="patch-forcedeth-multicast"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-multicast"

--- old/drivers/net/forcedeth.c	2008-01-13 15:15:22.000000000 -0500
+++ new/drivers/net/forcedeth.c	2008-01-13 15:24:22.000000000 -0500
@@ -277,7 +277,9 @@
 #define NVREG_MCASTADDRA_FORCE	0x01
 	NvRegMulticastAddrB = 0xB4,
 	NvRegMulticastMaskA = 0xB8,
+#define NVREG_MCASTMASKA_NONE		0xffffffff
 	NvRegMulticastMaskB = 0xBC,
+#define NVREG_MCASTMASKB_NONE		0xffff
 
 	NvRegPhyInterface = 0xC0,
 #define PHY_RGMII		0x10000000
@@ -2693,6 +2695,9 @@
 			addr[1] = alwaysOn[1];
 			mask[0] = alwaysOn[0] | alwaysOff[0];
 			mask[1] = alwaysOn[1] | alwaysOff[1];
+		} else {
+			mask[0] = NVREG_MCASTMASKA_NONE;
+			mask[1] = NVREG_MCASTMASKB_NONE;
 		}
 	}
 	addr[0] |= NVREG_MCASTADDRA_FORCE;
@@ -4803,8 +4808,8 @@
 		nv_mac_reset(dev);
 	writel(NVREG_MCASTADDRA_FORCE, base + NvRegMulticastAddrA);
 	writel(0, base + NvRegMulticastAddrB);
-	writel(0, base + NvRegMulticastMaskA);
-	writel(0, base + NvRegMulticastMaskB);
+	writel(NVREG_MCASTMASKA_NONE, base + NvRegMulticastMaskA);
+	writel(NVREG_MCASTMASKB_NONE, base + NvRegMulticastMaskB);
 	writel(0, base + NvRegPacketFilterFlags);
 
 	writel(0, base + NvRegTransmitterControl);
@@ -4898,8 +4903,8 @@
 	spin_lock_irq(&np->lock);
 	writel(NVREG_MCASTADDRA_FORCE, base + NvRegMulticastAddrA);
 	writel(0, base + NvRegMulticastAddrB);
-	writel(0, base + NvRegMulticastMaskA);
-	writel(0, base + NvRegMulticastMaskB);
+	writel(NVREG_MCASTMASKA_NONE, base + NvRegMulticastMaskA);
+	writel(NVREG_MCASTMASKB_NONE, base + NvRegMulticastMaskB);
 	writel(NVREG_PFF_ALWAYS|NVREG_PFF_MYADDR, base + NvRegPacketFilterFlags);
 	/* One manual link speed update: Interrupts are enabled, future link
 	 * speed changes cause interrupts and are handled by nv_link_irq().

--------------020509090300000602050908--
