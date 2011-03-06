From: j223yang@asset.uwaterloo.ca
Subject: [Patch] ariadne: fix possible null dereference
Date: Sun, 6 Mar 2011 02:08:32 -0500
Message-ID: <20110306070832.GA26188@asset.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: rdunlap@xenotime.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from asset.uwaterloo.ca ([129.97.92.29]:37781 "EHLO
	asset.uwaterloo.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751029Ab1CFHIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2011 02:08:34 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Randy,
I have tested my patch, and it is ok now.
Could you please try patching again? Sorry for previous trouble.
Thank you!
 
Jinqiu
------------------------------------------------------
This patch fixes bugzilla #13853:
https://bugzilla.kernel.org/show_bug.cgi?id=13853

The patch removes dereference of 'dev' after testing for NULL.

Signed-off-by: Jinqiu Yang<crindy646@gmail.com>
---
 ariadne.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ariadne.c b/drivers/net/ariadne.c
--- a/drivers/net/ariadne.c	2011-03-04 11:16:42.332164362 -0500
+++ b/drivers/net/ariadne.c	2011-03-05 21:11:52.949164759 -0500
@@ -420,7 +420,7 @@ static inline void ariadne_reset(struct 
 static irqreturn_t ariadne_interrupt(int irq, void *data)
 {
     struct net_device *dev = (struct net_device *)data;
-    volatile struct Am79C960 *lance = (struct Am79C960*)dev->base_addr;
+    volatile struct Am79C960 *lance;
     struct ariadne_private *priv;
     int csr0, boguscnt;
     int handled = 0;
@@ -430,6 +430,7 @@ static irqreturn_t ariadne_interrupt(int
 	return IRQ_NONE;
     }
 
+    lance = (struct Am79C960 *)dev->base_addr;
     lance->RAP = CSR0;			/* PCnet-ISA Controller Status */
 
     if (!(lance->RDP & INTR))		/* Check if any interrupt has been */
