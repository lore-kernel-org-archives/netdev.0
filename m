From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6] veth: remove unneeded ifname code from
 veth_newlink()
Date: Mon, 24 Jan 2011 16:45:46 +0100
Message-ID: <20110124154546.GA2689@psychotron.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, xemul@openvz.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62231 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752847Ab1AXPpu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jan 2011 10:45:50 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code is not needed because tb[IFLA_IFNAME] is already
processed in rtnl_newlink(). Remove this redundancy.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index cc83fa7..105d7f0 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -403,17 +403,6 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
 	if (tb[IFLA_ADDRESS] == NULL)
 		random_ether_addr(dev->dev_addr);
 
-	if (tb[IFLA_IFNAME])
-		nla_strlcpy(dev->name, tb[IFLA_IFNAME], IFNAMSIZ);
-	else
-		snprintf(dev->name, IFNAMSIZ, DRV_NAME "%%d");
-
-	if (strchr(dev->name, '%')) {
-		err = dev_alloc_name(dev, dev->name);
-		if (err < 0)
-			goto err_alloc_name;
-	}
-
 	err = register_netdevice(dev);
 	if (err < 0)
 		goto err_register_dev;
@@ -433,7 +422,6 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
 
 err_register_dev:
 	/* nothing to do */
-err_alloc_name:
 err_configure_peer:
 	unregister_netdevice(peer);
 	return err;
