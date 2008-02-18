From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 1/1] claw: make use of DIV_ROUND_UP
Date: Mon, 18 Feb 2008 14:41:55 +0100
Message-ID: <20080218134803.497224000@linux.vnet.ibm.com>
References: <20080218134154.893427000@linux.vnet.ibm.com>
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, julia@diku.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:21297 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754339AbYBRNsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2008 08:48:07 -0500
Content-Disposition: inline; filename=715-claw-div.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

The kernel.h macro DIV_ROUND_UP performs the computation
(((n) + (d) - 1) / (d)) but is perhaps more readable.

Signed-off-by: Ursula Braun <braunu@de.ibm.com>
---

 drivers/s390/net/claw.c |   39 ++++++++++++++++++---------------------
 1 file changed, 18 insertions(+), 21 deletions(-)

Index: linux-2.6-uschi/drivers/s390/net/claw.c
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/claw.c
+++ linux-2.6-uschi/drivers/s390/net/claw.c
@@ -1851,8 +1851,7 @@ claw_hw_tx(struct sk_buff *skb, struct n
                 }
         }
         /*      See how many write buffers are required to hold this data */
-        numBuffers= ( skb->len + privptr->p_env->write_size - 1) /
-			( privptr->p_env->write_size);
+	numBuffers = DIV_ROUND_UP(skb->len, privptr->p_env->write_size);
 
         /*      If that number of buffers isn't available, give up for now */
         if (privptr->write_free_count < numBuffers ||
@@ -2114,8 +2113,7 @@ init_ccw_bk(struct net_device *dev)
         */
         ccw_blocks_perpage= PAGE_SIZE /  CCWBK_SIZE;
         ccw_pages_required=
-		(ccw_blocks_required+ccw_blocks_perpage -1) /
-			 ccw_blocks_perpage;
+		DIV_ROUND_UP(ccw_blocks_required, ccw_blocks_perpage);
 
 #ifdef DEBUGMSG
         printk(KERN_INFO "%s: %s() > ccw_blocks_perpage=%d\n",
@@ -2131,30 +2129,29 @@ init_ccw_bk(struct net_device *dev)
 	 * provide good performance. With packing buffers support 32k
 	 * buffers are used.
          */
-        if (privptr->p_env->read_size < PAGE_SIZE) {
-            claw_reads_perpage= PAGE_SIZE / privptr->p_env->read_size;
-            claw_read_pages= (privptr->p_env->read_buffers +
-	    	claw_reads_perpage -1) / claw_reads_perpage;
+	if (privptr->p_env->read_size < PAGE_SIZE) {
+		claw_reads_perpage = PAGE_SIZE / privptr->p_env->read_size;
+		claw_read_pages = DIV_ROUND_UP(privptr->p_env->read_buffers,
+						claw_reads_perpage);
          }
          else {       /* > or equal  */
-            privptr->p_buff_pages_perread=
-	    	(privptr->p_env->read_size + PAGE_SIZE - 1) / PAGE_SIZE;
-            claw_read_pages=
-	    	privptr->p_env->read_buffers * privptr->p_buff_pages_perread;
+		privptr->p_buff_pages_perread =
+			DIV_ROUND_UP(privptr->p_env->read_size, PAGE_SIZE);
+		claw_read_pages = privptr->p_env->read_buffers *
+					privptr->p_buff_pages_perread;
          }
         if (privptr->p_env->write_size < PAGE_SIZE) {
-            claw_writes_perpage=
-	    	PAGE_SIZE / privptr->p_env->write_size;
-            claw_write_pages=
-	    	(privptr->p_env->write_buffers + claw_writes_perpage -1) /
-			claw_writes_perpage;
+		claw_writes_perpage =
+			PAGE_SIZE / privptr->p_env->write_size;
+		claw_write_pages = DIV_ROUND_UP(privptr->p_env->write_buffers,
+						claw_writes_perpage);
 
         }
         else {      /* >  or equal  */
-            privptr->p_buff_pages_perwrite=
-	    	 (privptr->p_env->read_size + PAGE_SIZE - 1) / PAGE_SIZE;
-            claw_write_pages=
-	     	privptr->p_env->write_buffers * privptr->p_buff_pages_perwrite;
+		privptr->p_buff_pages_perwrite =
+			DIV_ROUND_UP(privptr->p_env->read_size, PAGE_SIZE);
+		claw_write_pages = privptr->p_env->write_buffers *
+					privptr->p_buff_pages_perwrite;
         }
 #ifdef DEBUGMSG
         if (privptr->p_env->read_size < PAGE_SIZE) {

-- 
