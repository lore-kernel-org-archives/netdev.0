From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/2] gtp: Fix initialization of Flags octet in GTPv1 header
Date: Thu, 15 Dec 2016 22:35:53 +0100
Message-ID: <1481837753-10317-3-git-send-email-pablo@netfilter.org>
References: <1481837753-10317-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, laforge@gnumonks.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57330 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752293AbcLOVgM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Dec 2016 16:36:12 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 321BA7655
        for <netdev@vger.kernel.org>; Thu, 15 Dec 2016 22:36:11 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 21321DA861
        for <netdev@vger.kernel.org>; Thu, 15 Dec 2016 22:36:11 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 84AE3DA851
        for <netdev@vger.kernel.org>; Thu, 15 Dec 2016 22:36:08 +0100 (CET)
In-Reply-To: <1481837753-10317-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harald Welte <laforge@gnumonks.org>

When generating a GTPv1 header in gtp1_push_header(), initialize the
'reserved' bit to zero.  All 3GPP specifications for GTPv1 from Release
99 through Release 13 agree that a transmitter shall set this bit to
zero, see e.g. Note 0 of Figure 2 in Section 6 of 3GPP TS 29.060 v13.5.0
Release 13, available from
http://www.etsi.org/deliver/etsi_ts/129000_129099/129060/13.05.00_60/ts_129060v130500p.pdf

Signed-off-by: Harald Welte <laforge@gnumonks.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 drivers/net/gtp.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 6031d499f2be..8b6810bad54b 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -423,11 +423,11 @@ static inline void gtp1_push_header(struct sk_buff *skb, struct pdp_ctx *pctx)
 
 	/* Bits    8  7  6  5  4  3  2	1
 	 *	  +--+--+--+--+--+--+--+--+
-	 *	  |version |PT| 1| E| S|PN|
+	 *	  |version |PT| 0| E| S|PN|
 	 *	  +--+--+--+--+--+--+--+--+
 	 *	    0  0  1  1	1  0  0  0
 	 */
-	gtp1->flags	= 0x38; /* v1, GTP-non-prime. */
+	gtp1->flags	= 0x30; /* v1, GTP-non-prime. */
 	gtp1->type	= GTP_TPDU;
 	gtp1->length	= htons(payload_len);
 	gtp1->tid	= htonl(pctx->u.v1.o_tei);
-- 
2.1.4
