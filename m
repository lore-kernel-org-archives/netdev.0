From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 2/2] veth: Allow to create peer link with given ifindex
Date: Mon, 30 Jul 2012 08:36:57 +0400
Message-ID: <50160F69.7020205@parallels.com>
References: <50160EEF.6050406@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:3975 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751735Ab2G3EhC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jul 2012 00:37:02 -0400
In-Reply-To: <50160EEF.6050406@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ifinfomsg is in there (thanks kaber@ for foreseeing this long time ago),
so take the given ifidex and register netdev with it.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 5852361..496c026 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -348,6 +348,9 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
 	if (tbp[IFLA_ADDRESS] == NULL)
 		eth_hw_addr_random(peer);
 
+	if (ifmp)
+		peer->ifindex = ifmp->ifi_index;
+
 	err = register_netdevice(peer);
 	put_net(net);
 	net = NULL;
