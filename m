From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH 6/7] net: mvneta: Change the number of default rx queues to one
Date: Sat,  3 May 2014 15:27:01 -0300
Message-ID: <1399141622-30654-7-git-send-email-ezequiel.garcia@free-electrons.com>
References: <1399141622-30654-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jason Cooper <jason@lakedaemon.net>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	Willy Tarreau <w@1wt.eu>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:60658 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752410AbaECS2c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 May 2014 14:28:32 -0400
In-Reply-To: <1399141622-30654-1-git-send-email-ezequiel.garcia@free-electrons.com>
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
