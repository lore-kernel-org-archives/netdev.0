From: Matt Mackall <mpm@selenic.com>
Subject: [PATCH 1/8] netpoll: rx_flags bugfix
Date: Thu, 11 Aug 2005 21:19:10 -0500
Message-ID: <2.502409567@selenic.com>
References: <1.502409567@selenic.com>
Cc: ak@suse.de, Jeff Moyer <jmoyer@redhat.com>, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org, mingo@elte.hu, john.ronciak@intel.com,
        rostedt@goodmis.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.com>, "David S. Miller" <davem@davemloft.net>
In-Reply-To: <1.502409567@selenic.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Initialize npinfo->rx_flags.  The way it stands now, this will have random
garbage, and so will incur a locking penalty even when an rx_hook isn't
registered and we are not active in the netpoll polling code.

Signed-off-by: Jeff Moyer <jmoyer@redhat.com>
Signed-off-by: Matt Mackall <mpm@selenic.com>

--- linux-2.6.12/net/core/netpoll.c.orig	2005-07-01 14:02:56.039174635 -0400
+++ linux-2.6.12/net/core/netpoll.c	2005-07-01 14:03:16.688739508 -0400
@@ -639,6 +639,7 @@ int netpoll_setup(struct netpoll *np)
 		if (!npinfo)
 			goto release;
 
+		npinfo->rx_flags = 0;
 		npinfo->rx_np = NULL;
 		npinfo->poll_lock = SPIN_LOCK_UNLOCKED;
 		npinfo->poll_owner = -1;
