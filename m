From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH] ovs: queue_userspace_packet: bail out if nla_nest_start returns NULL
Date: Wed,  3 Jul 2013 10:49:57 +0200
Message-ID: <1372841397-10873-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26469 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932071Ab3GCIuM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jul 2013 04:50:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The return value of nla_nest_start() is not checked, and can be NULL,
which is then being dereferenced in nla_nest_end(). Add a check to
prevent such situations.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 On top of "net-next" tree.

 net/openvswitch/datapath.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index d12d6b8..51a3c66 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -427,6 +427,10 @@ static int queue_userspace_packet(struct net *net, int dp_ifindex,
 	upcall->dp_ifindex = dp_ifindex;
 
 	nla = nla_nest_start(user_skb, OVS_PACKET_ATTR_KEY);
+	if (unlikely(!nla)) {
+		err = -ENOMEM;
+		goto out;
+	}
 	ovs_flow_to_nlattrs(upcall_info->key, user_skb);
 	nla_nest_end(user_skb, nla);
 
-- 
1.7.11.7
