From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 10/30] solos: Reject non-AAL5 connections.... for now
Date: Tue, 17 Mar 2009 21:29:18 +0000
Message-ID: <1237325358.27681.339.camel@macbook.infradead.org>
References: <1237310370.27681.314.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37658 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758075AbZCQV30 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 17:29:26 -0400
Received: from macbook.infradead.org ([2001:8b0:10b:1:216:eaff:fe05:bbb8])
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1Ljgqh-0001v6-Jn
	for netdev@vger.kernel.org; Tue, 17 Mar 2009 21:29:23 +0000
In-Reply-To: <1237310370.27681.314.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/atm/solos-pci.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index c289b62..b500f00 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -732,6 +732,12 @@ static int popen(struct atm_vcc *vcc)
 	struct sk_buff *skb;
 	struct pkt_hdr *header;
 
+	if (vcc->qos.aal != ATM_AAL5) {
+		dev_warn(&card->dev->dev, "Unsupported ATM type %d\n",
+			 vcc->qos.aal);
+		return -EINVAL;
+	}
+
 	skb = alloc_skb(sizeof(*header), GFP_ATOMIC);
 	if (!skb && net_ratelimit()) {
 		dev_warn(&card->dev->dev, "Failed to allocate sk_buff in popen()\n");
-- 
1.6.0.6


