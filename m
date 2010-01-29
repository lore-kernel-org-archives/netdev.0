From: Sathya Perla <sathyap@serverengines.com>
Subject: [PATCH] be2net: use eq-id to calculate cev-isr reg offset
Date: Fri, 29 Jan 2010 12:38:36 +0530
Message-ID: <20100129070836.GA21744@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:39452 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754381Ab0A2HIl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 02:08:41 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cev-isr reg offset for each function is better calculated using (any) eq-id
alloted to that function instead of using pci-func number(which
does not work in some configurations...)

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 90c5661..5ac053a 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1350,7 +1350,7 @@ static irqreturn_t be_intx(int irq, void *dev)
 	int isr;
 
 	isr = ioread32(adapter->csr + CEV_ISR0_OFFSET +
-			be_pci_func(adapter) * CEV_ISR_SIZE);
+		(adapter->tx_eq.q.id/ 8) * CEV_ISR_SIZE);
 	if (!isr)
 		return IRQ_NONE;
 
-- 
1.6.3.3

