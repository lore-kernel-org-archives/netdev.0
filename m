From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH v2 net-next 10/13] vxlan: do not shadow flags variable
Date: Wed, 19 Aug 2015 12:10:00 +0200
Message-ID: <90a1de02af35b7162dafc47049c8da11f921ce3c.1439978875.git.jbenc@redhat.com>
References: <cover.1439978875.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46946 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753744AbbHSKLn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 06:11:43 -0400
In-Reply-To: <cover.1439978875.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 'flags' variable is already defined in the outer scope.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 070149f77072..2c1abf95c17d 100644
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
