From: igorm@etf.rs
Subject: [PATCH 1/4 net-next] net:core: use IS_ENABLED
Date: Mon, 12 Dec 2011 04:58:22 -0800
Message-ID: <1323694705-2793-1-git-send-email-igorm@etf.rs>
References: <igorm@etf.rs>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, =?UTF-8?q?Igor=20Maravi=C4=87?= <igorm@etf.rs>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.etf.rs ([147.91.14.169]:47683 "EHLO mx1.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753012Ab1LLM6z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 07:58:55 -0500
In-Reply-To: <igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Igor Maravi=C4=87 <igorm@etf.rs>

Use IS_ENABLED(CONFIG_FOO)
instead of defined(CONFIG_FOO) || defined (CONFIG_FOO_MODULE)

Signed-off-by: Igor Maravi=C4=87 <igorm@etf.rs>
---
 net/core/secure_seq.c |    2 +-
 net/core/skbuff.c     |    7 +++----
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/core/secure_seq.c b/net/core/secure_seq.c
index 9fbca46..6fd4460 100644
--- a/net/core/secure_seq.c
+++ b/net/core/secure_seq.c
@@ -134,7 +134,7 @@ u32 secure_ipv4_port_ephemeral(__be32 saddr, __be32=
 daddr, __be16 dport)
 EXPORT_SYMBOL_GPL(secure_ipv4_port_ephemeral);
 #endif
=20
-#if defined(CONFIG_IP_DCCP) || defined(CONFIG_IP_DCCP_MODULE)
+#if IS_ENABLED(CONFIG_IP_DCCP)
 u64 secure_dccp_sequence_number(__be32 saddr, __be32 daddr,
 				__be16 sport, __be16 dport)
 {
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index fd36462..da0c97f 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -452,7 +452,7 @@ static void skb_release_head_state(struct sk_buff *=
skb)
 		WARN_ON(in_irq());
 		skb->destructor(skb);
 	}
-#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE=
)
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
 	nf_conntrack_put(skb->nfct);
 #endif
 #ifdef NET_SKBUFF_NF_DEFRAG_NEEDED
@@ -602,15 +602,14 @@ static void __copy_skb_header(struct sk_buff *new=
, const struct sk_buff *old)
 	new->ip_summed		=3D old->ip_summed;
 	skb_copy_queue_mapping(new, old);
 	new->priority		=3D old->priority;
-#if defined(CONFIG_IP_VS) || defined(CONFIG_IP_VS_MODULE)
+#if IS_ENABLED(CONFIG_IP_VS)
 	new->ipvs_property	=3D old->ipvs_property;
 #endif
 	new->protocol		=3D old->protocol;
 	new->mark		=3D old->mark;
 	new->skb_iif		=3D old->skb_iif;
 	__nf_copy(new, old);
-#if defined(CONFIG_NETFILTER_XT_TARGET_TRACE) || \
-    defined(CONFIG_NETFILTER_XT_TARGET_TRACE_MODULE)
+#if IS_ENABLED(CONFIG_NETFILTER_XT_TARGET_TRACE)
 	new->nf_trace		=3D old->nf_trace;
 #endif
 #ifdef CONFIG_NET_SCHED
--=20
1.7.5.4
