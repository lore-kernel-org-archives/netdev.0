From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 2/3] can: Propagate SO_PRIORITY of raw sockets to skbs
Date: Wed, 29 Jan 2014 22:11:02 +0100
Message-ID: <1391029863-23099-3-git-send-email-mkl@pengutronix.de>
References: <1391029863-23099-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Rostislav Lisovy <lisovy@gmail.com>,
	Michal Sojka <sojkam1@fel.cvut.cz>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:49896 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751560AbaA2VLK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jan 2014 16:11:10 -0500
In-Reply-To: <1391029863-23099-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rostislav Lisovy <lisovy@gmail.com>

This allows controlling certain queueing disciplines by setting the
socket's SO_PRIORITY option.

For example, with the default pfifo_fast queueing discipline, which
provides three priorities, socket priority TC_PRIO_CONTROL means
higher than default and TC_PRIO_BULK means lower than default.

Signed-off-by: Rostislav Lisovy <lisovy@gmail.com>
Signed-off-by: Michal Sojka <sojkam1@fel.cvut.cz>
Acked-by: Oliver Hartkopp <socketcan@hartkopp.net>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 net/can/raw.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/can/raw.c b/net/can/raw.c
index 07d72d8..8be757c 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -715,6 +715,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct socket *sock,
 
 	skb->dev = dev;
 	skb->sk  = sk;
+	skb->priority = sk->sk_priority;
 
 	err = can_send(skb, ro->loopback);
 
-- 
1.8.5.3
