From: Benjamin Li <ben@wenli.org>
Subject: [PATCH] [VLAN] vlan_dev: Initialize dev pointer only when it is being used
Date: Wed, 30 Jan 2008 22:55:24 -0800
Message-ID: <1201762524-28403-1-git-send-email-ben@wenli.org>
Cc: Benjamin Li <ben@wenli.org>
To: kaber@trash.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.vhostnix.com ([12.168.32.21]:42927 "HELO
	server.vhostnix.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with SMTP id S1753209AbYAaHCJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 02:02:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Benjamin Li <ben@wenli.org>
---
 net/8021q/vlan_dev.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 8059fa4..2fa5d68 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -49,7 +49,7 @@
  */
 static int vlan_dev_rebuild_header(struct sk_buff *skb)
 {
-	struct net_device *dev = skb->dev;
+	struct net_device *dev;
 	struct vlan_ethhdr *veth = (struct vlan_ethhdr *)(skb->data);
 
 	switch (veth->h_vlan_encapsulated_proto) {
@@ -60,6 +60,7 @@ static int vlan_dev_rebuild_header(struct sk_buff *skb)
 		return arp_find(veth->h_dest, skb);
 #endif
 	default:
+		dev = skb->dev;
 		pr_debug("%s: unable to resolve type %X addresses.\n",
 			 dev->name, ntohs(veth->h_vlan_encapsulated_proto));
 
-- 
1.5.3.8

