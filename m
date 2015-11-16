From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] cxgb3: Delete unnecessary checks before the function call
 "kfree_skb"
Date: Mon, 16 Nov 2015 12:52:28 +0100
Message-ID: <5649C37C.9000603@users.sourceforge.net>
References: <5307CAA2.8060406@users.sourceforge.net>
 <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6>
 <530A086E.8010901@users.sourceforge.net>
 <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6>
 <530A72AA.3000601@users.sourceforge.net>
 <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6>
 <530B5FB6.6010207@users.sourceforge.net>
 <alpine.DEB.2.10.1402241710370.2074@hadrien>
 <530C5E18.1020800@users.sourceforge.net>
 <alpine.DEB.2.10.1402251014170.2080@hadrien>
 <530CD2C4.4050903@users.sourceforge.net>
 <alpine.DEB.2.10.1402251840450.7035@hadrien>
 <530CF8FF.8080600@users.sourceforge.net>
 <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6>
 <530DD06F.4090703@users.sourceforge.net>
 <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
 <5317A59D.4@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: netdev@vger.kernel.org, Santosh Raspatur <santosh@chelsio.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5317A59D.4@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 16 Nov 2015 12:46:41 +0100

The kfree_skb() function tests whether its argument is NULL and then
returns immediately. Thus the test around the calls is not needed.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c    | 3 +--
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c | 3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
index 8f7aa53a..89f193b 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
@@ -3401,8 +3401,7 @@ static void remove_one(struct pci_dev *pdev)
 				free_netdev(adapter->port[i]);
 
 		iounmap(adapter->regs);
-		if (adapter->nofail_skb)
-			kfree_skb(adapter->nofail_skb);
+		kfree_skb(adapter->nofail_skb);
 		kfree(adapter);
 		pci_release_regions(pdev);
 		pci_disable_device(pdev);
diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
index 76684dc..9a77339 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
@@ -1323,8 +1323,7 @@ void cxgb3_offload_deactivate(struct adapter *adapter)
 	rcu_read_unlock();
 	RCU_INIT_POINTER(tdev->l2opt, NULL);
 	call_rcu(&d->rcu_head, clean_l2_data);
-	if (t->nofail_skb)
-		kfree_skb(t->nofail_skb);
+	kfree_skb(t->nofail_skb);
 	kfree(t);
 }
 
-- 
2.6.2
