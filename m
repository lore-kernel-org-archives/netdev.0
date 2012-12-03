From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] net: call notifiers for mtu change even if iface is not up
Date: Mon,  3 Dec 2012 12:16:32 +0100
Message-ID: <1354533392-9308-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, psimerda@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:45873 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754588Ab2LCLQj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2012 06:16:39 -0500
Received: by mail-ea0-f174.google.com with SMTP id e13so1100398eaa.19
        for <netdev@vger.kernel.org>; Mon, 03 Dec 2012 03:16:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do the same thing as in set mac. Call notifiers every time.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/core/dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 2f94df2..0685a72 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4971,7 +4971,7 @@ int dev_set_mtu(struct net_device *dev, int new_mtu)
 	else
 		dev->mtu = new_mtu;
 
-	if (!err && dev->flags & IFF_UP)
+	if (!err)
 		call_netdevice_notifiers(NETDEV_CHANGEMTU, dev);
 	return err;
 }
-- 
1.8.0
