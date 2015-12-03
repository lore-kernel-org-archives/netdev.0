From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 4/4] batman-adv: Act on NETDEV_*_TYPE_CHANGE events
Date: Thu,  3 Dec 2015 21:12:33 +0100
Message-ID: <1449173553-23784-5-git-send-email-andrew@lunn.ch>
References: <1449173553-23784-1-git-send-email-andrew@lunn.ch>
Cc: Krzysztof Halasa <khc@pm.waw.pl>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	netdev <netdev@vger.kernel.org>,
	"B.A.T.M.A.N" <b.a.t.m.a.n@lists.open-mesh.net>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53066 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753392AbbLCUMt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 15:12:49 -0500
In-Reply-To: <1449173553-23784-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A network interface can change type. It may change from a type which
batman does not support, e.g. hdlc, to one it does, e.g. hdlc-eth.
When an interface changes type, it sends two notifications. Handle
these notifications.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 net/batman-adv/hard-interface.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index f11345e163d7..c7f00eeb735b 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -708,7 +708,8 @@ static int batadv_hard_if_event(struct notifier_block *this,
 	}
 
 	hard_iface = batadv_hardif_get_by_netdev(net_dev);
-	if (!hard_iface && event == NETDEV_REGISTER)
+	if (!hard_iface && (event == NETDEV_REGISTER ||
+			    event == NETDEV_POST_TYPE_CHANGE))
 		hard_iface = batadv_hardif_add_interface(net_dev);
 
 	if (!hard_iface)
@@ -723,6 +724,7 @@ static int batadv_hard_if_event(struct notifier_block *this,
 		batadv_hardif_deactivate_interface(hard_iface);
 		break;
 	case NETDEV_UNREGISTER:
+	case NETDEV_PRE_TYPE_CHANGE:
 		list_del_rcu(&hard_iface->list);
 
 		batadv_hardif_remove_interface(hard_iface);
-- 
2.6.2
