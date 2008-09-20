From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH] atl2: add tx bytes statistic
Date: Sat, 20 Sep 2008 18:47:05 -0500
Message-ID: <20080920184705.46ba1669@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Chris Snook <csnook@redhat.com>, jie.yang@atheros.com,
	netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost01.isp.att.net ([204.127.217.101]:34193 "EHLO
	fmailhost01.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751714AbYITXrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 19:47:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Cliburn <jacliburn@bellsouth.net>
Date: Sat, 20 Sep 2008 17:37:05 -0500
Subject: [PATCH] atl2: add tx bytes statistic

Let's see how many bytes have been transmitted.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/atlx/atl2.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/atlx/atl2.c b/drivers/net/atlx/atl2.c
index b2995ac..4f82f66 100644
--- a/drivers/net/atlx/atl2.c
+++ b/drivers/net/atlx/atl2.c
@@ -522,8 +522,10 @@ static void atl2_intr_tx(struct atl2_adapter *adapter)
 		atomic_set(&adapter->txd_read_ptr, (int)txd_read_ptr);
 
 		/* tx statistics: */
-		if (txs->ok)
+		if (txs->ok) {
+			adapter->net_stats.tx_bytes += txs->pkt_size;
 			adapter->net_stats.tx_packets++;
+		}
 		else
 			adapter->net_stats.tx_errors++;
 
-- 
1.5.5.1

