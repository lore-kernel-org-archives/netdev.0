From: Thomas Chou <thomas@wytron.com.tw>
Subject: [PATCH 2/2] ethoc: clear only pending irqs
Date: Thu,  8 Oct 2009 08:16:43 +0800
Message-ID: <1254961003-2453-2-git-send-email-thomas@wytron.com.tw>
References: <1254961003-2453-1-git-send-email-thomas@wytron.com.tw>
Cc: thierry.reding@avionic-design.de,
	Nios2 development list <nios2-dev@sopc.et.ntust.edu.tw>,
	linux-kernel@vger.kernel.org, Thomas Chou <thomas@wytron.com.tw>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from msr19.hinet.net ([168.95.4.119]:65156 "EHLO msr19.hinet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755271AbZJHAQY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2009 20:16:24 -0400
In-Reply-To: <1254961003-2453-1-git-send-email-thomas@wytron.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixed the problem of dropped packets due to lost of
interrupt requests. We should only clear what was pending at the
moment we read the irq source reg.

Signed-off-by: Thomas Chou <thomas@wytron.com.tw>
---
 drivers/net/ethoc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index 6b39723..ecc53d9 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -509,7 +509,7 @@ static irqreturn_t ethoc_interrupt(int irq, void *dev_id)
 		return IRQ_NONE;
 	}
 
-	ethoc_ack_irq(priv, INT_MASK_ALL);
+	ethoc_ack_irq(priv, pending);
 
 	if (pending & INT_MASK_BUSY) {
 		dev_err(&dev->dev, "packet dropped\n");
-- 
1.6.2.5

