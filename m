From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 3/5] veth: Allow to create peer link with given ifindex
Date: Mon, 06 Aug 2012 14:31:35 +0400
Message-ID: <501F9D07.9040104@parallels.com>
References: <501F9CAF.3030605@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:37147 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754125Ab2HFKcJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Aug 2012 06:32:09 -0400
In-Reply-To: <501F9CAF.3030605@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ifinfomsg is in there (thanks kaber@ for foreseeing this long time ago),
so take the given ifidex and register netdev with it.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 drivers/net/veth.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

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
-- 
1.7.6.5
