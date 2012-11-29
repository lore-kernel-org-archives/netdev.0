From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH: net-next] core: make GRO methods static.
Date: Thu, 29 Nov 2012 09:55:25 +0200
Message-ID: <1354175725-23382-1-git-send-email-ramirose@gmail.com>
Cc: netdev@vger.kernel.org, Rami Rosen <ramirose@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:56195 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752989Ab2K2H4R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 02:56:17 -0500
Received: by mail-wi0-f178.google.com with SMTP id hm6so6095273wib.1
        for <netdev@vger.kernel.org>; Wed, 28 Nov 2012 23:56:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes three methods to be static and removes their
EXPORT_SYMBOLs in core/dev.c and their external declaration in
netdevice.h. The methods, dev_gro_receive(), napi_frags_finish() and
napi_skb_finish(), which are in the GRO rx path, are not used
outside core/dev.c.

Signed-off-by: Rami Rosen <ramirose@gmail.com>
---
 include/linux/netdevice.h | 6 ------
 net/core/dev.c            | 9 +++------
 2 files changed, 3 insertions(+), 12 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e9929ab..18c5dc9 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2153,16 +2153,10 @@ extern void dev_kfree_skb_any(struct sk_buff *skb);
 extern int		netif_rx(struct sk_buff *skb);
 extern int		netif_rx_ni(struct sk_buff *skb);
 extern int		netif_receive_skb(struct sk_buff *skb);
-extern gro_result_t	dev_gro_receive(struct napi_struct *napi,
-					struct sk_buff *skb);
-extern gro_result_t	napi_skb_finish(gro_result_t ret, struct sk_buff *skb);
 extern gro_result_t	napi_gro_receive(struct napi_struct *napi,
 					 struct sk_buff *skb);
 extern void		napi_gro_flush(struct napi_struct *napi, bool flush_old);
 extern struct sk_buff *	napi_get_frags(struct napi_struct *napi);
-extern gro_result_t	napi_frags_finish(struct napi_struct *napi,
-					  struct sk_buff *skb,
-					  gro_result_t ret);
 extern gro_result_t	napi_gro_frags(struct napi_struct *napi);
 
 static inline void napi_free_frags(struct napi_struct *napi)
diff --git a/net/core/dev.c b/net/core/dev.c
index 2a5f5586..2f94df2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3592,7 +3592,7 @@ void napi_gro_flush(struct napi_struct *napi, bool flush_old)
 }
 EXPORT_SYMBOL(napi_gro_flush);
 
-enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
+static enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 {
 	struct sk_buff **pp = NULL;
 	struct packet_offload *ptype;
@@ -3683,7 +3683,6 @@ normal:
 	ret = GRO_NORMAL;
 	goto pull;
 }
-EXPORT_SYMBOL(dev_gro_receive);
 
 static inline gro_result_t
 __napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
@@ -3710,7 +3709,7 @@ __napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 	return dev_gro_receive(napi, skb);
 }
 
-gro_result_t napi_skb_finish(gro_result_t ret, struct sk_buff *skb)
+static gro_result_t napi_skb_finish(gro_result_t ret, struct sk_buff *skb)
 {
 	switch (ret) {
 	case GRO_NORMAL:
@@ -3736,7 +3735,6 @@ gro_result_t napi_skb_finish(gro_result_t ret, struct sk_buff *skb)
 
 	return ret;
 }
-EXPORT_SYMBOL(napi_skb_finish);
 
 static void skb_gro_reset_offset(struct sk_buff *skb)
 {
@@ -3788,7 +3786,7 @@ struct sk_buff *napi_get_frags(struct napi_struct *napi)
 }
 EXPORT_SYMBOL(napi_get_frags);
 
-gro_result_t napi_frags_finish(struct napi_struct *napi, struct sk_buff *skb,
+static gro_result_t napi_frags_finish(struct napi_struct *napi, struct sk_buff *skb,
 			       gro_result_t ret)
 {
 	switch (ret) {
@@ -3813,7 +3811,6 @@ gro_result_t napi_frags_finish(struct napi_struct *napi, struct sk_buff *skb,
 
 	return ret;
 }
-EXPORT_SYMBOL(napi_frags_finish);
 
 static struct sk_buff *napi_frags_skb(struct napi_struct *napi)
 {
-- 
1.7.11.7
