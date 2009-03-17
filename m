From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 12/30] solos: Fix under-allocation of skb size for get/set
 parameters
Date: Tue, 17 Mar 2009 21:29:24 +0000
Message-ID: <1237325364.27681.341.camel@macbook.infradead.org>
References: <1237310370.27681.314.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37660 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758065AbZCQV33 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 17:29:29 -0400
Received: from macbook.infradead.org ([2001:8b0:10b:1:216:eaff:fe05:bbb8])
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1Ljgqk-0001vC-ED
	for netdev@vger.kernel.org; Tue, 17 Mar 2009 21:29:26 +0000
In-Reply-To: <1237310370.27681.314.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/atm/solos-pci.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 2978699..2dca5ff 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -159,7 +159,7 @@ static ssize_t solos_param_show(struct device *dev, struct device_attribute *att
 
 	buflen = strlen(attr->attr.name) + 10;
 
-	skb = alloc_skb(buflen, GFP_KERNEL);
+	skb = alloc_skb(sizeof(*header) + buflen, GFP_KERNEL);
 	if (!skb) {
 		dev_warn(&card->dev->dev, "Failed to allocate sk_buff in solos_param_show()\n");
 		return -ENOMEM;
@@ -215,7 +215,7 @@ static ssize_t solos_param_store(struct device *dev, struct device_attribute *at
 
 	buflen = strlen(attr->attr.name) + 11 + count;
 
-	skb = alloc_skb(buflen, GFP_KERNEL);
+	skb = alloc_skb(sizeof(*header) + buflen, GFP_KERNEL);
 	if (!skb) {
 		dev_warn(&card->dev->dev, "Failed to allocate sk_buff in solos_param_store()\n");
 		return -ENOMEM;
-- 
1.6.0.6


