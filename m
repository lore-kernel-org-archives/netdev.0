From: Matt Mackall <mpm@selenic.com>
Subject: [PATCH 6/8] netpoll: pre-fill skb pool
Date: Thu, 11 Aug 2005 21:19:11 -0500
Message-ID: <7.502409567@selenic.com>
References: <6.502409567@selenic.com>
Cc: ak@suse.de, Jeff Moyer <jmoyer@redhat.com>, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org, mingo@elte.hu, john.ronciak@intel.com,
        rostedt@goodmis.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.com>, "David S. Miller" <davem@davemloft.net>
In-Reply-To: <6.502409567@selenic.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

we could do one thing (see the patch below): i think it would be useful 
to fill up the netlogging skb queue straight at initialization time.  
Especially if netpoll is used for dumping alone, the system might not be 
in a situation to fill up the queue at the point of crash, so better be 
a bit more prepared and keep the pipeline filled.

	Ingo

Signed-off-by: Ingo Molnar <mingo@elte.hu>

I've modified this to be called earlier - mpm

Signed-off-by: Matt Mackall <mpm@selenic.com>

Index: l/net/core/netpoll.c
===================================================================
--- l.orig/net/core/netpoll.c	2005-08-08 23:00:48.000000000 -0500
+++ l/net/core/netpoll.c	2005-08-11 01:50:31.000000000 -0500
@@ -724,6 +724,10 @@ int netpoll_setup(struct netpoll *np)
 		npinfo->rx_np = np;
 		spin_unlock_irqrestore(&npinfo->rx_lock, flags);
 	}
+
+	/* fill up the skb queue */
+	refill_skbs();
+
 	/* last thing to do is link it to the net device structure */
 	ndev->npinfo = npinfo;
 
