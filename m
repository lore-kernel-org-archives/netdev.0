From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 09/12] sky2: use roundup() macro
Date: Mon, 09 Jul 2007 15:33:41 -0700
Message-ID: <20070709223453.505786980@linux-foundation.org>
References: <20070709223332.966231494@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:60841 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755796AbXGIWhU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 18:37:20 -0400
Content-Disposition: inline; filename=sky2-roundup.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use roundup() macro to size receive buffer.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/sky2.c	2007-07-09 15:30:12.000000000 -0700
+++ b/drivers/net/sky2.c	2007-07-09 15:30:13.000000000 -0700
@@ -1180,8 +1180,7 @@ static int sky2_rx_start(struct sky2_por
 	rx_set_checksum(sky2);
 
 	/* Space needed for frame data + headers rounded up */
-	size = ALIGN(sky2->netdev->mtu + ETH_HLEN + VLAN_HLEN, 8)
-		+ 8;
+	size = roundup(sky2->netdev->mtu + ETH_HLEN + VLAN_HLEN, 8);
 
 	/* Stopping point for hardware truncation */
 	thresh = (size - 8) / sizeof(u32);

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

