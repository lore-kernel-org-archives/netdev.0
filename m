From: Ralf Baechle DL5RB <ralf@linux-mips.org>
Subject: [PATCH  3/12] NET/ROM statistics fix
Date: Sun, 11 Sep 2005 23:18:51 +0100
Message-ID: <20050911221851.GA9287@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-hams-owner@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Calling an incoming NET/ROM-encapsulated IP packet an error if the interface
isn't up is probably a bit over the top, so count it as dropped instead of
an error.

Signed-off-by: Ralf Baechle DL5RB <ralf@linux-mips.org>

 net/netrom/nr_dev.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

Index: net-2.6.git/net/netrom/nr_dev.c
===================================================================
--- net-2.6.git.orig/net/netrom/nr_dev.c
+++ net-2.6.git/net/netrom/nr_dev.c
@@ -47,7 +47,7 @@ int nr_rx_ip(struct sk_buff *skb, struct
 	struct net_device_stats *stats = netdev_priv(dev);
 
 	if (!netif_running(dev)) {
-		stats->rx_errors++;
+		stats->rx_dropped++;
 		return 0;
 	}
 
