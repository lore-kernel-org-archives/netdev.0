From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 10/17] sky2: add prefetch for next skb on receive
Date: Tue, 08 May 2007 20:49:59 -0700
Message-ID: <20070509035029.859249988@linux-foundation.org>
References: <20070509034949.624934448@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:40903 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1033215AbXEIED7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 00:03:59 -0400
Cc: Greg KH <greg@kroah.com>
Content-Disposition: inline; filename=sky2-prefetch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Prefetch the next skb information in receive.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |    1 +
 1 file changed, 1 insertion(+)

--- sky2-2.6.21.orig/drivers/net/sky2.c	2007-05-08 10:29:14.000000000 -0700
+++ sky2-2.6.21/drivers/net/sky2.c	2007-05-08 10:29:17.000000000 -0700
@@ -2160,6 +2160,7 @@ force_update:
 			/* Stop after net poll weight */
 			if (++work_done >= to_do)
 				goto exit_loop;
+			prefetch(sky2->rx_ring[sky2->rx_next].skb);
 			break;
 
 #ifdef SKY2_VLAN_TAG_USED

--

