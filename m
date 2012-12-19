From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/4] dummy: implement carrier change
Date: Wed, 19 Dec 2012 10:35:56 +0100
Message-ID: <1355909756-2389-5-git-send-email-jiri@resnulli.us>
References: <1355909756-2389-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, mirqus@gmail.com, shemminger@vyatta.com,
	greearb@candelatech.com, fbl@redhat.com, john.r.fastabend@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f180.google.com ([209.85.215.180]:39209 "EHLO
	mail-ea0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754205Ab2LSJgO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 04:36:14 -0500
Received: by mail-ea0-f180.google.com with SMTP id f13so684407eai.39
        for <netdev@vger.kernel.org>; Wed, 19 Dec 2012 01:36:12 -0800 (PST)
In-Reply-To: <1355909756-2389-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/dummy.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index c260af5..42aa54a 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -100,6 +100,15 @@ static void dummy_dev_uninit(struct net_device *dev)
 	free_percpu(dev->dstats);
 }
 
+static int dummy_change_carrier(struct net_device *dev, bool new_carrier)
+{
+	if (new_carrier)
+		netif_carrier_on(dev);
+	else
+		netif_carrier_off(dev);
+	return 0;
+}
+
 static const struct net_device_ops dummy_netdev_ops = {
 	.ndo_init		= dummy_dev_init,
 	.ndo_uninit		= dummy_dev_uninit,
@@ -108,6 +117,7 @@ static const struct net_device_ops dummy_netdev_ops = {
 	.ndo_set_rx_mode	= set_multicast_list,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_get_stats64	= dummy_get_stats64,
+	.ndo_change_carrier	= dummy_change_carrier,
 };
 
 static void dummy_setup(struct net_device *dev)
-- 
1.8.0
