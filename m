From: David Miller <davem@davemloft.net>
Subject: [PATCH]: niu: Use pci_ioremap_bar().
Date: Mon, 03 Nov 2008 17:06:24 -0800 (PST)
Message-ID: <20081103.170624.28350110.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41183
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752304AbYKDBGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 20:06:48 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 38476C8C183
	for <netdev@vger.kernel.org>; Mon,  3 Nov 2008 17:06:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Since everyone else is starting to use pci_ioremap_bar(),
I didn't want NIU to miss the party either.  And to be honest
it's a good safety check.

Committed to net-2.6

niu: Use pci_ioremap_bar().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/niu.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index ebc8127..9acb5d7 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -8667,7 +8667,6 @@ static void __devinit niu_device_announce(struct niu *np)
 static int __devinit niu_pci_init_one(struct pci_dev *pdev,
 				      const struct pci_device_id *ent)
 {
-	unsigned long niureg_base, niureg_len;
 	union niu_parent_id parent_id;
 	struct net_device *dev;
 	struct niu *np;
@@ -8758,10 +8757,7 @@ static int __devinit niu_pci_init_one(struct pci_dev *pdev,
 
 	dev->features |= (NETIF_F_SG | NETIF_F_HW_CSUM);
 
-	niureg_base = pci_resource_start(pdev, 0);
-	niureg_len = pci_resource_len(pdev, 0);
-
-	np->regs = ioremap_nocache(niureg_base, niureg_len);
+	np->regs = pci_ioremap_bar(pdev, 0);
 	if (!np->regs) {
 		dev_err(&pdev->dev, PFX "Cannot map device registers, "
 			"aborting.\n");
-- 
1.5.6.5

