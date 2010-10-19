From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] napi: unexport napi_reuse_skb
Date: Tue, 19 Oct 2010 10:12:10 -0700
Message-ID: <20101019101210.1bcff4af@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42172 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754293Ab0JSRMM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Oct 2010 13:12:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function napi_reuse_skb is only used inside core.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 include/linux/netdevice.h |    2 --
 net/core/dev.c            |    3 +--
 2 files changed, 1 insertion(+), 4 deletions(-)

--- a/include/linux/netdevice.h	2010-10-19 09:03:13.211106810 -0700
+++ b/include/linux/netdevice.h	2010-10-19 09:03:24.568216914 -0700
@@ -1745,8 +1745,6 @@ extern gro_result_t	napi_skb_finish(gro_
 extern gro_result_t	napi_gro_receive(struct napi_struct *napi,
 					 struct sk_buff *skb);
 extern void		napi_gro_flush(struct napi_struct *napi);
-extern void		napi_reuse_skb(struct napi_struct *napi,
-				       struct sk_buff *skb);
 extern struct sk_buff *	napi_get_frags(struct napi_struct *napi);
 extern gro_result_t	napi_frags_finish(struct napi_struct *napi,
 					  struct sk_buff *skb,
--- a/net/core/dev.c	2010-10-19 09:03:13.235109156 -0700
+++ b/net/core/dev.c	2010-10-19 09:03:58.839566666 -0700
@@ -3287,14 +3287,13 @@ gro_result_t napi_gro_receive(struct nap
 }
 EXPORT_SYMBOL(napi_gro_receive);
 
-void napi_reuse_skb(struct napi_struct *napi, struct sk_buff *skb)
+static void napi_reuse_skb(struct napi_struct *napi, struct sk_buff *skb)
 {
 	__skb_pull(skb, skb_headlen(skb));
 	skb_reserve(skb, NET_IP_ALIGN - skb_headroom(skb));
 
 	napi->skb = skb;
 }
-EXPORT_SYMBOL(napi_reuse_skb);
 
 struct sk_buff *napi_get_frags(struct napi_struct *napi)
 {
