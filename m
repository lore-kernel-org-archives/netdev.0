From: Ben Dooks <ben-linux@fluff.org>
Subject: [PATCH] DM9000 - do no re-init spin lock
Date: Wed, 14 Jun 2006 00:05:50 +0100
Message-ID: <20060613230550.GA27024@home.fluff.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="gKMricLos+KVdGMg"
Return-path: <netdev-owner@vger.kernel.org>
Received: from host-84-9-203-241.bulldogdsl.com ([84.9.203.241]:5290 "EHLO
	aeryn.fluff.org.uk") by vger.kernel.org with ESMTP id S1751181AbWFMXGK
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jun 2006 19:06:10 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--gKMricLos+KVdGMg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

The DM9000 initialisation sequence for the
hardware re-initialise the board spin-lock,
which is in my view wrong.

This patch removes the extra spin lock
initialisation

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

--gKMricLos+KVdGMg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dm9k-no-spinlock-reinit.patch"

--- ../linux-2.6.17/linux-2.6.17-rc5/drivers/net/dm9000.c	2006-03-20 05:53:29.000000000 +0000
+++ linux-2.6.16-simtec2/drivers/net/dm9000.c	2006-05-22 21:46:18.000000000 +0100
@@ -663,7 +665,6 @@ dm9000_init_dm9000(struct net_device *de
 	db->tx_pkt_cnt = 0;
 	db->queue_pkt_len = 0;
 	dev->trans_start = 0;
-	spin_lock_init(&db->lock);
 }
 
 /*

--gKMricLos+KVdGMg--
