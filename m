From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 1/2] smsc9420: add netpoll support
Date: Thu, 11 Dec 2008 11:01:51 +0000
Message-ID: <1228993312-16738-2-git-send-email-steve.glendinning@smsc.com>
References: <1228993312-16738-1-git-send-email-steve.glendinning@smsc.com>
Cc: Vlad Lyalikov <vlad.lyalikov@smsc.com>,
	Ian Saturley <ian.saturley@smsc.com>,
	David Miller <davem@davemloft.net>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [86.54.240.115] ([86.54.240.115]:55106 "EHLO
	drevil2.shawell.net" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754953AbYLKLBw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 06:01:52 -0500
In-Reply-To: <1228993312-16738-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/smsc9420.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/smsc9420.c b/drivers/net/smsc9420.c
index b04bfb2..80dab8b 100644
--- a/drivers/net/smsc9420.c
+++ b/drivers/net/smsc9420.c
@@ -550,6 +550,15 @@ static irqreturn_t smsc9420_isr(int irq, void *dev_id)
 	return ret;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void smsc9420_poll_controller(struct net_device *dev)
+{
+	disable_irq(dev->irq);
+	smsc9420_isr(0, dev);
+	enable_irq(dev->irq);
+}
+#endif /* CONFIG_NET_POLL_CONTROLLER */
+
 static void smsc9420_dmac_soft_reset(struct smsc9420_pdata *pd)
 {
 	smsc9420_reg_write(pd, BUS_MODE, BUS_MODE_SWR_);
@@ -1418,6 +1427,9 @@ static const struct net_device_ops smsc9420_netdev_ops = {
 	.ndo_set_multicast_list	= smsc9420_set_multicast_list,
 	.ndo_do_ioctl		= smsc9420_do_ioctl,
 	.ndo_validate_addr	= eth_validate_addr,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= smsc9420_poll_controller,
+#endif /* CONFIG_NET_POLL_CONTROLLER */
 };
 
 static int __devinit
-- 
1.5.6.5

