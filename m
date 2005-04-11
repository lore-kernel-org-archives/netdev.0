From: Jesper Juhl <juhl-lkml@dif.dk>
Subject: [PATCH] net: remove redundant NULL pointer checks prior to kfree in
 drivers/net/slip.c
Date: Mon, 11 Apr 2005 23:15:40 +0200 (CEST)
Message-ID: <Pine.LNX.4.62.0504112311130.2480@dragon.hyggekrogen.localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Laurence Culhane <loz@holmes.demon.co.uk>,
        "Fred N. van Kempen" <waltje@uwalt.nl.mugnet.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

kfree() checks for NULL. Checking prior to calling it is redundant.
This patch removes these redundant checks from drivers/net/slip.c

Signed-off-by: Jesper Juhl <juhl-lkml@dif.dk>
---

 slip.c |   30 ++++++++++++------------------
 1 files changed, 12 insertions(+), 18 deletions(-)

--- linux-2.6.12-rc2-mm3-orig/drivers/net/slip.c	2005-03-02 08:38:33.000000000 +0100
+++ linux-2.6.12-rc2-mm3/drivers/net/slip.c	2005-04-11 23:10:06.000000000 +0200
@@ -185,15 +185,12 @@ sl_alloc_bufs(struct slip *sl, int mtu)
 	/* Cleanup */
 err_exit:
 #ifdef SL_INCLUDE_CSLIP
-	if (cbuff)
-		kfree(cbuff);
+	kfree(cbuff);
 	if (slcomp)
 		slhc_free(slcomp);
 #endif
-	if (xbuff)
-		kfree(xbuff);
-	if (rbuff)
-		kfree(rbuff);
+	kfree(xbuff);
+	kfree(rbuff);
 	return err;
 }
 
@@ -204,13 +201,13 @@ sl_free_bufs(struct slip *sl)
 	void * tmp;
 
 	/* Free all SLIP frame buffers. */
-	if ((tmp = xchg(&sl->rbuff, NULL)) != NULL)
-		kfree(tmp);
-	if ((tmp = xchg(&sl->xbuff, NULL)) != NULL)
-		kfree(tmp);
+	tmp = xchg(&sl->rbuff, NULL);
+	kfree(tmp);
+	tmp = xchg(&sl->xbuff, NULL);
+	kfree(tmp);
 #ifdef SL_INCLUDE_CSLIP
-	if ((tmp = xchg(&sl->cbuff, NULL)) != NULL)
-		kfree(tmp);
+	tmp = xchg(&sl->cbuff, NULL);
+	kfree(tmp);
 	if ((tmp = xchg(&sl->slcomp, NULL)) != NULL)
 		slhc_free(tmp);
 #endif
@@ -297,13 +294,10 @@ done_on_bh:
 	spin_unlock_bh(&sl->lock);
 
 done:
-	if (xbuff)
-		kfree(xbuff);
-	if (rbuff)
-		kfree(rbuff);
+	kfree(xbuff);
+	kfree(rbuff);
 #ifdef SL_INCLUDE_CSLIP
-	if (cbuff)
-		kfree(cbuff);
+	kfree(cbuff);
 #endif
 	return err;
 }
