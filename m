From: Paul Chavent <Paul.Chavent@onera.fr>
Subject: [PATCH] net : enable tx time stamping in the vde driver.
Date: Thu,  6 Dec 2012 16:25:05 +0100
Message-ID: <1354807505-21222-1-git-send-email-paul.chavent@onera.fr>
Cc: Paul Chavent <Paul.Chavent@onera.fr>
To: jdike@addtoit.com, richard@nod.at,
	user-mode-linux-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from briaree.onecert.fr ([134.212.190.4]:59684 "EHLO
	briaree.onecert.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964876Ab2LFP3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 10:29:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This new version moves the skb_tx_timestamp in the main uml
driver. This should avoid the need to call this function in each
transport (vde, slirp, tuntap, ...). It also add support for ethtool
get_ts_info.

Signed-off-by: Paul Chavent <paul.chavent@onera.fr>
---
 arch/um/drivers/net_kern.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/um/drivers/net_kern.c b/arch/um/drivers/net_kern.c
index b1314eb..5aa8696 100644
--- a/arch/um/drivers/net_kern.c
+++ b/arch/um/drivers/net_kern.c
@@ -218,6 +218,7 @@ static int uml_net_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	spin_lock_irqsave(&lp->lock, flags);
 
 	len = (*lp->write)(lp->fd, skb, lp);
+	skb_tx_timestampns(skb);
 
 	if (len == skb->len) {
 		dev->stats.tx_packets++;
@@ -281,6 +282,7 @@ static void uml_net_get_drvinfo(struct net_device *dev,
 static const struct ethtool_ops uml_net_ethtool_ops = {
 	.get_drvinfo	= uml_net_get_drvinfo,
 	.get_link	= ethtool_op_get_link,
+	.get_ts_info	= ethtool_op_get_ts_info,
 };
 
 static void uml_net_user_timer_expire(unsigned long _conn)
-- 
1.7.12.1
