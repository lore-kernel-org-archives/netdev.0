From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/7] netfilter: bridge: fix CONFIG_NF_DEFRAG_IPV4/6 related warnings/errors
Date: Wed,  8 Jul 2015 11:48:15 +0200
Message-ID: <1436348900-13130-3-git-send-email-pablo@netfilter.org>
References: <1436348900-13130-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51693 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933849AbbGHJnN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jul 2015 05:43:13 -0400
In-Reply-To: <1436348900-13130-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bernhard Thaler <bernhard.thaler@wvnet.at>

br_nf_ip_fragment() is not needed when neither CONFIG_NF_DEFRAG_IPV4 nor
CONFIG_NF_DEFRAG_IPV6 is set.

struct brnf_frag_data must be available if either CONFIG_NF_DEFRAG_IPV4
or CONFIG_NF_DEFRAG_IPV6 is set.

Fixes: efb6de9b4ba0 ("netfilter: bridge: forward IPv6 fragmented packets")
Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Bernhard Thaler <bernhard.thaler@wvnet.at>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/br_netfilter_hooks.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
index d89f4fa..8a394bd 100644
--- a/net/bridge/br_netfilter_hooks.c
+++ b/net/bridge/br_netfilter_hooks.c
@@ -111,7 +111,7 @@ static inline __be16 pppoe_proto(const struct sk_buff *skb)
 /* largest possible L2 header, see br_nf_dev_queue_xmit() */
 #define NF_BRIDGE_MAX_MAC_HEADER_LENGTH (PPPOE_SES_HLEN + ETH_HLEN)
 
-#if IS_ENABLED(CONFIG_NF_DEFRAG_IPV4)
+#if IS_ENABLED(CONFIG_NF_DEFRAG_IPV4) || IS_ENABLED(CONFIG_NF_DEFRAG_IPV6)
 struct brnf_frag_data {
 	char mac[NF_BRIDGE_MAX_MAC_HEADER_LENGTH];
 	u8 encap_size;
@@ -694,6 +694,7 @@ static int br_nf_push_frag_xmit(struct sock *sk, struct sk_buff *skb)
 }
 #endif
 
+#if IS_ENABLED(CONFIG_NF_DEFRAG_IPV4)
 static int br_nf_ip_fragment(struct sock *sk, struct sk_buff *skb,
 			     int (*output)(struct sock *, struct sk_buff *))
 {
@@ -712,6 +713,7 @@ static int br_nf_ip_fragment(struct sock *sk, struct sk_buff *skb,
 
 	return ip_do_fragment(sk, skb, output);
 }
+#endif
 
 static unsigned int nf_bridge_mtu_reduction(const struct sk_buff *skb)
 {
-- 
1.7.10.4
