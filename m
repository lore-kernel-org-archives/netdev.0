From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 51/54] wlags49_h2: Call dev_kfree/consume_skb_any instead of dev_kfree_skb.
Date: Mon, 24 Mar 2014 23:05:37 -0700
Message-ID: <1395727540-12148-51-git-send-email-ebiederm@xmission.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:59069 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752228AbaCYGLd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 02:11:33 -0400
In-Reply-To: <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Replace dev_kfree_skb with dev_consume_skb_any in wl_send and
wl_send_dma which can be called in hard irq and other contexts,
on the code paths where the skb was transmitted successfully.

Replace dev_kfree_skb with dev_kfree_skb_any in wl_send_dmay which can
be called in hard irq and other contexts, on the code path where a
skb is dropped.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/staging/wlags49_h2/wl_netdev.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/wlags49_h2/wl_netdev.c b/drivers/staging/wlags49_h2/wl_netdev.c
index 965b1c0a4753..69bc0a01ae14 100644
--- a/drivers/staging/wlags49_h2/wl_netdev.c
+++ b/drivers/staging/wlags49_h2/wl_netdev.c
@@ -715,7 +715,7 @@ int wl_send( struct wl_private *lp )
 
         /* Free the skb and perform queue cleanup, as the buffer was
             transmitted successfully */
-        dev_kfree_skb( lp->txF.skb );
+        dev_consume_skb_any( lp->txF.skb );
 
         lp->txF.skb = NULL;
         lp->txF.port = 0;
@@ -1730,7 +1730,7 @@ int wl_send_dma( struct wl_private *lp, struct sk_buff *skb, int port )
             WL_WDS_NETIF_STOP_QUEUE( lp );
             lp->netif_queue_on = FALSE;
 
-            dev_kfree_skb( skb );
+            dev_kfree_skb_any( skb );
             return 0;
         }
     }
@@ -1755,7 +1755,7 @@ int wl_send_dma( struct wl_private *lp, struct sk_buff *skb, int port )
 
     /* Free the skb and perform queue cleanup, as the buffer was
             transmitted successfully */
-    dev_kfree_skb( skb );
+    dev_consume_skb_any( skb );
 
     return TRUE;
 } // wl_send_dma
-- 
1.7.10.4
