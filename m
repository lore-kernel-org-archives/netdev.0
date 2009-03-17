From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 13/30] solos: Remove parameter group from sysfs on ATM dev
 deregister
Date: Tue, 17 Mar 2009 21:29:25 +0000
Message-ID: <1237325365.27681.342.camel@macbook.infradead.org>
References: <1237310370.27681.314.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37661 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758146AbZCQV3a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 17:29:30 -0400
Received: from macbook.infradead.org ([2001:8b0:10b:1:216:eaff:fe05:bbb8])
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1Ljgql-0001vM-PH
	for netdev@vger.kernel.org; Tue, 17 Mar 2009 21:29:28 +0000
In-Reply-To: <1237310370.27681.314.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/atm/solos-pci.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 2dca5ff..b7d4af3 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -1166,6 +1166,8 @@ static void atm_remove(struct solos_card *card)
 	for (i = 0; i < card->nr_ports; i++) {
 		if (card->atmdev[i]) {
 			dev_info(&card->dev->dev, "Unregistering ATM device %d\n", card->atmdev[i]->number);
+
+			sysfs_remove_group(&card->atmdev[i]->class_dev.kobj, &solos_attr_group);
 			atm_dev_deregister(card->atmdev[i]);
 		}
 	}
-- 
1.6.0.6


