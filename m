From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next v10 10/11] vxlan: respect scope_id for ll addr
Date: Wed, 28 Aug 2013 13:22:58 +0800
Message-ID: <1377667379-2315-11-git-send-email-amwang@redhat.com>
References: <1377667379-2315-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>,
	David Stevens <dlstevens@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32476 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752669Ab3H1FZ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 01:25:28 -0400
In-Reply-To: <1377667379-2315-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

As pointed out by David, we should take care of scope id for ll
addr, and use it for route lookup.

Cc: David S. Miller <davem@davemloft.net>
Cc: David Stevens <dlstevens@us.ibm.com>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 drivers/net/vxlan.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 33a2c6e..a06355d 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1662,6 +1662,12 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		struct flowi6 fl6;
 		u32 flags;
 
+		if (ipv6_addr_type(&dst->sin6.sin6_addr) & IPV6_ADDR_LINKLOCAL) {
+			dst->sin6.sin6_scope_id = ipv6_iface_scope_id(&dst->sin6.sin6_addr,
+								rdst->remote_ifindex);
+			rdst->remote_ifindex = dst->sin6.sin6_scope_id;
+		}
+
 		memset(&fl6, 0, sizeof(fl6));
 		fl6.flowi6_oif = rdst->remote_ifindex;
 		fl6.daddr = dst->sin6.sin6_addr;
-- 
1.7.7.6
