From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: l2tp_eth: fix kernel panic on rmmod l2tp_eth
Date: Thu, 07 Jun 2012 12:07:20 +0200
Message-ID: <1339063640.26966.113.camel@edumazet-glaptop>
References: <61a2ca9cc47a9a9a1c8a36738090dbf9@visp.net.lb>
	 <1339060346.26966.106.camel@edumazet-glaptop>
	 <66de011eba423f7b5eeb3c57e8430c5a@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, James Chapman <jchapman@katalix.com>
To: Denys Fedoryshchenko <denys@visp.net.lb>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:56857 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752849Ab2FGKH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 06:07:29 -0400
Received: by eaak11 with SMTP id k11so147957eaa.19
        for <netdev@vger.kernel.org>; Thu, 07 Jun 2012 03:07:28 -0700 (PDT)
In-Reply-To: <66de011eba423f7b5eeb3c57e8430c5a@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

We must prevent module unloading if some devices are still attached to
l2tp_eth driver.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Denys Fedoryshchenko <denys@visp.net.lb>
Tested-by: Denys Fedoryshchenko <denys@visp.net.lb>
Cc: James Chapman <jchapman@katalix.com>
---
 net/l2tp/l2tp_eth.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index 443591d..185f12f 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -162,6 +162,7 @@ static void l2tp_eth_delete(struct l2tp_session *session)
 		if (dev) {
 			unregister_netdev(dev);
 			spriv->dev = NULL;
+			module_put(THIS_MODULE);
 		}
 	}
 }
@@ -249,6 +250,7 @@ static int l2tp_eth_create(struct net *net, u32 tunnel_id, u32 session_id, u32 p
 	if (rc < 0)
 		goto out_del_dev;
 
+	__module_get(THIS_MODULE);
 	/* Must be done after register_netdev() */
 	strlcpy(session->ifname, dev->name, IFNAMSIZ);
 
