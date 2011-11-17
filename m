From: Thomas Meyer <thomas@m3y3r.de>
Subject: [PATCH] net: Use kzalloc rather than kmalloc followed by memset
 with 0
Date: Thu, 17 Nov 2011 23:43:40 +0100
Message-ID: <1321569820.1624.263.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www17.your-server.de ([213.133.104.17]:48424 "EHLO
	www17.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756805Ab1KRJ1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 04:27:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This considers some simple cases that are common and easy to validate
Note in particular that there are no ...s in the rule, so all of the
matched code has to be contiguous

The semantic patch that makes this change is available
in scripts/coccinelle/api/alloc/kzalloc-simple.cocci.

Signed-off-by: Thomas Meyer <thomas@m3y3r.de>
---

diff -u -p a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
--- a/drivers/net/ethernet/micrel/ksz884x.c 2011-11-07 19:37:59.173455664 +0100
+++ b/drivers/net/ethernet/micrel/ksz884x.c 2011-11-08 09:32:00.426428212 +0100
@@ -4382,12 +4382,10 @@ static void ksz_update_timer(struct ksz_
  */
 static int ksz_alloc_soft_desc(struct ksz_desc_info *desc_info, int transmit)
 {
-	desc_info->ring = kmalloc(sizeof(struct ksz_desc) * desc_info->alloc,
-		GFP_KERNEL);
+	desc_info->ring = kzalloc(sizeof(struct ksz_desc) * desc_info->alloc,
+				  GFP_KERNEL);
 	if (!desc_info->ring)
 		return 1;
-	memset((void *) desc_info->ring, 0,
-		sizeof(struct ksz_desc) * desc_info->alloc);
 	hw_init_desc(desc_info, transmit);
 	return 0;
 }
