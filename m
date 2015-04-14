From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH 3/5] ibmveth: Add GRO support
Date: Tue, 14 Apr 2015 15:35:02 -0500
Message-ID: <1429043704-22552-3-git-send-email-tlfalcon@linux.vnet.ibm.com>
References: <1429043704-22552-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org,
	Brian King <brking@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:39187 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754629AbbDNUfL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 16:35:11 -0400
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
	Tue, 14 Apr 2015 14:35:11 -0600
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id A56AD3E40044
	for <netdev@vger.kernel.org>; Tue, 14 Apr 2015 14:35:08 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp08026.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3EKZ8kV44892196
	for <netdev@vger.kernel.org>; Tue, 14 Apr 2015 13:35:08 -0700
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3EKZ7Pm014562
	for <netdev@vger.kernel.org>; Tue, 14 Apr 2015 14:35:08 -0600
In-Reply-To: <1429043704-22552-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Brian King <brking@linux.vnet.ibm.com>
Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmveth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
index 2911a57..08970c7 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -1137,7 +1137,7 @@ restart_poll:
 			if (csum_good)
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
 
-			netif_receive_skb(skb);	/* send it up */
+			napi_gro_receive(napi, skb);	/* send it up */
 
 			netdev->stats.rx_packets++;
 			netdev->stats.rx_bytes += length;
-- 
1.8.3.1
