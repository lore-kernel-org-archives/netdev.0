From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 2/3] can: fix oops caused by wrong rtnl dellink usage
Date: Thu, 23 Jun 2016 11:22:20 +0200
Message-ID: <1466673741-23115-3-git-send-email-mkl@pengutronix.de>
References: <1466673741-23115-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Oliver Hartkopp <socketcan@hartkopp.net>,
	stable@vger.kernel.org, Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:43403 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751454AbcFWJW3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 05:22:29 -0400
In-Reply-To: <1466673741-23115-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>

For 'real' hardware CAN devices the netlink interface is used to set CAN
specific communication parameters. Real CAN hardware can not be created nor
removed with the ip tool ...

This patch adds a private dellink function for the CAN device driver interface
that does just nothing.

It's a follow up to commit 993e6f2fd ("can: fix oops caused by wrong rtnl
newlink usage") but for dellink.

Reported-by: ajneu <ajneu1@gmail.com>
Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
Cc: <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/dev.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index 348dd5001fa4..ad535a854e5c 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -1011,6 +1011,11 @@ static int can_newlink(struct net *src_net, struct net_device *dev,
 	return -EOPNOTSUPP;
 }
 
+static void can_dellink(struct net_device *dev, struct list_head *head)
+{
+	return;
+}
+
 static struct rtnl_link_ops can_link_ops __read_mostly = {
 	.kind		= "can",
 	.maxtype	= IFLA_CAN_MAX,
@@ -1019,6 +1024,7 @@ static struct rtnl_link_ops can_link_ops __read_mostly = {
 	.validate	= can_validate,
 	.newlink	= can_newlink,
 	.changelink	= can_changelink,
+	.dellink	= can_dellink,
 	.get_size	= can_get_size,
 	.fill_info	= can_fill_info,
 	.get_xstats_size = can_get_xstats_size,
-- 
2.8.1
