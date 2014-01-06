From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH net-next] netfilter: nfnetlink_queue: fix compilation problem due missing header
Date: Mon,  6 Jan 2014 17:34:49 +0100
Message-ID: <1389026089-4917-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43424 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755650AbaAFQe7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jan 2014 11:34:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In 08c0cad ("netfilter: nfnetlink_queue: enable UID/GID socket info
retrieval"), the header that defines TCP_TIME_WAIT.

net/netfilter/nfnetlink_queue_core.c: In function 'nfqnl_put_sk_uidgid':
net/netfilter/nfnetlink_queue_core.c:304:35: error: 'TCP_TIME_WAIT' undeclared (first use in this function)
net/netfilter/nfnetlink_queue_core.c:304:35: note: each undeclared identifier is reported only once for each function it appears in make[3]: *** [net/netfilter/nfnetlink_queue_core.o] Error 1

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
Hi David,

Please, put this patch into net-next. It seems this compilation problem is
depending on the .config selections as I didn't reproducible when testing the
patches.

Thanks!

 net/netfilter/nfnetlink_queue_core.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index d3cf12b..ce20bd8 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -32,6 +32,7 @@
 #include <net/netfilter/nf_queue.h>
 #include <net/netns/generic.h>
 #include <net/netfilter/nfnetlink_queue.h>
+#include <net/tcp_states.h>
 
 #include <linux/atomic.h>
 
-- 
1.7.10.4
