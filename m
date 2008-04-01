From: frank.blaschka@de.ibm.com
Subject: [patch 4/8] qeth: CCL-sequence numbers required for protocol ETH_P_802_2 only
Date: Tue, 01 Apr 2008 10:26:56 +0200
Message-ID: <20080401082742.852685000@de.ibm.com>
References: <20080401082652.754871000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <braunu@de.ibm.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:4279 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754118AbYDAI1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 04:27:45 -0400
Content-Disposition: inline; filename=04-qeth_ccl_sequence.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <braunu@de.ibm.com>

Symptom:     slow CCL response time
Problem:     non-ETH_P_802_2 packets are not delivered to NDH for
             CCL. But CCL detects missing sequence numbers, which
             cause a serious performance problem with CCL.
Solution:    assign sequence numbers only to 802.2 packets.

Signed-off-by: Ursula Braun <braunu@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 drivers/s390/net/qeth_l2_main.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: git_davem-2.6.26/drivers/s390/net/qeth_l2_main.c
===================================================================
--- git_davem-2.6.26.orig/drivers/s390/net/qeth_l2_main.c	2008-03-26 09:21:08.000000000 +0100
+++ git_davem-2.6.26/drivers/s390/net/qeth_l2_main.c	2008-03-31 11:19:36.000000000 +0200
@@ -451,7 +451,8 @@
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
 			else
 				skb->ip_summed = CHECKSUM_NONE;
-			*((__u32 *)skb->cb) = ++card->seqno.pkt_seqno;
+			if (skb->protocol == htons(ETH_P_802_2))
+				*((__u32 *)skb->cb) = ++card->seqno.pkt_seqno;
 			len = skb->len;
 			netif_rx(skb);
 			break;

-- 
