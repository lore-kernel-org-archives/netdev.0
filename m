From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 05/23] e1000e: don't clean Rx ring while resetting
Date: Sat, 21 Nov 2009 01:23:16 -0800
Message-ID: <20091121092315.5715.32.stgit@localhost.localdomain>
References: <20091121092126.5715.41618.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.emeryville.ca.mail.comcast.net ([76.96.27.211]:55669
	"EHLO QMTA11.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752406AbZKUJX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2009 04:23:26 -0500
In-Reply-To: <20091121092126.5715.41618.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

When using legacy interrupts, do not clean the Rx ring while resetting
otherwise traffic will not pass.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 3845fb6..e819f19 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1176,7 +1176,7 @@ static irqreturn_t e1000_intr(int irq, void *data)
 	struct e1000_hw *hw = &adapter->hw;
 	u32 rctl, icr = er32(ICR);
 
-	if (!icr)
+	if (!icr || test_bit(__E1000_DOWN, &adapter->state))
 		return IRQ_NONE;  /* Not our interrupt */
 
 	/*

