From: Benedikt Spranger <b.spranger@linutronix.de>
Subject: [PATCH 13/16] c_can: flexcard: add ioctl to reset FIFO message object
Date: Mon,  9 Sep 2013 09:25:10 +0200
Message-ID: <1378711513-2548-14-git-send-email-b.spranger@linutronix.de>
References: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de>
Cc: Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Holger Dengler <dengler@linutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:38025 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751171Ab3IIHnZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 03:43:25 -0400
In-Reply-To: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The FlexCard FIFO reset implementation did not reset the FIFO message object.
Since the FIFO configuration is done from userspace a function to reset the
FIFO message object is needed. Add an ioctl to reset the FIFO message object
from userspace.

Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>
---
 drivers/net/can/c_can/c_can.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index 51ca2a6..670a6b1 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -1447,7 +1447,21 @@ void free_c_can_dev(struct net_device *dev)
 }
 EXPORT_SYMBOL_GPL(free_c_can_dev);
 
+static int c_can_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+{
+	switch (cmd) {
+	case SIOCDEVPRIVATE:
+		c_can_inval_msg_object(dev, 0, FC_TXFIFO_MO);
+		break;
+	default:
+		return -ENOIOCTLCMD;
+	}
+
+	return 0;
+}
+
 static const struct net_device_ops c_can_netdev_ops = {
+	.ndo_do_ioctl = c_can_ioctl,
 	.ndo_open = c_can_open,
 	.ndo_stop = c_can_close,
 	.ndo_start_xmit = c_can_start_xmit,
-- 
1.8.4.rc3
