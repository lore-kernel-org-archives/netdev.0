From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/2 net-next] net: kill useless net_*_ingress_queue() definitions when NET_CLS_ACT is unset
Date: Sun, 10 May 2015 18:59:29 +0200
Message-ID: <1431277170-4618-2-git-send-email-pablo@netfilter.org>
References: <1431277170-4618-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, ast@plumgrid.com, jhs@mojatatu.com,
	daniel@iogearbox.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40244 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751661AbbEJQyu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 May 2015 12:54:50 -0400
In-Reply-To: <1431277170-4618-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes 4577139 ("net: use jump label patching for ingress qdisc in
__netif_receive_skb_core").

The only client of this is sch_ingress and it depends on NET_CLS_ACT. So
there is no way these definition can be of any use at all.

Fixes: 4577139 ("net: use jump label patching for ingress qdisc in __netif_receive_skb_core")
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/rtnetlink.h |    8 --------
 1 file changed, 8 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 7b8e260..bd29ab4 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -82,14 +82,6 @@ struct netdev_queue *dev_ingress_queue_create(struct net_device *dev);
 #ifdef CONFIG_NET_CLS_ACT
 void net_inc_ingress_queue(void);
 void net_dec_ingress_queue(void);
-#else
-static inline void net_inc_ingress_queue(void)
-{
-}
-
-static inline void net_dec_ingress_queue(void)
-{
-}
 #endif
 
 extern void rtnetlink_init(void);
-- 
1.7.10.4
