From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] cxgb3: remove pointless conditional before kfree_skb()
Date: Tue, 28 Aug 2012 21:04:38 +0800
Message-ID: <CAPgLHd9b+0DDZ9iYFzNS4NP1w_3GmWaMD+ihqeVeEGXei9cfUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:58056 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752684Ab2H1NEj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Aug 2012 09:04:39 -0400
Received: by qaas11 with SMTP id s11so2610628qaa.19
        for <netdev@vger.kernel.org>; Tue, 28 Aug 2012 06:04:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Remove pointless conditional before kfree_skb().

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c | 3 +--
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c    | 3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
index 2dbbcbb..aac26f2 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
@@ -1341,8 +1341,7 @@ void cxgb3_offload_deactivate(struct adapter *adapter)
 	rcu_read_unlock();
 	RCU_INIT_POINTER(tdev->l2opt, NULL);
 	call_rcu(&d->rcu_head, clean_l2_data);
-	if (t->nofail_skb)
-		kfree_skb(t->nofail_skb);
+	kfree_skb(t->nofail_skb);
 	kfree(t);
 }
 

diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
index 6505070..0b79309 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
@@ -3412,8 +3412,7 @@ static void __devexit remove_one(struct pci_dev *pdev)
 				free_netdev(adapter->port[i]);
 
 		iounmap(adapter->regs);
-		if (adapter->nofail_skb)
-			kfree_skb(adapter->nofail_skb);
+		kfree_skb(adapter->nofail_skb);
 		kfree(adapter);
 		pci_release_regions(pdev);
 		pci_disable_device(pdev);
