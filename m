From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] net/ethernet/eth.c: make a function static
Date: Tue, 14 Dec 2004 14:48:42 +0100
Message-ID: <20041214134842.GD23151@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261509AbULNNst@vger.kernel.org>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patch below makes a needlessly global function static.


diffstat output:
 include/linux/etherdevice.h |    2 --
 net/ethernet/eth.c          |    2 +-
 2 files changed, 1 insertion(+), 3 deletions(-)



Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.10-rc3-mm1-full/include/linux/etherdevice.h.old	2004-12-14 03:38:12.000000000 +0100
+++ linux-2.6.10-rc3-mm1-full/include/linux/etherdevice.h	2004-12-14 03:38:20.000000000 +0100
@@ -37,8 +37,6 @@
 						unsigned char * haddr);
 extern int		eth_header_cache(struct neighbour *neigh,
 					 struct hh_cache *hh);
-extern int		eth_header_parse(struct sk_buff *skb,
-					 unsigned char *haddr);
 
 extern struct net_device *alloc_etherdev(int sizeof_priv);
 static inline void eth_copy_and_sum (struct sk_buff *dest, 
--- linux-2.6.10-rc3-mm1-full/net/ethernet/eth.c.old	2004-12-14 03:38:29.000000000 +0100
+++ linux-2.6.10-rc3-mm1-full/net/ethernet/eth.c	2004-12-14 03:38:34.000000000 +0100
@@ -208,7 +208,7 @@
 	return htons(ETH_P_802_2);
 }
 
-int eth_header_parse(struct sk_buff *skb, unsigned char *haddr)
+static int eth_header_parse(struct sk_buff *skb, unsigned char *haddr)
 {
 	struct ethhdr *eth = eth_hdr(skb);
 	memcpy(haddr, eth->h_source, ETH_ALEN);
