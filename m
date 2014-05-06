From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH v2 6/9] net: mvneta: Change the number of default rx queues to one
Date: Tue,  6 May 2014 14:20:55 -0300
Message-ID: <1399396858-14551-7-git-send-email-ezequiel.garcia@free-electrons.com>
References: <1399396858-14551-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	Willy Tarreau <w@1wt.eu>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:53552 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753627AbaEFRVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 13:21:55 -0400
In-Reply-To: <1399396858-14551-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver does not support multiple rx queues, and so it's a waste
of resources to have a default number larger than one (1).

Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 0dcce29..ec4f67a 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -441,7 +441,10 @@ struct mvneta_rx_queue {
 	int next_desc_to_proc;
 };
 
-static int rxq_number = 8;
+/* The hardware supports eight (8) rx queues, but we are only allowing
+ * the first one to be used. Therefore, let's just allocate one queue.
+ */
+static int rxq_number = 1;
 static int txq_number = 8;
 
 static int rxq_def;
-- 
1.9.1
