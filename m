From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH net-next] net: kill useless net_*_ingress_queue() definitions when NET_CLS_ACT is unset
Date: Tue, 12 May 2015 20:28:07 +0200
Message-ID: <1431455287-4925-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, daniel@iogearbox.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45930 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932809AbbELSXd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 May 2015 14:23:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes 4577139b2dabf589 ("net: use jump label patching for ingress qdisc in
__netif_receive_skb_core").

The only client of this is sch_ingress and it depends on NET_CLS_ACT. So
there is no way these definition can be of any help.

Cc: Daniel Borkmann <daniel@iogearbox.net>
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
