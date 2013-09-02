From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next] vxlan: fix flowi6_proto value
Date: Mon,  2 Sep 2013 10:06:51 +0800
Message-ID: <1378087613-15279-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41633 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756338Ab3IBCHA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Sep 2013 22:07:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

It should be IPPROTO_UDP.

Signed-off-by: Cong Wang <amwang@redhat.com>
---
 drivers/net/vxlan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 3ffb22d..0fcf3f7 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1671,7 +1671,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		fl6.flowi6_oif = rdst->remote_ifindex;
 		fl6.daddr = dst->sin6.sin6_addr;
 		fl6.saddr = vxlan->saddr.sin6.sin6_addr;
-		fl6.flowi6_proto = skb->protocol;
+		fl6.flowi6_proto = IPPROTO_UDP;
 
 		if (ipv6_stub->ipv6_dst_lookup(sk, &ndst, &fl6)) {
 			netdev_dbg(dev, "no route to %pI6\n",
-- 
1.7.7.6
