From: Thomas Meyer <thomas@m3y3r.de>
Subject: [PATCH] iwlegacy: Use kcalloc instead of kzalloc to allocate array
Date: Tue, 29 Nov 2011 22:08:00 +0100
Message-ID: <1322600880.1534.324.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www17.your-server.de ([213.133.104.17]:53243 "EHLO
	www17.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752525Ab1LCI2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2011 03:28:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The advantage of kcalloc is, that will prevent integer overflows which could
result from the multiplication of number of elements and size and it is also
a bit nicer to read.

The semantic patch that makes this change is available
in https://lkml.org/lkml/2011/11/25/107

Signed-off-by: Thomas Meyer <thomas@m3y3r.de>
---

diff -u -p a/drivers/net/wireless/iwlegacy/iwl-tx.c b/drivers/net/wireless/iwlegacy/iwl-tx.c
--- a/drivers/net/wireless/iwlegacy/iwl-tx.c 2011-11-13 11:07:38.540345582 +0100
+++ b/drivers/net/wireless/iwlegacy/iwl-tx.c 2011-11-28 19:55:42.036442592 +0100
@@ -297,8 +297,8 @@ static int iwl_legacy_tx_queue_alloc(str
 	/* Driver private data, only for Tx (not command) queues,
 	 * not shared with device. */
 	if (id != priv->cmd_queue) {
-		txq->txb = kzalloc(sizeof(txq->txb[0]) *
-				   TFD_QUEUE_SIZE_MAX, GFP_KERNEL);
+		txq->txb = kcalloc(TFD_QUEUE_SIZE_MAX, sizeof(txq->txb[0]),
+				   GFP_KERNEL);
 		if (!txq->txb) {
 			IWL_ERR(priv, "kmalloc for auxiliary BD "
 				  "structures failed\n");
