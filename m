From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/4) acenic - eliminate MAX_SKB_FRAGS #if
Date: Mon, 20 Sep 2004 10:45:35 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040920104535.4c6ce363@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jes Sorensen <jes@wildopensource.com>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Since MAX_SKB_FRAGS is defined in both 2.4 and 2.6, it makes sense
to eliminate this old #if code.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/acenic.c b/drivers/net/acenic.c
--- a/drivers/net/acenic.c	2004-09-20 10:46:46 -07:00
+++ b/drivers/net/acenic.c	2004-09-20 10:46:46 -07:00
@@ -2523,10 +2523,7 @@
 	if (tx_ring_full(ap, ap->tx_ret_csm, idx))
 		goto overflow;
 
-#if MAX_SKB_FRAGS
-	if (!skb_shinfo(skb)->nr_frags)
-#endif
-	{
+	if (!skb_shinfo(skb)->nr_frags)	{
 		dma_addr_t mapping;
 		u32 vlan_tag = 0;
 
@@ -2548,9 +2545,7 @@
 			flagsize |= BD_FLG_COAL_NOW;
 
 		ace_load_tx_bd(ap, desc, mapping, flagsize, vlan_tag);
-	}
-#if MAX_SKB_FRAGS
-	else {
+	} else {
 		dma_addr_t mapping;
 		u32 vlan_tag = 0;
 		int i, len = 0;
@@ -2605,7 +2600,6 @@
 			ace_load_tx_bd(ap, desc, mapping, flagsize, vlan_tag);
 		}
 	}
-#endif
 
  	wmb();
  	ap->tx_prd = idx;
diff -Nru a/drivers/net/acenic.h b/drivers/net/acenic.h
--- a/drivers/net/acenic.h	2004-09-20 10:46:46 -07:00
+++ b/drivers/net/acenic.h	2004-09-20 10:46:46 -07:00
@@ -10,11 +10,6 @@
  */
 #define USE_TX_COAL_NOW	 0
 
-#ifndef MAX_SKB_FRAGS
-#define MAX_SKB_FRAGS 0
-#endif
-
-
 /*
  * Addressing:
  *
@@ -712,13 +707,7 @@
 }
 
 #define tx_free(ap) 		tx_space((ap)->tx_ret_csm, (ap)->tx_prd, ap)
-
-#if MAX_SKB_FRAGS
 #define tx_ring_full(ap, csm, prd)	(tx_space(ap, csm, prd) <= TX_RESERVED)
-#else
-#define tx_ring_full			0
-#endif
-
 
 static inline void set_aceaddr(aceaddr *aa, dma_addr_t addr)
 {
