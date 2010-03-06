From: Dan Carpenter <error27@gmail.com>
Subject: [patch] bridge: cleanup: remove unneed check
Date: Sat, 6 Mar 2010 14:14:09 +0300
Message-ID: <20100306111408.GJ4958@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
        bridge@lists.linux-foundation.org,
        "David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

We dereference "port" on the lines immediately before and immediately 
after the test so port should hopefully never be null here.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 2559fb5..8b25887 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -627,8 +627,8 @@ static void br_multicast_port_query_expired(unsigned long data)
 	struct net_bridge *br = port->br;
 
 	spin_lock(&br->multicast_lock);
-	if (port && (port->state == BR_STATE_DISABLED ||
-		     port->state == BR_STATE_BLOCKING))
+	if (port->state == BR_STATE_DISABLED ||
+	    port->state == BR_STATE_BLOCKING)
 		goto out;
 
 	if (port->multicast_startup_queries_sent <
