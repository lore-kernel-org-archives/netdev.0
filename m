From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/6] net: honour netif_set_real_num_tx_queues() retval
Date: Fri, 20 Jul 2012 14:28:46 +0200
Message-ID: <1342787331-1866-2-git-send-email-jiri@resnulli.us>
References: <1342787331-1866-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, shemminger@vyatta.com,
	fubar@us.ibm.com, andy@greyhouse.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:39376 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752783Ab2GTM3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 08:29:00 -0400
Received: by wgbdr13 with SMTP id dr13so3588259wgb.1
        for <netdev@vger.kernel.org>; Fri, 20 Jul 2012 05:28:59 -0700 (PDT)
In-Reply-To: <1342787331-1866-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In netif_copy_real_num_queues() the return value of
netif_set_real_num_tx_queues() should be checked.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/netdevice.h |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ab0251d..eb06e58 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2110,7 +2110,12 @@ static inline int netif_set_real_num_rx_queues(struct net_device *dev,
 static inline int netif_copy_real_num_queues(struct net_device *to_dev,
 					     const struct net_device *from_dev)
 {
-	netif_set_real_num_tx_queues(to_dev, from_dev->real_num_tx_queues);
+	int err;
+
+	err = netif_set_real_num_tx_queues(to_dev,
+					   from_dev->real_num_tx_queues);
+	if (err)
+		return err;
 #ifdef CONFIG_RPS
 	return netif_set_real_num_rx_queues(to_dev,
 					    from_dev->real_num_rx_queues);
-- 
1.7.10.4
