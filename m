From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: sched: fix compile warning in cls_u32
Date: Mon, 22 Sep 2014 13:42:53 -0700
Message-ID: <1411418573.26859.157.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:46267 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753879AbaIVUmy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 16:42:54 -0400
Received: by mail-pa0-f52.google.com with SMTP id hz1so5213994pad.11
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2014 13:42:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

$ grep CONFIG_CLS_U32_MARK .config
# CONFIG_CLS_U32_MARK is not set

net/sched/cls_u32.c: In function 'u32_change':
net/sched/cls_u32.c:852:1: warning: label 'errout' defined but not used
[-Wunused-label]

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/cls_u32.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index e3fb5308d44a..ef97a646ee94 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -847,9 +847,9 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 
 #ifdef CONFIG_CLS_U32_MARK
 	free_percpu(n->pcpu_success);
+errout:
 #endif
 
-errout:
 #ifdef CONFIG_CLS_U32_PERF
 	free_percpu(n->pf);
 #endif
