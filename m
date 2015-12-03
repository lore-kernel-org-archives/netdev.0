From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 3/4] ipv6: Only act upon NETDEV_*_TYPE_CHANGE if we have ipv6 addresses
Date: Thu,  3 Dec 2015 21:12:32 +0100
Message-ID: <1449173553-23784-4-git-send-email-andrew@lunn.ch>
References: <1449173553-23784-1-git-send-email-andrew@lunn.ch>
Cc: Krzysztof Halasa <khc@pm.waw.pl>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	netdev <netdev@vger.kernel.org>,
	"B.A.T.M.A.N" <b.a.t.m.a.n@lists.open-mesh.net>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53079 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753574AbbLCUNG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 15:13:06 -0500
In-Reply-To: <1449173553-23784-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An interface changing type may not have IPv6 addresses. Don't
call the address configuration type change in this case.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 net/ipv6/addrconf.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index d84742f003a9..d2ab0f89a8d8 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3287,7 +3287,8 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 
 	case NETDEV_PRE_TYPE_CHANGE:
 	case NETDEV_POST_TYPE_CHANGE:
-		addrconf_type_change(dev, event);
+		if (idev)
+			addrconf_type_change(dev, event);
 		break;
 	}
 
-- 
2.6.2
