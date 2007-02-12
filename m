From: "Leigh Brown" <leigh@solinno.co.uk>
Subject: [PATCH] sundance: add IFF_RUNNING support
Date: Mon, 12 Feb 2007 21:21:55 -0000 (GMT)
Message-ID: <52241.81.105.120.197.1171315315.squirrel@www.solinno.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mwuml021.modern-world.net ([193.110.88.84]:1970 "EHLO
	mwuml021.modern-world.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030189AbXBLVsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 16:48:03 -0500
References: 
In-Reply-To: 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patch to add IFF_RUNNING support for sundance.

I copied the basic code for this from the forcedeth driver, and I've
tested it using the ifplugstatus command from the ifplugd package.
This is very handy if you use Quagga or keepalived.

Signed-off-by: Leigh Brown <leigh@solinno.co.uk>

diff -urN a/drivers/net/sundance.c b/drivers/net/sundance.c
--- a/drivers/net/sundance.c	2007-02-11 11:29:19.000000000 +0000
+++ b/drivers/net/sundance.c	2007-02-12 19:48:36.000000000 +0000
@@ -23,8 +23,8 @@
 */

 #define DRV_NAME	"sundance"
-#define DRV_VERSION	"1.2"
-#define DRV_RELDATE	"11-Sep-2006"
+#define DRV_VERSION	"1.3"
+#define DRV_RELDATE	"12-Feb-2007"


 /* The user-configurable values.
@@ -831,6 +831,7 @@
 	/* Fix DFE-580TX packet drop issue */
 	if (np->pci_rev_id >= 0x14)
 		iowrite8(0x01, ioaddr + DebugCtrl1);
+	netif_carrier_off(dev);
 	netif_start_queue(dev);

 	spin_lock_irqsave(&np->lock, flags);
@@ -1429,6 +1430,13 @@
 			iowrite16(ioread16(ioaddr + MACCtrl0) | EnbFlowCtrl,
 				ioaddr + MACCtrl0);
 		}
+		if (mii_link_ok(&np->mii_if)) {
+			if (!netif_carrier_ok(dev))
+				netif_carrier_on(dev);
+		} else {
+			if (netif_carrier_ok(dev))
+				netif_carrier_off(dev);
+		}
 	}
 	if (intr_status & StatsMax) {
 		get_stats(dev);

