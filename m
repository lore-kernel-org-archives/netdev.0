From: Tony Zelenoff <antonz@parallels.com>
Subject: [PATCH 5/9] atl1: make function to set imr of card
Date: Fri, 13 Apr 2012 20:09:50 +0400
Message-ID: <1334333394-38404-6-git-send-email-antonz@parallels.com>
References: <1334333394-38404-1-git-send-email-antonz@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <antonz@parallels.com>, <netdev@vger.kernel.org>,
	<jcliburn@gmail.com>, <csnook@redhat.com>, <khorenko@parallels.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:54716 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754733Ab2DMQJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 12:09:59 -0400
In-Reply-To: <1334333394-38404-1-git-send-email-antonz@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function should be used later to set/remove proper
bits in imr to disable only rx ints.

Signed-off-by: Tony Zelenoff <antonz@parallels.com>
---
 drivers/net/ethernet/atheros/atlx/atlx.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atlx/atlx.c b/drivers/net/ethernet/atheros/atlx/atlx.c
index c9e9dc5..6c4a706 100644
--- a/drivers/net/ethernet/atheros/atlx/atlx.c
+++ b/drivers/net/ethernet/atheros/atlx/atlx.c
@@ -155,14 +155,20 @@ static void atlx_set_multi(struct net_device *netdev)
 	}
 }
 
+static inline void atlx_imr_set(struct atlx_adapter *adapter,
+				unsigned int imr)
+{
+	iowrite32(imr, adapter->hw.hw_addr + REG_IMR);
+	ioread32(adapter->hw.hw_addr + REG_IMR);
+}
+
 /*
  * atlx_irq_enable - Enable default interrupt generation settings
  * @adapter: board private structure
  */
 static void atlx_irq_enable(struct atlx_adapter *adapter)
 {
-	iowrite32(IMR_NORMAL_MASK, adapter->hw.hw_addr + REG_IMR);
-	ioread32(adapter->hw.hw_addr + REG_IMR);
+	atlx_imr_set(adapter, IMR_NORMAL_MASK);
 }
 
 /*
@@ -171,8 +177,7 @@ static void atlx_irq_enable(struct atlx_adapter *adapter)
  */
 static void atlx_irq_disable(struct atlx_adapter *adapter)
 {
-	iowrite32(0, adapter->hw.hw_addr + REG_IMR);
-	ioread32(adapter->hw.hw_addr + REG_IMR);
+	atlx_imr_set(adapter, 0);
 	synchronize_irq(adapter->pdev->irq);
 }
 
-- 
1.7.1
