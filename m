From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 5/6] cxgb4: Use seq_puts() in cim_qcfg_show()
Date: Thu, 4 May 2017 22:35:16 +0200
Message-ID: <2695f4a2-8201-1ae5-d93d-e4f41544c76c@users.sourceforge.net>
References: <a3216042-2461-b397-dfa1-1de178d58513@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
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
Date: Thu, 4 May 2017 21:52:32 +0200

A string which did not contain a data format specification should be put
into a sequence. Thus use the corresponding function "seq_puts".

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 2bc40d89f874..32add8dfc253 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -357,9 +357,8 @@ static int cim_qcfg_show(struct seq_file *seq, void *v)
 		return i;
 
 	t4_read_cimq_cfg(adap, base, size, thres);
-
-	seq_printf(seq,
-		   "  Queue  Base  Size Thres  RdPtr WrPtr  SOP  EOP Avail\n");
+	seq_puts(seq,
+		 "  Queue  Base  Size Thres  RdPtr WrPtr  SOP  EOP Avail\n");
 	for (i = 0; i < CIM_NUM_IBQ; i++, p += 4)
 		seq_printf(seq, "%7s %5x %5u %5u %6x  %4x %4u %4u %5u\n",
 			   qname[i], base[i], size[i], thres[i],
-- 
2.12.2
