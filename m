From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] atm: lec use dev_change_mtu
Date: Thu, 19 Mar 2009 17:24:00 -0700
Message-ID: <20090319172400.239594f8@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59210 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755824AbZCTAf1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Mar 2009 20:35:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rather than calling device pointer directly (which is incorrect with
net_device_ops), use the standard dev_change_mtu. Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/atm/lec.c	2009-03-19 17:18:35.140652628 -0700
+++ b/net/atm/lec.c	2009-03-19 17:19:19.500777355 -0700
@@ -502,7 +502,7 @@ static int lec_atm_send(struct atm_vcc *
 		priv->lane2_ops = NULL;
 		if (priv->lane_version > 1)
 			priv->lane2_ops = &lane2_ops;
-		if (dev->change_mtu(dev, mesg->content.config.mtu))
+		if (dev_set_mtu(dev, mesg->content.config.mtu))
 			printk("%s: change_mtu to %d failed\n", dev->name,
 			       mesg->content.config.mtu);
 		priv->is_proxy = mesg->content.config.is_proxy;
