From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: struct napi_struct fields reordering
Date: Wed, 26 Sep 2012 19:07:47 +0200
Message-ID: <1348679267.5093.419.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:49814 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754031Ab2IZRHw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2012 13:07:52 -0400
Received: by bkcjk13 with SMTP id jk13so475274bkc.19
        for <netdev@vger.kernel.org>; Wed, 26 Sep 2012 10:07:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Remove two holes on 64bit arches, and put dev_list at the end of
napi_struct since its not used in fast path.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/netdevice.h |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 6c131f0..dd320bb 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -338,18 +338,16 @@ struct napi_struct {
 
 	unsigned long		state;
 	int			weight;
+	unsigned int		gro_count;
 	int			(*poll)(struct napi_struct *, int);
 #ifdef CONFIG_NETPOLL
 	spinlock_t		poll_lock;
 	int			poll_owner;
 #endif
-
-	unsigned int		gro_count;
-
 	struct net_device	*dev;
-	struct list_head	dev_list;
 	struct sk_buff		*gro_list;
 	struct sk_buff		*skb;
+	struct list_head	dev_list;
 };
 
 enum {
