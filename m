From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 10/13] vxlan: do not shadow flags variable
Date: Tue, 18 Aug 2015 22:33:19 +0200
Message-ID: <c89ec26c7a2684fdf642583f309877bd80ade35b.1439929916.git.jbenc@redhat.com>
References: <cover.1439929916.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46925 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753094AbbHRUdw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 16:33:52 -0400
In-Reply-To: <cover.1439929916.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 'flags' variable is already defined in the outer scope.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index d5ca1d7e0b81..d0caac63231c 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2025,7 +2025,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	} else {
 		struct dst_entry *ndst;
 		struct flowi6 fl6;
-		u32 flags;
+		u32 rt6i_flags;
 
 		memset(&fl6, 0, sizeof(fl6));
 		fl6.flowi6_oif = rdst ? rdst->remote_ifindex : 0;
@@ -2050,9 +2050,9 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		}
 
 		/* Bypass encapsulation if the destination is local */
-		flags = ((struct rt6_info *)ndst)->rt6i_flags;
-		if (flags & RTF_LOCAL &&
-		    !(flags & (RTCF_BROADCAST | RTCF_MULTICAST))) {
+		rt6i_flags = ((struct rt6_info *)ndst)->rt6i_flags;
+		if (rt6i_flags & RTF_LOCAL &&
+		    !(rt6i_flags & (RTCF_BROADCAST | RTCF_MULTICAST))) {
 			struct vxlan_dev *dst_vxlan;
 
 			dst_release(ndst);
-- 
1.8.3.1
