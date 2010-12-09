From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] netfilter: don't need to initialize instance_table
Date: Thu, 9 Dec 2010 15:03:08 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1012091501270.21049@obet.zrqbmnf.qr>
References: <1291889421-10794-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1291889421-10794-1-git-send-email-xiaosuo@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 2010-12-09 11:10, Changli Gao wrote:

>Since instance_table is a static array, and has been zeroed already, we
>don't need to take CPU cycles to initialize it.
>
>Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>---
> net/netfilter/nfnetlink_queue.c |    3 ---
> 1 file changed, 3 deletions(-)
>diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
>index 68e67d1..9c80d6f 100644
>--- a/net/netfilter/nfnetlink_queue.c
>+++ b/net/netfilter/nfnetlink_queue.c
>@@ -893,9 +893,6 @@ static int __init nfnetlink_queue_init(void)
> {
> 	int i, status = -ENOMEM;
> 
>-	for (i = 0; i < INSTANCE_BUCKETS; i++)
>-		INIT_HLIST_HEAD(&instance_table[i]);
>-
> 	netlink_register_notifier(&nfqnl_rtnl_notifier);
> 	status = nfnetlink_subsys_register(&nfqnl_subsys);
> 	if (status < 0) {

This is here for correctness and documentation. If the hlist 
implementation changed, one would have a hard time figuring out the 
callsites which then need to add the initialization back.
