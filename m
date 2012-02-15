From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] veth: Enforce minimum size of VETH_INFO_PEER
Date: Wed, 15 Feb 2012 15:09:46 +0100
Message-ID: <1329314986-20320-1-git-send-email-tgraf@suug.ch>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29093 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756133Ab2BOOJ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Feb 2012 09:09:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VETH_INFO_PEER carries struct ifinfomsg plus optional IFLA
attributes. A minimal size of sizeof(struct ifinfomsg) must be
enforced or we may risk accessing that struct beyond the limits
of the netlink message.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 drivers/net/veth.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 49f4667..4a34028 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -422,7 +422,9 @@ static void veth_dellink(struct net_device *dev, struct list_head *head)
 	unregister_netdevice_queue(peer, head);
 }
 
-static const struct nla_policy veth_policy[VETH_INFO_MAX + 1];
+static const struct nla_policy veth_policy[VETH_INFO_MAX + 1] = {
+	[VETH_INFO_PEER]	= { .len = sizeof(struct ifinfomsg) },
+};
 
 static struct rtnl_link_ops veth_link_ops = {
 	.kind		= DRV_NAME,
-- 
1.7.7.6
