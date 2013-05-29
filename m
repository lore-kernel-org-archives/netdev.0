From: Simon Horman <horms@verge.net.au>
Subject: [PATCH net-next v2 1/7] isdn: Correct comparison of skb->tail and skb-transport_header
Date: Wed, 29 May 2013 15:34:23 +0900
Message-ID: <1369809269-13130-2-git-send-email-horms@verge.net.au>
References: <1369809269-13130-1-git-send-email-horms@verge.net.au>
Cc: netdev@vger.kernel.org, Simon Horman <horms@verge.net.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:53143 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757865Ab3E2Gds (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 02:33:48 -0400
In-Reply-To: <1369809269-13130-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This corrects an regression introduced by "net: Use 16bits for *_headers
fields of struct skbuff" when NET_SKBUFF_DATA_USES_OFFSET is not set. In
that case skb->tail will be a pointer whereas skb->transport_header
will be an offset from head. This is corrected by using wrappers that
ensure that the comparison is always between pointers.

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 drivers/isdn/i4l/isdn_net.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/isdn/i4l/isdn_net.c b/drivers/isdn/i4l/isdn_net.c
index 88d657d..8b98d53 100644
--- a/drivers/isdn/i4l/isdn_net.c
+++ b/drivers/isdn/i4l/isdn_net.c
@@ -885,7 +885,7 @@ isdn_net_log_skb(struct sk_buff *skb, isdn_net_local *lp)
 
 	addinfo[0] = '\0';
 	/* This check stolen from 2.1.72 dev_queue_xmit_nit() */
-	if (p < skb->data || skb->network_header >= skb->tail) {
+	if (p < skb->data || skb_network_header(skb) >= skb_tail_pointer(skb)) {
 		/* fall back to old isdn_net_log_packet method() */
 		char *buf = skb->data;
 
-- 
1.7.10.4
