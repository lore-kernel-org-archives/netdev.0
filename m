From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 02/30] solos: Slight debugging improvements
Date: Tue, 17 Mar 2009 21:29:09 +0000
Message-ID: <1237325349.27681.331.camel@macbook.infradead.org>
References: <1237310370.27681.314.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37650 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756876AbZCQV3N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 17:29:13 -0400
Received: from macbook.infradead.org ([2001:8b0:10b:1:216:eaff:fe05:bbb8])
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1LjgqV-0001ue-8n
	for netdev@vger.kernel.org; Tue, 17 Mar 2009 21:29:11 +0000
In-Reply-To: <1237310370.27681.314.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Print a message if pskb_expand_head fails.

Make atmdebug writable by root, so that you can turn printing of data sent to
and received from the card on and off at runtime - useful for tracking
corruption.

Signed-off-by: Simon Farnsworth <simon@farnz.org.uk>
Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/atm/solos-pci.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index f030954..3daa3a3 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -91,7 +91,7 @@ MODULE_LICENSE("GPL");
 MODULE_PARM_DESC(debug, "Enable Loopback");
 MODULE_PARM_DESC(atmdebug, "Print ATM data");
 module_param(debug, int, 0444);
-module_param(atmdebug, int, 0444);
+module_param(atmdebug, int, 0644);
 
 static int opens;
 
@@ -541,6 +541,7 @@ static int psend(struct atm_vcc *vcc, struct sk_buff *skb)
 
 		ret = pskb_expand_head(skb, expand_by, 0, GFP_ATOMIC);
 		if (ret) {
+			dev_warn(&card->dev->dev, "pskb_expand_head failed.\n");
 			solos_pop(vcc, skb);
 			return ret;
 		}
-- 
1.6.0.6


