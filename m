From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/7] net: call add_device_randomness() only after successful mac change
Date: Tue,  1 Jan 2013 14:30:14 +0100
Message-ID: <1357047019-1037-3-git-send-email-jiri@resnulli.us>
References: <1357047019-1037-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	sassmann@redhat.com, kaber@trash.net, richard@nod.at
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f51.google.com ([74.125.83.51]:61216 "EHLO
	mail-ee0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752239Ab3AANab (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jan 2013 08:30:31 -0500
Received: by mail-ee0-f51.google.com with SMTP id d4so6398619eek.10
        for <netdev@vger.kernel.org>; Tue, 01 Jan 2013 05:30:30 -0800 (PST)
In-Reply-To: <1357047019-1037-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/core/dev.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 21c5b97..c85e32b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5020,10 +5020,11 @@ int dev_set_mac_address(struct net_device *dev, struct sockaddr *sa)
 	if (!netif_device_present(dev))
 		return -ENODEV;
 	err = ops->ndo_set_mac_address(dev, sa);
-	if (!err)
-		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
+	if (err)
+		return err;
+	call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
 	add_device_randomness(dev->dev_addr, dev->addr_len);
-	return err;
+	return 0;
 }
 EXPORT_SYMBOL(dev_set_mac_address);
 
-- 
1.8.0
