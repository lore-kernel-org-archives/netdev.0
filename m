From: Matt Mackall <mpm@selenic.com>
Subject: [PATCH] netpoll fix racy dev->flags usage
Date: Thu, 10 Mar 2005 15:22:46 -0800
Message-ID: <20050310232245.GR3120@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Dave Miller <davem@davemloft.net>, netdev@oss.sgi.com,
        Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Put ndev->flags usage under the lock. Spotted by Patrick McHardy.

Signed-off-by: Matt Mackall <mpm@selenic.com>

Index: np/net/core/netpoll.c
===================================================================
--- np.orig/net/core/netpoll.c	2005-03-10 17:02:03.000000000 -0600
+++ np/net/core/netpoll.c	2005-03-10 17:12:46.000000000 -0600
@@ -632,16 +632,13 @@ int netpoll_setup(struct netpoll *np)
 	}
 
 	if (!netif_running(ndev)) {
-		unsigned short oflags;
 		unsigned long atmost, atleast;
 
 		printk(KERN_INFO "%s: device %s not up yet, forcing it\n",
 		       np->name, np->dev_name);
 
-		oflags = ndev->flags;
-
 		rtnl_shlock();
-		if (dev_change_flags(ndev, oflags | IFF_UP) < 0) {
+		if (dev_change_flags(ndev, ndev->flags | IFF_UP) < 0) {
 			printk(KERN_ERR "%s: failed to open %s\n",
 			       np->name, np->dev_name);
 			rtnl_shunlock();

-- 
Mathematics is the supreme nostalgia of our time.
