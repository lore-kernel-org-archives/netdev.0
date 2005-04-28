From: Jesper Juhl <juhl-lkml@dif.dk>
Subject: [PATCH] ppp: remove redundant NULL pointer checks before kfree &
 vfree
Date: Fri, 29 Apr 2005 00:54:44 +0200 (CEST)
Message-ID: <Pine.LNX.4.62.0504290049240.2476@dragon.hyggekrogen.localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-ppp@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-ppp-owner@vger.kernel.org>
To: Paul Mackerras <paulus@samba.org>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

kfree() and vfree() can both deal with NULL pointers. This patch removes 
redundant NULL pointer checks from the ppp code in drivers/net/

Signed-off-by: Jesper Juhl <juhl-lkml@dif.dk>
---

 drivers/net/ppp_deflate.c |    6 ++----
 drivers/net/ppp_generic.c |   12 ++++--------
 2 files changed, 6 insertions(+), 12 deletions(-)

--- linux-2.6.12-rc2-mm3-orig/drivers/net/ppp_deflate.c	2005-04-05 21:21:33.000000000 +0200
+++ linux-2.6.12-rc2-mm3/drivers/net/ppp_deflate.c	2005-04-29 00:44:26.000000000 +0200
@@ -87,8 +87,7 @@ static void z_comp_free(void *arg)
 
 	if (state) {
 		zlib_deflateEnd(&state->strm);
-		if (state->strm.workspace)
-			vfree(state->strm.workspace);
+		vfree(state->strm.workspace);
 		kfree(state);
 	}
 }
@@ -308,8 +307,7 @@ static void z_decomp_free(void *arg)
 
 	if (state) {
 		zlib_inflateEnd(&state->strm);
-		if (state->strm.workspace)
-			kfree(state->strm.workspace);
+		kfree(state->strm.workspace);
 		kfree(state);
 	}
 }
--- linux-2.6.12-rc2-mm3-orig/drivers/net/ppp_generic.c	2005-04-11 21:20:47.000000000 +0200
+++ linux-2.6.12-rc2-mm3/drivers/net/ppp_generic.c	2005-04-29 00:46:00.000000000 +0200
@@ -2510,14 +2510,10 @@ static void ppp_destroy_interface(struct
 	skb_queue_purge(&ppp->mrq);
 #endif /* CONFIG_PPP_MULTILINK */
 #ifdef CONFIG_PPP_FILTER
-	if (ppp->pass_filter) {
-		kfree(ppp->pass_filter);
-		ppp->pass_filter = NULL;
-	}
-	if (ppp->active_filter) {
-		kfree(ppp->active_filter);
-		ppp->active_filter = NULL;
-	}
+	kfree(ppp->pass_filter);
+	ppp->pass_filter = NULL;
+	kfree(ppp->active_filter);
+	ppp->active_filter = NULL;
 #endif /* CONFIG_PPP_FILTER */
 
 	kfree(ppp);





PS. Please CC me on replies.



