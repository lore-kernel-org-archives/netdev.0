From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH 6/9] net: mvmdio: put the poll intervals in the private structure
Date: Wed,  7 Jun 2017 10:38:07 +0200
Message-ID: <20170607083810.30922-7-antoine.tenart@free-electrons.com>
References: <20170607083810.30922-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, mw@semihalf.com,
        linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:37630 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751452AbdFGIjQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 04:39:16 -0400
In-Reply-To: <20170607083810.30922-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Put the two poll intervals (min and max) in the driver's private
structure. This is needed to add the xmdio support later.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvmdio.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index 8a71ef93a61b..3cb3dd3331d8 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -63,6 +63,9 @@ struct orion_mdio_dev {
 	int err_interrupt;
 	wait_queue_head_t smi_busy_wait;
 	struct orion_mdio_ops *ops;
+
+	unsigned int poll_interval_min;
+	unsigned int poll_interval_max;
 };
 
 struct orion_mdio_ops {
@@ -123,8 +126,8 @@ static int orion_mdio_wait_ready(struct mii_bus *bus)
 			break;
 
 	        if (dev->err_interrupt <= 0) {
-			usleep_range(MVMDIO_SMI_POLL_INTERVAL_MIN,
-				     MVMDIO_SMI_POLL_INTERVAL_MAX);
+			usleep_range(dev->poll_interval_min,
+				     dev->poll_interval_max);
 
 			if (time_is_before_jiffies(end))
 				++timedout;
@@ -279,6 +282,8 @@ static int orion_mdio_probe(struct platform_device *pdev)
 	if (!ops)
 		return -ENOMEM;
 
+	dev->poll_interval_min = MVMDIO_SMI_POLL_INTERVAL_MIN;
+	dev->poll_interval_max = MVMDIO_SMI_POLL_INTERVAL_MAX;
 	ops->is_done = orion_mdio_smi_is_done;
 	ops->is_read_valid = orion_mdio_smi_is_read_valid;
 	ops->start_read = orion_mdio_start_read_op;
-- 
2.9.4
