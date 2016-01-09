From: =?UTF-8?q?J=CE=B5an=20Sacren?= <sakiwit@gmail.com>
Subject: [PATCH net-next 1/3] openvswitch: clean up unused function
Date: Sat,  9 Jan 2016 16:07:09 -0700
Message-ID: <1452380831-11258-2-git-send-email-sakiwit@gmail.com>
Cc: Pravin Shelar <pshelar@nicira.com>, dev@openvswitch.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36212 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756247AbcAIXHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jan 2016 18:07:51 -0500
Received: by mail-pf0-f194.google.com with SMTP id n128so2158770pfn.3
        for <netdev@vger.kernel.org>; Sat, 09 Jan 2016 15:07:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Sacren <sakiwit@gmail.com>

commit 6b001e682e90 ("openvswitch: Use Geneve device.")

The commit above deleted the only call site of ovs_tunnel_route_lookup()
and now that function is not used any more. So let's delete the function
definition as well.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
---
 net/openvswitch/vport.h | 20 --------------------
 1 file changed, 20 deletions(-)

diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index 8ea3a96980ac..f00bb153ad13 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -204,26 +204,6 @@ int __ovs_vport_ops_register(struct vport_ops *ops);
 	})
 
 void ovs_vport_ops_unregister(struct vport_ops *ops);
-
-static inline struct rtable *ovs_tunnel_route_lookup(struct net *net,
-						     const struct ip_tunnel_key *key,
-						     u32 mark,
-						     struct flowi4 *fl,
-						     u8 protocol)
-{
-	struct rtable *rt;
-
-	memset(fl, 0, sizeof(*fl));
-	fl->daddr = key->u.ipv4.dst;
-	fl->saddr = key->u.ipv4.src;
-	fl->flowi4_tos = RT_TOS(key->tos);
-	fl->flowi4_mark = mark;
-	fl->flowi4_proto = protocol;
-
-	rt = ip_route_output_key(net, fl);
-	return rt;
-}
-
 void ovs_vport_send(struct vport *vport, struct sk_buff *skb);
 
 #endif /* vport.h */
