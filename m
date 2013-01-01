From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/7] net: add address assign type "SET"
Date: Tue,  1 Jan 2013 14:30:16 +0100
Message-ID: <1357047019-1037-5-git-send-email-jiri@resnulli.us>
References: <1357047019-1037-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	sassmann@redhat.com, kaber@trash.net, richard@nod.at
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f181.google.com ([209.85.215.181]:35300 "EHLO
	mail-ea0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752323Ab3AANai (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jan 2013 08:30:38 -0500
Received: by mail-ea0-f181.google.com with SMTP id k14so5312576eaa.26
        for <netdev@vger.kernel.org>; Tue, 01 Jan 2013 05:30:37 -0800 (PST)
In-Reply-To: <1357047019-1037-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the way to indicate that mac address of a device has been set by
dev_set_mac_address()

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/netdevice.h | 2 ++
 net/core/dev.c            | 1 +
 2 files changed, 3 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 6835b58..c5031a4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -64,6 +64,8 @@ struct wireless_dev;
 #define NET_ADDR_PERM		0	/* address is permanent (default) */
 #define NET_ADDR_RANDOM		1	/* address is generated randomly */
 #define NET_ADDR_STOLEN		2	/* address is stolen from other device */
+#define NET_ADDR_SET		3	/* address is set using
+					 * dev_set_mac_address() */
 
 /* Backlog congestion levels */
 #define NET_RX_SUCCESS		0	/* keep 'em coming, baby */
diff --git a/net/core/dev.c b/net/core/dev.c
index c85e32b..bddb2f2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5022,6 +5022,7 @@ int dev_set_mac_address(struct net_device *dev, struct sockaddr *sa)
 	err = ops->ndo_set_mac_address(dev, sa);
 	if (err)
 		return err;
+	dev->addr_assign_type = NET_ADDR_SET;
 	call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
 	add_device_randomness(dev->dev_addr, dev->addr_len);
 	return 0;
-- 
1.8.0
