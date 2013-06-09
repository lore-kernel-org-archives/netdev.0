From: Hong Zhiguo <honkiko@gmail.com>
Subject: [PATCH net-next] veth: remove redundant call of dev_alloc_name
Date: Sun,  9 Jun 2013 20:15:20 +0800
Message-ID: <1370780120-8495-1-git-send-email-honkiko@gmail.com>
Cc: davem@davemloft.net, stephen@networkplumber.org, xemul@openvz.org,
	ebiederm@xmission.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:42136 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753553Ab3FIMPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jun 2013 08:15:33 -0400
Received: by mail-pd0-f170.google.com with SMTP id x11so711627pdj.15
        for <netdev@vger.kernel.org>; Sun, 09 Jun 2013 05:15:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

it's called in the following register_netdevice. No need to call it
here.
Tested with "ip link add type veth" and "ip link add xxx%d type veth".

Signed-off-by: Hong Zhiguo <honkiko@gmail.com>
---
 drivers/net/veth.c |    7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 177f911..da86652 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -379,12 +379,6 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
 	else
 		snprintf(dev->name, IFNAMSIZ, DRV_NAME "%%d");
 
-	if (strchr(dev->name, '%')) {
-		err = dev_alloc_name(dev, dev->name);
-		if (err < 0)
-			goto err_alloc_name;
-	}
-
 	err = register_netdevice(dev);
 	if (err < 0)
 		goto err_register_dev;
@@ -404,7 +398,6 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
 
 err_register_dev:
 	/* nothing to do */
-err_alloc_name:
 err_configure_peer:
 	unregister_netdevice(peer);
 	return err;
-- 
1.7.10.4
