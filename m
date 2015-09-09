From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH 1/4] net: cavium: liquidio: use kzalloc in setup_glist()
Date: Wed,  9 Sep 2015 10:38:02 +0200
Message-ID: <1441787886-7214-2-git-send-email-linux@rasmusvillemoes.dk>
References: <1441787886-7214-1-git-send-email-linux@rasmusvillemoes.dk>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:36746 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752119AbbIIIi0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 04:38:26 -0400
Received: by lanb10 with SMTP id b10so1977042lan.3
        for <netdev@vger.kernel.org>; Wed, 09 Sep 2015 01:38:25 -0700 (PDT)
In-Reply-To: <1441787886-7214-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We save a little .text and get rid of the sizeof(...) style
inconsistency.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 0660deecc2c9..f683d97d7614 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -818,10 +818,9 @@ static int setup_glist(struct lio *lio)
 	INIT_LIST_HEAD(&lio->glist);
 
 	for (i = 0; i < lio->tx_qsize; i++) {
-		g = kmalloc(sizeof(*g), GFP_KERNEL);
+		g = kzalloc(sizeof(*g), GFP_KERNEL);
 		if (!g)
 			break;
-		memset(g, 0, sizeof(struct octnic_gather));
 
 		g->sg_size =
 			((ROUNDUP4(OCTNIC_MAX_SG) >> 2) * OCT_SG_ENTRY_SIZE);
-- 
2.1.3
