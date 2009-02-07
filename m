From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 18/26] igb: don't read eicr when responding to legacy
	interrupts
Date: Sat, 07 Feb 2009 01:20:49 -0800
Message-ID: <20090207092049.15697.69346.stgit@lost.foo-projects.org>
References: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.westchester.pa.mail.comcast.net ([76.96.62.17]:58684
	"EHLO QMTA10.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755681AbZBGJVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 04:21:10 -0500
In-Reply-To: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The interrupt handler was reading eicr and then doing nothing with the
result.  I have removed the variable and the register read since they
provide no value to the legacy interrupt handler.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index e3f521c..56c1455 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3519,7 +3519,7 @@ static irqreturn_t igb_intr_msi(int irq, void *data)
 }
 
 /**
- * igb_intr - Interrupt Handler
+ * igb_intr - Legacy Interrupt Handler
  * @irq: interrupt number
  * @data: pointer to a network interface device structure
  **/
@@ -3531,7 +3531,6 @@ static irqreturn_t igb_intr(int irq, void *data)
 	/* Interrupt Auto-Mask...upon reading ICR, interrupts are masked.  No
 	 * need for the IMC write */
 	u32 icr = rd32(E1000_ICR);
-	u32 eicr = 0;
 	if (!icr)
 		return IRQ_NONE;  /* Not our interrupt */
 
@@ -3547,8 +3546,6 @@ static irqreturn_t igb_intr(int irq, void *data)
 		adapter->stats.doosync++;
 	}
 
-	eicr = rd32(E1000_EICR);
-
 	if (icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC)) {
 		hw->mac.get_link_status = 1;
 		/* guard against interrupt when we're going down */

