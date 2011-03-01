From: huzaifas@redhat.com
Subject: [PATCH] Fix possible null pointer dereference in ariadne.c
Date: Tue,  1 Mar 2011 17:03:27 +0530
Message-ID: <1298979207-11237-1-git-send-email-huzaifas@redhat.com>
Cc: geert@linux-m68k.org, tj@kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, Huzaifa Sidhpurwala <huzaifas@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29624 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755822Ab1CALeA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2011 06:34:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huzaifa Sidhpurwala <huzaifas@redhat.com>

Make sure dev exists before referencing it

Signed-off-by: Huzaifa Sidhpurwala <huzaifas@redhat.com>
---
 drivers/net/ariadne.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ariadne.c b/drivers/net/ariadne.c
index 39214e5..fc3c762 100644
--- a/drivers/net/ariadne.c
+++ b/drivers/net/ariadne.c
@@ -420,7 +420,7 @@ static inline void ariadne_reset(struct net_device *dev)
 static irqreturn_t ariadne_interrupt(int irq, void *data)
 {
     struct net_device *dev = (struct net_device *)data;
-    volatile struct Am79C960 *lance = (struct Am79C960*)dev->base_addr;
+    volatile struct Am79C960 *lance;
     struct ariadne_private *priv;
     int csr0, boguscnt;
     int handled = 0;
@@ -430,6 +430,7 @@ static irqreturn_t ariadne_interrupt(int irq, void *data)
 	return IRQ_NONE;
     }
 
+    *lance = (struct Am79C960*)dev->base_addr;
     lance->RAP = CSR0;			/* PCnet-ISA Controller Status */
 
     if (!(lance->RDP & INTR))		/* Check if any interrupt has been */
-- 
1.7.3.4

