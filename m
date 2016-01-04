From: Salam Noureddine <noureddine@arista.com>
Subject: [PATCH net-next 1/4] net: add event_list to struct net and provide utility functions
Date: Mon,  4 Jan 2016 15:10:53 -0800
Message-ID: <1451949056-15500-2-git-send-email-noureddine@arista.com>
References: <1451949056-15500-1-git-send-email-noureddine@arista.com>
Cc: Salam Noureddine <noureddine@arista.com>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mx.aristanetworks.com ([162.210.130.12]:59049 "EHLO
	prod-mx.aristanetworks.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753411AbcADXSD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 18:18:03 -0500
In-Reply-To: <1451949056-15500-1-git-send-email-noureddine@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Salam Noureddine <noureddine@arista.com>
---
 include/net/net_namespace.h | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 4089abc..4cf47de 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -58,6 +58,7 @@ struct net {
 	struct list_head	list;		/* list of network namespaces */
 	struct list_head	cleanup_list;	/* namespaces on death row */
 	struct list_head	exit_list;	/* Use only net_mutex */
+	struct list_head	event_list;     /* net_device notifier list */
 
 	struct user_namespace   *user_ns;	/* Owning user namespace */
 	spinlock_t		nsid_lock;
@@ -380,4 +381,25 @@ static inline void fnhe_genid_bump(struct net *net)
 	atomic_inc(&net->fnhe_genid);
 }
 
+#ifdef CONFIG_NET_NS
+static inline void net_add_event_list(struct list_head *head, struct net *net)
+{
+	if (!list_empty(&net->event_list))
+		list_add_tail(&net->event_list, head);
+}
+
+static inline void net_del_event_list(struct net *net)
+{
+	list_del_init(&net->event_list);
+}
+#else
+static inline void net_add_event_list(struct list_head *head, struct net *net)
+{
+}
+
+static inline void net_del_event_list(struct net *net)
+{
+}
+#endif
+
 #endif /* __NET_NET_NAMESPACE_H */
-- 
1.8.1.4
