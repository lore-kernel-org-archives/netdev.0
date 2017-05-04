From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 3/6] cxgb4vf: Adjust five checks for null pointers
Date: Thu, 4 May 2017 22:33:22 +0200
Message-ID: <921bc451-3b7b-1d77-72eb-755061a7fe09@users.sourceforge.net>
References: <a3216042-2461-b397-dfa1-1de178d58513@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, Casey Leedom <leedom@chelsio.com>,
        Ganesh Goudar <ganeshgr@chelsio.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a3216042-2461-b397-dfa1-1de178d58513@users.sourceforge.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Thu, 4 May 2017 21:20:25 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

The script “checkpatch.pl” pointed information out like the following.

Comparison to NULL could be written !…

Thus fix the affected source code places.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 9c2690aeb32b..682e844c5a7d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -491,7 +491,7 @@ static int fwevtq_handler(struct sge_rspq *rspq, const __be64 *rsp,
 			break;
 		}
 		tq = s->egr_map[eq_idx];
-		if (unlikely(tq == NULL)) {
+		if (unlikely(!tq)) {
 			dev_err(adapter->pdev_dev,
 				"Egress Update QID %d TXQ=NULL\n", qid);
 			break;
@@ -2939,7 +2939,7 @@ static int cxgb4vf_pci_probe(struct pci_dev *pdev,
 		 */
 		netdev = alloc_etherdev_mq(sizeof(struct port_info),
 					   MAX_PORT_QSETS);
-		if (netdev == NULL) {
+		if (!netdev) {
 			t4vf_free_vi(adapter, viid);
 			err = -ENOMEM;
 			goto err_free_dev;
@@ -3053,7 +3053,7 @@ static int cxgb4vf_pci_probe(struct pci_dev *pdev,
 	for_each_port(adapter, pidx) {
 		struct port_info *pi = netdev_priv(adapter->port[pidx]);
 		netdev = adapter->port[pidx];
-		if (netdev == NULL)
+		if (!netdev)
 			continue;
 
 		netif_set_real_num_tx_queues(netdev, pi->nqsets);
@@ -3120,7 +3120,7 @@ static int cxgb4vf_pci_probe(struct pci_dev *pdev,
 err_free_dev:
 	for_each_port(adapter, pidx) {
 		netdev = adapter->port[pidx];
-		if (netdev == NULL)
+		if (!netdev)
 			continue;
 		pi = netdev_priv(netdev);
 		t4vf_free_vi(adapter, pi->viid);
@@ -3197,7 +3197,7 @@ static void cxgb4vf_pci_remove(struct pci_dev *pdev)
 			struct net_device *netdev = adapter->port[pidx];
 			struct port_info *pi;
 
-			if (netdev == NULL)
+			if (!netdev)
 				continue;
 
 			pi = netdev_priv(netdev);
-- 
2.12.2
