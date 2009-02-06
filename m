From: Yinghai Lu <yinghai@kernel.org>
Subject: [PATCH] forcedeth: disable irq at first before schedule rx
Date: Thu, 05 Feb 2009 21:01:06 -0800
Message-ID: <498BC412.3090900@kernel.org>
References: <498BC3A8.9040203@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>, Ingo Molnar <mingo@elte.hu>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:32780 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756137AbZBFFCS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Feb 2009 00:02:18 -0500
In-Reply-To: <498BC3A8.9040203@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Impact: clean up

schedule it later after disable it.

Signed-off-by: Yinghai Lu <yinghai@kernel.org>

---
 drivers/net/forcedeth.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6/drivers/net/forcedeth.c
===================================================================
--- linux-2.6.orig/drivers/net/forcedeth.c
+++ linux-2.6/drivers/net/forcedeth.c
@@ -3708,13 +3708,13 @@ static irqreturn_t nv_nic_irq_rx(int foo
 	u32 events;
 
 	events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQ_RX_ALL;
-	writel(NVREG_IRQ_RX_ALL, base + NvRegMSIXIrqStatus);
 
 	if (events) {
-		netif_rx_schedule(&np->napi);
 		/* disable receive interrupts on the nic */
 		writel(NVREG_IRQ_RX_ALL, base + NvRegIrqMask);
 		pci_push(base);
+		writel(NVREG_IRQ_RX_ALL, base + NvRegMSIXIrqStatus);
+		netif_rx_schedule(&np->napi);
 	}
 	return IRQ_HANDLED;
 }
