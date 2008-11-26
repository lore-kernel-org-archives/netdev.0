From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] net: hp-plus uses eip_poll
Date: Tue, 25 Nov 2008 19:54:00 -0800
Message-ID: <20081125195400.dbb46066.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jgarzik <jgarzik@pobox.com>,
	alan@lxorguk.ukuu.org.uk
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:41026 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752773AbYKZDyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 22:54:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

hp-plus uses 8390p.c, so it should use eip_poll(), not ei_poll().

drivers/built-in.o: In function `hpp_probe1':
hp-plus.c:(.init.text+0x9cbd): undefined reference to `ei_poll'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/hp-plus.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-next-20081125.orig/drivers/net/hp-plus.c
+++ linux-next-20081125/drivers/net/hp-plus.c
@@ -229,7 +229,7 @@ static int __init hpp_probe1(struct net_
 	dev->open = &hpp_open;
 	dev->stop = &hpp_close;
 #ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = ei_poll;
+	dev->poll_controller = eip_poll;
 #endif
 
 	ei_status.name = name;
