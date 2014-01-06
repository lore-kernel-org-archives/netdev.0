From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 03/12] netfilter: nfnetlink_queue: enable UID/GID
 socket info retrieval
Date: Mon, 06 Jan 2014 13:36:33 -0500 (EST)
Message-ID: <20140106.133633.333909371095279469.davem@davemloft.net>
References: <1388963586-5049-1-git-send-email-pablo@netfilter.org>
	<1388963586-5049-4-git-send-email-pablo@netfilter.org>
	<1389022353.12212.176.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, valentina.giusti@bmw-carit.de,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1389022353.12212.176.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 06 Jan 2014 07:32:33 -0800

> net/netfilter/nfnetlink_queue_core.c: In function 'nfqnl_put_sk_uidgid':
> net/netfilter/nfnetlink_queue_core.c:304:35: error: 'TCP_TIME_WAIT' undeclared (first use in this function)
> net/netfilter/nfnetlink_queue_core.c:304:35: note: each undeclared identifier is reported only once for each function it appears in
> make[3]: *** [net/netfilter/nfnetlink_queue_core.o] Error 1
> 
> Fix is obvious (#include <net/tcp_states.h>), but I have to run...

I just committed the following:

====================
[PATCH] netfilter: Fix build failure in nfnetlink_queue_core.c.

net/netfilter/nfnetlink_queue_core.c: In function 'nfqnl_put_sk_uidgid':
net/netfilter/nfnetlink_queue_core.c:304:35: error: 'TCP_TIME_WAIT' undeclared (first use in this function)
net/netfilter/nfnetlink_queue_core.c:304:35: note: each undeclared identifier is reported only once for each function it appears in
make[3]: *** [net/netfilter/nfnetlink_queue_core.o] Error 1

Just a missing include of net/tcp_states.h

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/netfilter/nfnetlink_queue_core.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index d3cf12b..b5e1f82 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -29,6 +29,7 @@
 #include <linux/netfilter/nfnetlink_queue.h>
 #include <linux/list.h>
 #include <net/sock.h>
+#include <net/tcp_states.h>
 #include <net/netfilter/nf_queue.h>
 #include <net/netns/generic.h>
 #include <net/netfilter/nfnetlink_queue.h>
-- 
1.7.11.7

