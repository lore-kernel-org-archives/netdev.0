From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/4) bridge: use jenkins hash
Date: Thu, 10 Mar 2005 15:44:29 -0800
Message-ID: <20050310154429.0f879894@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, bridge@osdl.org
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Replace the existing mac hash in the bridge code with the nice
inline jenkins hash. This should provide better distribution across
hash buckets and compiles to code that is similar in complexity.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
--- a/net/bridge/br_fdb.c	2005-03-10 15:05:11 -08:00
+++ b/net/bridge/br_fdb.c	2005-03-10 15:05:11 -08:00
@@ -19,6 +19,7 @@
 #include <linux/times.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
+#include <linux/jhash.h>
 #include <asm/atomic.h>
 #include "br_private.h"
 
@@ -57,18 +58,7 @@
 
 static __inline__ int br_mac_hash(const unsigned char *mac)
 {
-	unsigned long x;
-
-	x = mac[0];
-	x = (x << 2) ^ mac[1];
-	x = (x << 2) ^ mac[2];
-	x = (x << 2) ^ mac[3];
-	x = (x << 2) ^ mac[4];
-	x = (x << 2) ^ mac[5];
-
-	x ^= x >> 8;
-
-	return x & (BR_HASH_SIZE - 1);
+	return jhash(mac, ETH_ALEN, 0) & (BR_HASH_SIZE - 1);
 }
 
 static __inline__ void fdb_delete(struct net_bridge_fdb_entry *f)
