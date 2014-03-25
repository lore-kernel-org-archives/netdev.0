From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 54/54] if_vlan: Call dev_kfree_skb_any instead of kfree_skb.
Date: Mon, 24 Mar 2014 23:05:40 -0700
Message-ID: <1395727540-12148-54-git-send-email-ebiederm@xmission.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:59073 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751754AbaCYGLe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 02:11:34 -0400
In-Reply-To: <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Replace kfree_skb with dev_kfree_skb_any in vlan_insert_tag as
vlan_insert_tag can be called from hard irq context (netpoll)
and from other contexts.

dev_kfree_skb_any is used as vlan_insert_tag only frees the skb if the
skb can not be modified to insert a tag, in which case vlan_insert_tag
drops the skb.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/linux/if_vlan.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index bbedfb56bd66..d3d2306f00bf 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -288,7 +288,7 @@ static inline struct sk_buff *vlan_insert_tag(struct sk_buff *skb,
 	struct vlan_ethhdr *veth;
 
 	if (skb_cow_head(skb, VLAN_HLEN) < 0) {
-		kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		return NULL;
 	}
 	veth = (struct vlan_ethhdr *)skb_push(skb, VLAN_HLEN);
-- 
1.7.10.4
