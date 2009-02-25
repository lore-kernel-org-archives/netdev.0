From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] ppp: remove some pointless conditionals before kfree_skb()
Date: Wed, 25 Feb 2009 18:16:08 +0800
Message-ID: <49A51A68.3000509@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: linux-ppp@vger.kernel.org, netdev@vger.kernel.org
To: Paul Mackerras <paulus@samba.org>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <linux-ppp-owner@vger.kernel.org>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove some pointless conditionals before kfree_skb().

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 drivers/net/ppp_async.c   |    6 ++----
 drivers/net/ppp_generic.c |    6 ++----
 drivers/net/ppp_synctty.c |    3 +--
 3 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ppp_async.c b/drivers/net/ppp_async.c
index 6567fab..5de6fed 100644
--- a/drivers/net/ppp_async.c
+++ b/drivers/net/ppp_async.c
@@ -233,11 +233,9 @@ ppp_asynctty_close(struct tty_struct *tty)
 	tasklet_kill(&ap->tsk);
 
 	ppp_unregister_channel(&ap->chan);
-	if (ap->rpkt)
-		kfree_skb(ap->rpkt);
+	kfree_skb(ap->rpkt);
 	skb_queue_purge(&ap->rqueue);
-	if (ap->tpkt)
-		kfree_skb(ap->tpkt);
+	kfree_skb(ap->tpkt);
 	kfree(ap);
 }
 
diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index 81e7fcc..4a12159 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -1245,8 +1245,7 @@ ppp_send_frame(struct ppp *ppp, struct sk_buff *skb)
 	return;
 
  drop:
-	if (skb)
-		kfree_skb(skb);
+	kfree_skb(skb);
 	++ppp->dev->stats.tx_errors;
 }
 
@@ -2658,8 +2657,7 @@ static void ppp_destroy_interface(struct ppp *ppp)
 	ppp->active_filter = NULL;
 #endif /* CONFIG_PPP_FILTER */
 
-	if (ppp->xmit_pending)
-		kfree_skb(ppp->xmit_pending);
+	kfree_skb(ppp->xmit_pending);
 
 	free_netdev(ppp->dev);
 }
diff --git a/drivers/net/ppp_synctty.c b/drivers/net/ppp_synctty.c
index 1e892b7..3ea791d 100644
--- a/drivers/net/ppp_synctty.c
+++ b/drivers/net/ppp_synctty.c
@@ -281,8 +281,7 @@ ppp_sync_close(struct tty_struct *tty)
 
 	ppp_unregister_channel(&ap->chan);
 	skb_queue_purge(&ap->rqueue);
-	if (ap->tpkt)
-		kfree_skb(ap->tpkt);
+	kfree_skb(ap->tpkt);
 	kfree(ap);
 }
 
-- 
1.5.3.8




