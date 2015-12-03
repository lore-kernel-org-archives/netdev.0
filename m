From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 1/4] WAN: HDLC: Detach protocol before unregistering device
Date: Thu,  3 Dec 2015 21:12:30 +0100
Message-ID: <1449173553-23784-2-git-send-email-andrew@lunn.ch>
References: <1449173553-23784-1-git-send-email-andrew@lunn.ch>
Cc: Krzysztof Halasa <khc@pm.waw.pl>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	netdev <netdev@vger.kernel.org>,
	"B.A.T.M.A.N" <b.a.t.m.a.n@lists.open-mesh.net>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53086 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753582AbbLCUNN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 15:13:13 -0500
In-Reply-To: <1449173553-23784-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current code first unregisters the device, and then detaches the
protocol from it. This should be performed the other way around, since
the detach may try to use state which has been freed by the
unregister. Swap the order, so that we first detach and then remove the
netdev.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/wan/hdlc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wan/hdlc.c b/drivers/net/wan/hdlc.c
index 51f6cee8aab2..2a6595b4ae15 100644
--- a/drivers/net/wan/hdlc.c
+++ b/drivers/net/wan/hdlc.c
@@ -266,8 +266,8 @@ struct net_device *alloc_hdlcdev(void *priv)
 void unregister_hdlc_device(struct net_device *dev)
 {
 	rtnl_lock();
-	unregister_netdevice(dev);
 	detach_hdlc_protocol(dev);
+	unregister_netdevice(dev);
 	rtnl_unlock();
 }
 
-- 
2.6.2
