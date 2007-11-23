From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: [PATCH 5/8] ipg: remove commented out code
Date: Fri, 23 Nov 2007 10:19:33 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0711231019210.18378@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: romieu@fr.zoreil.com, sorbica@icplus.com.tw, jesse@icplus.com.tw,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42513 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751551AbXKWITe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2007 03:19:34 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pekka Enberg <penberg@cs.helsinki.fi>

Cc: Francois Romieu <romieu@fr.zoreil.com>
Cc: Sorbica Shieh <sorbica@icplus.com.tw>
Cc: Jesse Huang <jesse@icplus.com.tw>
Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---
 drivers/net/ipg.c |   34 ++++++----------------------------
 drivers/net/ipg.h |    4 +---
 2 files changed, 7 insertions(+), 31 deletions(-)

Index: linux-2.6/drivers/net/ipg.c
===================================================================
--- linux-2.6.orig/drivers/net/ipg.c
+++ linux-2.6/drivers/net/ipg.c
@@ -1492,35 +1492,13 @@ static int ipg_nic_rx(struct net_device 
 			/* Set the buffer's protocol field to Ethernet. */
 			skb->protocol = eth_type_trans(skb, dev);
 
-			/* If the frame contains an IP/TCP/UDP frame,
-			 * determine if upper layer must check IP/TCP/UDP
-			 * checksums.
-			 *
-			 * NOTE: DO NOT RELY ON THE TCP/UDP CHECKSUM
-			 *       VERIFICATION FOR SILICON REVISIONS B3
-			 *       AND EARLIER!
-			 *
-			 if ((le64_to_cpu(rxfd->rfs &
-			     (IPG_RFS_TCPDETECTED | IPG_RFS_UDPDETECTED |
-			      IPG_RFS_IPDETECTED))) &&
-			    !(le64_to_cpu(rxfd->rfs &
-			      (IPG_RFS_TCPERROR | IPG_RFS_UDPERROR |
-			       IPG_RFS_IPERROR)))) {
-				 * Indicate IP checksums were performed
-				 * by the IPG.
-				 *
-				skb->ip_summed = CHECKSUM_UNNECESSARY;
-			 } else
+			/* The IPG encountered an error with (or
+			 * there were no) IP/TCP/UDP checksums.
+			 * This may or may not indicate an invalid
+			 * IP/TCP/UDP frame was received. Let the
+			 * upper layer decide.
 			 */
-			 {
-				/* The IPG encountered an error with (or
-				 * there were no) IP/TCP/UDP checksums.
-				 * This may or may not indicate an invalid
-				 * IP/TCP/UDP frame was received. Let the
-				 * upper layer decide.
-				 */
-				skb->ip_summed = CHECKSUM_NONE;
-			}
+			skb->ip_summed = CHECKSUM_NONE;
 
 			/* Hand off frame for higher layer processing.
 			 * The function netif_rx() releases the sk_buff
Index: linux-2.6/drivers/net/ipg.h
===================================================================
--- linux-2.6.orig/drivers/net/ipg.h
+++ linux-2.6/drivers/net/ipg.h
@@ -23,7 +23,6 @@
 #include <linux/skbuff.h>
 #include <linux/version.h>
 #include <asm/bitops.h>
-/*#include <asm/spinlock.h>*/
 
 /*
  *	Constants
@@ -733,8 +732,7 @@ enum ipg_regs {
  * Miscellaneous macros.
  */
 
-/* Marco for printing debug statements.
-#  define IPG_DDEBUG_MSG(args...) printk(KERN_DEBUG "IPG: " ## args) */
+/* Marco for printing debug statements. */
 #ifdef IPG_DEBUG
 #  define IPG_DEBUG_MSG(args...)
 #  define IPG_DDEBUG_MSG(args...) printk(KERN_DEBUG "IPG: " args)
