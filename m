From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 3/5 (resend)] veth: Allow to create peer link with given ifindex
Date: Tue, 07 Aug 2012 15:02:03 +0400
Message-ID: <5020F5AB.3090101@parallels.com>
References: <501FD0F2.4040609@parallels.com> <501FD14F.2040209@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:21288 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753805Ab2HGLCJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Aug 2012 07:02:09 -0400
In-Reply-To: <501FD14F.2040209@parallels.com>
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
