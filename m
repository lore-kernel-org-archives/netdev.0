From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] net: core: remove unnecessary code
Date: Wed, 3 May 2017 12:17:30 -0500
Message-ID: <20170503171730.GA14179@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vager.kernel.org, linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: "David S. Miller" <davem@davemloft.net>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The name of an array used by itself will always return the array's address.
So this test will always evaluate as true.

Addresses-Coverity-ID: 115325
Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 net/core/netpoll.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 9424673..27ce3b1 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -657,13 +657,13 @@ int netpoll_setup(struct netpoll *np)
 {
 	struct net_device *ndev = NULL;
 	struct in_device *in_dev;
+	struct net *net;
 	int err;
 
 	rtnl_lock();
-	if (np->dev_name) {
-		struct net *net = current->nsproxy->net_ns;
-		ndev = __dev_get_by_name(net, np->dev_name);
-	}
+	net = current->nsproxy->net_ns;
+	ndev = __dev_get_by_name(net, np->dev_name);
+
 	if (!ndev) {
 		np_err(np, "%s doesn't exist, aborting\n", np->dev_name);
 		err = -ENODEV;
-- 
2.5.0
