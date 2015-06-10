From: sfeldma@gmail.com
Subject: [PATCH net-next] switchdev: fix BUG when port driver doesn't support set attr op
Date: Wed, 10 Jun 2015 13:56:02 -0700
Message-ID: <1433969762-22406-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, bblanco@plumgrid.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35746 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965196AbbFJUy6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 16:54:58 -0400
Received: by pacyx8 with SMTP id yx8so41388941pac.2
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2015 13:54:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Fix a BUG() where CONFIG_NET_SWITCHDEV is set but the driver for a bridged
port does not support switchdec_port_attr_set op.  Don't BUG() if
-EOPNOTSUPP is returned.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Reported-by: Brenden Blanco <bblanco@plumgrid.com>
---
 net/switchdev/switchdev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index e008057..99bced4 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -103,7 +103,7 @@ static void switchdev_port_attr_set_work(struct work_struct *work)
 
 	rtnl_lock();
 	err = switchdev_port_attr_set(asw->dev, &asw->attr);
-	BUG_ON(err);
+	BUG_ON(err && err != -EOPNOTSUPP);
 	rtnl_unlock();
 
 	dev_put(asw->dev);
-- 
1.7.10.4
