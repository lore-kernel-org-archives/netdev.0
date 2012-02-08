From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 31/50] tc35815: use dev_hw_addr_random() instead of random_ether_addr()
Date: Wed,  8 Feb 2012 22:10:38 +0100
Message-ID: <1328735457-29986-32-git-send-email-danny.kukawka@bisect.de>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Paul <paul.gortmaker@windriver.com>,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wp188.webpack.hosteurope.de ([80.237.132.195]:36567 "EHLO
	wp188.webpack.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755518Ab2BHVMt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 16:12:49 -0500
In-Reply-To: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use dev_hw_addr_random() instead of calling random_ether_addr()
to set addr_assign_type correctly to NET_ADDR_RANDOM.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/ethernet/toshiba/tc35815.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/toshiba/tc35815.c b/drivers/net/ethernet/toshiba/tc35815.c
index 71b785c..b5bb9ed 100644
--- a/drivers/net/ethernet/toshiba/tc35815.c
+++ b/drivers/net/ethernet/toshiba/tc35815.c
@@ -850,7 +850,7 @@ static int __devinit tc35815_init_one(struct pci_dev *pdev,
 	/* Retrieve the ethernet address. */
 	if (tc35815_init_dev_addr(dev)) {
 		dev_warn(&pdev->dev, "not valid ether addr\n");
-		random_ether_addr(dev->dev_addr);
+		dev_hw_addr_random(dev, dev->dev_addr);
 	}
 
 	rc = register_netdev(dev);
-- 
1.7.7.3
