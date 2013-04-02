From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] bridge: remove a redundant synchronize_net()
Date: Tue, 02 Apr 2013 08:45:00 -0700
Message-ID: <1364917500.5113.176.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Veaceslav Falico <vfalico@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:53798 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932661Ab3DBPpE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 11:45:04 -0400
Received: by mail-pd0-f172.google.com with SMTP id 5so313042pdd.17
        for <netdev@vger.kernel.org>; Tue, 02 Apr 2013 08:45:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

commit 00cfec37484761 (net: add a synchronize_net() in
netdev_rx_handler_unregister())
allows us to remove the synchronized_net() call from del_nbp()

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Veaceslav Falico <vfalico@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
---
 net/bridge/br_if.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index ef1b914..f17fcb3 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -148,7 +148,6 @@ static void del_nbp(struct net_bridge_port *p)
 	dev->priv_flags &= ~IFF_BRIDGE_PORT;
 
 	netdev_rx_handler_unregister(dev);
-	synchronize_net();
 
 	netdev_upper_dev_unlink(dev, br->dev);
 
