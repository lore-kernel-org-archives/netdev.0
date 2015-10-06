From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 1/3] Subject: s390/qeth: switch to napi_gro_receive
Date: Tue,  6 Oct 2015 15:12:27 +0200
Message-ID: <1444137149-919-2-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1444137149-919-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com, ubraun@linux.vnet.ibm.com,
	Thomas Richter <tmricht@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp16.uk.ibm.com ([195.75.94.112]:55325 "EHLO
	e06smtp16.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752007AbbJFNMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 09:12:42 -0400
Received: from localhost
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Tue, 6 Oct 2015 14:12:40 +0100
In-Reply-To: <1444137149-919-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Richter <tmricht@linux.vnet.ibm.com

Add support for GRO (generic receive offload) in the layer 2
part of device driver qeth. This results in a performance
improvement when GRO and RX is turned on.

Signed-off-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---
 drivers/s390/net/qeth_l2_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index dc905b3..b6eabfa 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -511,7 +511,7 @@ static int qeth_l2_process_inbound_buffer(struct qeth_card *card,
 			if (skb->protocol == htons(ETH_P_802_2))
 				*((__u32 *)skb->cb) = ++card->seqno.pkt_seqno;
 			len = skb->len;
-			netif_receive_skb(skb);
+			napi_gro_receive(&card->napi, skb);
 			break;
 		case QETH_HEADER_TYPE_OSN:
 			if (card->info.type == QETH_CARD_TYPE_OSN) {
-- 
2.3.9
