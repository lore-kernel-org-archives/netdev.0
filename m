From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net-next] l2tp: remove useless device duplication test in
 l2tp_eth_create()
Date: Wed, 26 Apr 2017 11:54:47 +0200
Message-ID: <95d793ebf07f9ec7aefa496ed2b1432aa9dc8aa8.1493199657.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:50536 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1435356AbdDZJyv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 05:54:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's no need to verify that cfg->ifname is unique at this point.
register_netdev() will return -EEXIST if asked to create a device with
a name that's alrealy in use.

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 net/l2tp/l2tp_eth.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index 59aba8aeac03..8b21af7321b9 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -280,12 +280,6 @@ static int l2tp_eth_create(struct net *net, u32 tunnel_id, u32 session_id, u32 p
 	}
 
 	if (cfg->ifname) {
-		dev = dev_get_by_name(net, cfg->ifname);
-		if (dev) {
-			dev_put(dev);
-			rc = -EEXIST;
-			goto out;
-		}
 		strlcpy(name, cfg->ifname, IFNAMSIZ);
 		name_assign_type = NET_NAME_USER;
 	} else {
-- 
2.11.0
