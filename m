From: akpm@osdl.org
Subject: [patch 1/1] remove last_rx update from loopback device
Date: Mon,  7 Mar 2005 16:22:41 -0800
Message-ID: <200503080022.j280MdD3008666@shell0.pdx.osdl.net>
Cc: netdev@oss.sgi.com, akpm@osdl.org, christoph@graphe.net,
        nirajk@calsoftinc.com, christoph@lameter.com, Shai@Scalex86.org
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Christoph Lameter <christoph@graphe.net>

The last_rx field in the loopback driver is updated on every xmit but is
not used otherwise.  Accesses to ->last_rx cause unecessary traffic on the
interlink for NUMA systems which limits the performance of the loopback
device.

The comment given at include/linux/netdevice.h says that last_rx may be
used for future network-power-down code, which is likely not relevant for
the loopback device (please let me know if it is otherwise ..).

Signed-off-by: Niraj Kumar <nirajk@calsoftinc.com>
Signed-off-by: Christoph Lameter <christoph@lameter.com>
Signed-off-by: Shai Fultheim <Shai@Scalex86.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/drivers/net/loopback.c |    2 --
 1 files changed, 2 deletions(-)

diff -puN drivers/net/loopback.c~remove-last_rx-update-from-loopback-device drivers/net/loopback.c
--- 25/drivers/net/loopback.c~remove-last_rx-update-from-loopback-device	Mon Mar  7 16:21:49 2005
+++ 25-akpm/drivers/net/loopback.c	Mon Mar  7 16:21:49 2005
@@ -144,8 +144,6 @@ static int loopback_xmit(struct sk_buff 
 		return 0;
 	}
 
-	dev->last_rx = jiffies;
-
 	lb_stats = &per_cpu(loopback_stats, get_cpu());
 	lb_stats->rx_bytes += skb->len;
 	lb_stats->tx_bytes += skb->len;
_
