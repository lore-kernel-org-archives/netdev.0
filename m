From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 11/12] sky2: avoid divide in receive path
Date: Wed, 29 Aug 2007 12:58:20 -0700
Message-ID: <20070829195843.233327131@linux-foundation.org>
References: <20070829193922.078561651@linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:37658 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752969AbXH2UKS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 16:10:18 -0400
Content-Disposition: inline; filename=sky2-rx-ring-mod.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Avoid divide (modulus) in receive buffer handling path.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/drivers/net/sky2.c	2007-08-29 11:41:23.000000000 -0700
+++ b/drivers/net/sky2.c	2007-08-29 11:45:00.000000000 -0700
@@ -2140,7 +2140,8 @@ static struct sk_buff *sky2_receive(stru
 		printk(KERN_DEBUG PFX "%s: rx slot %u status 0x%x len %d\n",
 		       dev->name, sky2->rx_next, status, length);
 
-	sky2->rx_next = (sky2->rx_next + 1) % sky2->rx_pending;
+	if (++sky2->rx_next >= sky2->rx_pending)
+		sky2->rx_next = 0;
 	prefetch(sky2->rx_ring + sky2->rx_next);
 
 	if (status & GMR_FS_ANY_ERR)

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

