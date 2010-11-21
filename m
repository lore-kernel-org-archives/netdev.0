From: Joe Perches <joe@perches.com>
Subject: [PATCH 22/62] hp: Use static const
Date: Sat, 20 Nov 2010 18:38:23 -0800
Message-ID: <6a5db66ec82dab8c4438da5751874778d93b7f30.1290305776.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1666 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756076Ab0KUCkC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Nov 2010 21:40:02 -0500
In-Reply-To: <cover.1290305773.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
   4743	    104	   1256	   6103	   17d7	drivers/net/hp.o.new
   4720	    104	   1256	   6080	   17c0	drivers/net/hp.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/hp.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/hp.c b/drivers/net/hp.c
index d15d2f2..ef20143 100644
--- a/drivers/net/hp.c
+++ b/drivers/net/hp.c
@@ -162,9 +162,9 @@ static int __init hp_probe1(struct net_device *dev, int ioaddr)
 
 	/* Snarf the interrupt now.  Someday this could be moved to open(). */
 	if (dev->irq < 2) {
-		int irq_16list[] = { 11, 10, 5, 3, 4, 7, 9, 0};
-		int irq_8list[] = { 7, 5, 3, 4, 9, 0};
-		int *irqp = wordmode ? irq_16list : irq_8list;
+		static const int irq_16list[] = { 11, 10, 5, 3, 4, 7, 9, 0};
+		static const int irq_8list[] = { 7, 5, 3, 4, 9, 0};
+		const int *irqp = wordmode ? irq_16list : irq_8list;
 		do {
 			int irq = *irqp;
 			if (request_irq (irq, NULL, 0, "bogus", NULL) != -EBUSY) {
-- 
1.7.3.2.245.g03276.dirty

