From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] jme: fix panic on load
Date: Sun, 31 Oct 2010 16:46:18 +0100
Message-ID: <1288539978.2660.47.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Guo-Fu Tseng <cooldavid@cooldavid.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:65165 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755937Ab0JaPqY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Oct 2010 11:46:24 -0400
Received: by wyf28 with SMTP id 28so4702183wyf.19
        for <netdev@vger.kernel.org>; Sun, 31 Oct 2010 08:46:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Its now illegal to call netif_stop_queue() before register_netdev()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Guo-Fu Tseng <cooldavid@cooldavid.org>
---
 drivers/net/jme.c |    4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index d85edf3..c57d9a4 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -2955,11 +2955,7 @@ jme_init_one(struct pci_dev *pdev,
 	 * Tell stack that we are not ready to work until open()
 	 */
 	netif_carrier_off(netdev);
-	netif_stop_queue(netdev);
 
-	/*
-	 * Register netdev
-	 */
 	rc = register_netdev(netdev);
 	if (rc) {
 		pr_err("Cannot register net device\n");


