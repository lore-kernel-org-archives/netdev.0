From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RESEND][NET-NEXT PATCH 06/29] ixgbe: fix bug with shared interrupts
Date: Thu, 11 Sep 2008 19:56:14 -0700
Message-ID: <20080912025601.6234.70683.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.170]:15725 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754776AbYILC4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 22:56:16 -0400
Received: by wf-out-1314.google.com with SMTP id 27so620997wfd.4
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 19:56:16 -0700 (PDT)
In-Reply-To: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

fix ixgbe bug reported with shared legacy interrupts

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 11bf86b..cfaa3ca 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1245,8 +1245,13 @@ static irqreturn_t ixgbe_intr(int irq, void *data)
 	/* for NAPI, using EIAM to auto-mask tx/rx interrupt bits on read
 	 * therefore no explict interrupt disable is necessary */
 	eicr = IXGBE_READ_REG(hw, IXGBE_EICR);
-	if (!eicr)
+	if (!eicr) {
+		/* shared interrupt alert!
+		 * make sure interrupts are enabled because the read will
+		 * have disabled interrupts due to EIAM */
+		ixgbe_irq_enable(adapter);
 		return IRQ_NONE;	/* Not our interrupt */
+	}
 
 	if (eicr & IXGBE_EICR_LSC)
 		ixgbe_check_lsc(adapter);

