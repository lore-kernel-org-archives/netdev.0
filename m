From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: [PATCH] net/cxgb4: use remove handler as shutdown handler
Date: Mon, 24 Feb 2014 17:04:52 -0300
Message-ID: <1393272292-11268-1-git-send-email-cascardo@linux.vnet.ibm.com>
Cc: dm@chelsio.com, davem@davemloft.net, linux-kernel@vger.kernel.org,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Without a shutdown handler, T4 cards behave very badly after a kexec.
Some firmware calls return errors indicating allocation failures, for
example. This is probably because thouse resources were not released by
a BYE message to the firmware, for example.

Using the remove handler guarantees we will use a well tested path.

With this patch I applied, I managed to use kexec multiple times and
probe and iSCSI login worked every time.

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 43ab35f..34e2488 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -6179,6 +6179,7 @@ static struct pci_driver cxgb4_driver = {
 	.id_table = cxgb4_pci_tbl,
 	.probe    = init_one,
 	.remove   = remove_one,
+	.shutdown = remove_one,
 	.err_handler = &cxgb4_eeh,
 };
 
-- 
1.7.1
