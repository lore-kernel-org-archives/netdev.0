From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net-next v3 3/4] ibmveth: Add GRO support
Date: Wed, 29 Apr 2015 16:25:46 -0500
Message-ID: <1430342747-16774-3-git-send-email-tlfalcon@linux.vnet.ibm.com>
References: <1430342747-16774-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, nfont@linux.vnet.ibm.com,
	eric.dumazet@gmail.com, Brian King <brking@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:43312 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750883AbbD2VZ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 17:25:56 -0400
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
	Wed, 29 Apr 2015 15:25:56 -0600
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 6E30919D8026
	for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 15:16:57 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by b03cxnp07029.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3TLPqqg54329496
	for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 14:25:53 -0700
Received: from d03av01.boulder.ibm.com (localhost [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3TLPq8q021695
	for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 15:25:52 -0600
In-Reply-To: <1430342747-16774-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Brian King <brking@linux.vnet.ibm.com>
Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmveth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
index 25cfc26..f0ec4e5 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -1139,7 +1139,7 @@ restart_poll:
 			if (csum_good)
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
 
-			netif_receive_skb(skb);	/* send it up */
+			napi_gro_receive(napi, skb);	/* send it up */
 
 			netdev->stats.rx_packets++;
 			netdev->stats.rx_bytes += length;
-- 
1.9.3
