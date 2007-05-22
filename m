From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 3/4] forcedeth: fix cpu irq mask
Date: Mon, 21 May 2007 20:23:11 -0400
Message-ID: <465237EF.60302@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070809050807060303050300"
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate02.nvidia.com ([216.228.112.143]:15839 "EHLO
	HQEMGATE02.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757019AbXEVDIc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2007 23:08:32 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070809050807060303050300
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch fixes the cpu irq mask define to include the timer irq. 
Another flag check was setting up the timer bit in all cases so we 
didn't notice the issue.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------070809050807060303050300
Content-Type: text/plain;
 name="patch-forcedeth-cpumask"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-cpumask"

--- old/drivers/net/forcedeth.c	2007-05-21 20:07:44.000000000 -0400
+++ new/drivers/net/forcedeth.c	2007-05-21 20:08:34.000000000 -0400
@@ -195,7 +195,7 @@
 #define NVREG_IRQ_TX_FORCED		0x0100
 #define NVREG_IRQ_RECOVER_ERROR		0x8000
 #define NVREG_IRQMASK_THROUGHPUT	0x00df
-#define NVREG_IRQMASK_CPU		0x0040
+#define NVREG_IRQMASK_CPU		0x0060
 #define NVREG_IRQ_TX_ALL		(NVREG_IRQ_TX_ERR|NVREG_IRQ_TX_OK|NVREG_IRQ_TX_FORCED)
 #define NVREG_IRQ_RX_ALL		(NVREG_IRQ_RX_ERROR|NVREG_IRQ_RX|NVREG_IRQ_RX_NOBUF|NVREG_IRQ_RX_FORCED)
 #define NVREG_IRQ_OTHER			(NVREG_IRQ_TIMER|NVREG_IRQ_LINK|NVREG_IRQ_RECOVER_ERROR)

--------------070809050807060303050300--
