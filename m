From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] pktgen: remove some pointless conditionals before kfree_skb()
Date: Wed, 25 Feb 2009 18:31:54 +0800
Message-ID: <49A51E1A.5050601@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58930 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1762071AbZBYKcc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2009 05:32:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove some pointless conditionals before kfree_skb().

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/core/pktgen.c |   18 ++++++------------
 1 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 6549848..32d419f 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3275,8 +3275,7 @@ static void pktgen_stop(struct pktgen_thread *t)
 
 	list_for_each_entry(pkt_dev, &t->if_list, list) {
 		pktgen_stop_device(pkt_dev);
-		if (pkt_dev->skb)
-			kfree_skb(pkt_dev->skb);
+		kfree_skb(pkt_dev->skb);
 
 		pkt_dev->skb = NULL;
 	}
@@ -3303,8 +3302,7 @@ static void pktgen_rem_one_if(struct pktgen_thread *t)
 		if (!cur->removal_mark)
 			continue;
 
-		if (cur->skb)
-			kfree_skb(cur->skb);
+		kfree_skb(cur->skb);
 		cur->skb = NULL;
 
 		pktgen_remove_device(t, cur);
@@ -3328,8 +3326,7 @@ static void pktgen_rem_all_ifs(struct pktgen_thread *t)
 	list_for_each_safe(q, n, &t->if_list) {
 		cur = list_entry(q, struct pktgen_dev, list);
 
-		if (cur->skb)
-			kfree_skb(cur->skb);
+		kfree_skb(cur->skb);
 		cur->skb = NULL;
 
 		pktgen_remove_device(t, cur);
@@ -3393,8 +3390,7 @@ static __inline__ void pktgen_xmit(struct pktgen_dev *pkt_dev)
 
 		if (!netif_running(odev)) {
 			pktgen_stop_device(pkt_dev);
-			if (pkt_dev->skb)
-				kfree_skb(pkt_dev->skb);
+			kfree_skb(pkt_dev->skb);
 			pkt_dev->skb = NULL;
 			goto out;
 		}
@@ -3415,8 +3411,7 @@ static __inline__ void pktgen_xmit(struct pktgen_dev *pkt_dev)
 		if ((++pkt_dev->clone_count >= pkt_dev->clone_skb)
 		    || (!pkt_dev->skb)) {
 			/* build a new pkt */
-			if (pkt_dev->skb)
-				kfree_skb(pkt_dev->skb);
+			kfree_skb(pkt_dev->skb);
 
 			pkt_dev->skb = fill_packet(odev, pkt_dev);
 			if (pkt_dev->skb == NULL) {
@@ -3498,8 +3493,7 @@ static __inline__ void pktgen_xmit(struct pktgen_dev *pkt_dev)
 
 		/* Done with this */
 		pktgen_stop_device(pkt_dev);
-		if (pkt_dev->skb)
-			kfree_skb(pkt_dev->skb);
+		kfree_skb(pkt_dev->skb);
 		pkt_dev->skb = NULL;
 	}
 out:;
-- 
1.5.3.8




