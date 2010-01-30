From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 3/5] Bluetooth: Redo checks in IRQ handler for shared IRQ support
Date: Sat, 30 Jan 2010 06:08:46 -0800
Message-ID: <7427847d2d044d85f478757ea03165ae3cfe87c4.1264859950.git.marcel@holtmann.org>
References: <cover.1264859950.git.marcel@holtmann.org>
 <fcafde2e6d81aa7901f9b10e6a097592f0637b79.1264859950.git.marcel@holtmann.org>
 <e420aba331f44de0eed6871441293a6124d566d1.1264859950.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:60249 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753280Ab0A3OJi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jan 2010 09:09:38 -0500
In-Reply-To: <e420aba331f44de0eed6871441293a6124d566d1.1264859950.git.marcel@holtmann.org>
In-Reply-To: <cover.1264859950.git.marcel@holtmann.org>
References: <cover.1264859950.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier@gentoo.org>

Commit ac019360fe3 changed the irq handler logic to BUG_ON rather than
returning IRQ_NONE when the incoming argument is invalid.  While this
works in most cases, it doesn't work when the IRQ is shared with other
devices (or when DEBUG_SHIRQ is enabled).

So revert the previous change and replace the warning message with a
comment explaining that we want this behavior.

Signed-off-by: Michael Hennerich <michael.hennerich@analog.com>
Signed-off-by: Mike Frysinger <vapier@gentoo.org>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 drivers/bluetooth/bluecard_cs.c |    4 +++-
 drivers/bluetooth/bt3c_cs.c     |    4 +++-
 drivers/bluetooth/btuart_cs.c   |    4 +++-
 drivers/bluetooth/dtl1_cs.c     |    4 +++-
 4 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/bluetooth/bluecard_cs.c b/drivers/bluetooth/bluecard_cs.c
index 2acdc60..c2cf811 100644
--- a/drivers/bluetooth/bluecard_cs.c
+++ b/drivers/bluetooth/bluecard_cs.c
@@ -503,7 +503,9 @@ static irqreturn_t bluecard_interrupt(int irq, void *dev_inst)
 	unsigned int iobase;
 	unsigned char reg;
 
-	BUG_ON(!info->hdev);
+	if (!info || !info->hdev)
+		/* our irq handler is shared */
+		return IRQ_NONE;
 
 	if (!test_bit(CARD_READY, &(info->hw_state)))
 		return IRQ_HANDLED;
diff --git a/drivers/bluetooth/bt3c_cs.c b/drivers/bluetooth/bt3c_cs.c
index d814a27..9f5926a 100644
--- a/drivers/bluetooth/bt3c_cs.c
+++ b/drivers/bluetooth/bt3c_cs.c
@@ -345,7 +345,9 @@ static irqreturn_t bt3c_interrupt(int irq, void *dev_inst)
 	int iir;
 	irqreturn_t r = IRQ_NONE;
 
-	BUG_ON(!info->hdev);
+	if (!info || !info->hdev)
+		/* our irq handler is shared */
+		return IRQ_NONE;
 
 	iobase = info->p_dev->io.BasePort1;
 
diff --git a/drivers/bluetooth/btuart_cs.c b/drivers/bluetooth/btuart_cs.c
index d339464..91c5230 100644
--- a/drivers/bluetooth/btuart_cs.c
+++ b/drivers/bluetooth/btuart_cs.c
@@ -295,7 +295,9 @@ static irqreturn_t btuart_interrupt(int irq, void *dev_inst)
 	int iir, lsr;
 	irqreturn_t r = IRQ_NONE;
 
-	BUG_ON(!info->hdev);
+	if (!info || !info->hdev)
+		/* our irq handler is shared */
+		return IRQ_NONE;
 
 	iobase = info->p_dev->io.BasePort1;
 
diff --git a/drivers/bluetooth/dtl1_cs.c b/drivers/bluetooth/dtl1_cs.c
index 4f02a6f..6975919 100644
--- a/drivers/bluetooth/dtl1_cs.c
+++ b/drivers/bluetooth/dtl1_cs.c
@@ -299,7 +299,9 @@ static irqreturn_t dtl1_interrupt(int irq, void *dev_inst)
 	int iir, lsr;
 	irqreturn_t r = IRQ_NONE;
 
-	BUG_ON(!info->hdev);
+	if (!info || !info->hdev)
+		/* our irq handler is shared */
+		return IRQ_NONE;
 
 	iobase = info->p_dev->io.BasePort1;
 
-- 
1.6.6

