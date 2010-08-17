From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] sunhme: Use return value of register_netdev
Date: Tue, 17 Aug 2010 18:13:05 +0200
Message-ID: <1282061585-19527-1-git-send-email-tklauser@distanz.ch>
Cc: kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:34260 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757274Ab0HQQNH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Aug 2010 12:13:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the return value provided by register_netdev on error instead of
using a previously set value.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/sunhme.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sunhme.c b/drivers/net/sunhme.c
index bd0df1c..d96431e 100644
--- a/drivers/net/sunhme.c
+++ b/drivers/net/sunhme.c
@@ -2808,7 +2808,8 @@ static int __devinit happy_meal_sbus_probe_one(struct platform_device *op, int i
 	happy_meal_set_initial_advertisement(hp);
 	spin_unlock_irq(&hp->happy_lock);
 
-	if (register_netdev(hp->dev)) {
+	err = register_netdev(hp->dev);
+	if (err) {
 		printk(KERN_ERR "happymeal: Cannot register net device, "
 		       "aborting.\n");
 		goto err_out_free_coherent;
@@ -3130,7 +3131,8 @@ static int __devinit happy_meal_pci_probe(struct pci_dev *pdev,
 	happy_meal_set_initial_advertisement(hp);
 	spin_unlock_irq(&hp->happy_lock);
 
-	if (register_netdev(hp->dev)) {
+	err = register_netdev(hp->dev);
+	if (err) {
 		printk(KERN_ERR "happymeal(PCI): Cannot register net device, "
 		       "aborting.\n");
 		goto err_out_iounmap;
-- 
1.7.0.4

