From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net-next v2 3/4] ibmveth: Add GRO support
Date: Mon, 27 Apr 2015 17:10:54 -0500
Message-ID: <1430172655-17606-3-git-send-email-tlfalcon@linux.vnet.ibm.com>
References: <1430172655-17606-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, nfont@linux.vnet.ibm.com,
	eric.dumazet@gmail.com, Brian King <brking@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:60295 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965506AbbD0WLG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2015 18:11:06 -0400
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
	Mon, 27 Apr 2015 16:11:06 -0600
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 30B9A1FF0021
	for <netdev@vger.kernel.org>; Mon, 27 Apr 2015 16:02:13 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp08027.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3RMB2os36110432
	for <netdev@vger.kernel.org>; Mon, 27 Apr 2015 15:11:02 -0700
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3RMB1xK028691
	for <netdev@vger.kernel.org>; Mon, 27 Apr 2015 16:11:02 -0600
In-Reply-To: <1430172655-17606-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
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
