From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 6/7] qlge: bugfix: Fix RX scaling values.
Date: Wed, 11 Feb 2009 05:58:36 -0800
Message-ID: <1234360717-32194-6-git-send-email-ron.mercer@qlogic.com>
References: <1234360717-32194-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:50248 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754852AbZBKOBU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2009 09:01:20 -0500
In-Reply-To: <1234360717-32194-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Receive packets were only scaling across 2 of the receive queues. The
value was hardcoded to 2 instead of being based on how many rx queues
were running.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 54b0a9e..3ab0369 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -2884,8 +2884,8 @@ static int ql_start_rss(struct ql_adapter *qdev)
 	/*
 	 * Fill out the Indirection Table.
 	 */
-	for (i = 0; i < 32; i++)
-		hash_id[i] = i & 1;
+	for (i = 0; i < 256; i++)
+		hash_id[i] = i & (qdev->rss_ring_count - 1);
 
 	/*
 	 * Random values for the IPv6 and IPv4 Hash Keys.
-- 
1.6.0.2

